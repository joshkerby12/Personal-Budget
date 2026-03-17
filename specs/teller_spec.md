# Teller Integration Spec — TASK-017

Bank account connection via Teller. Syncs real transactions into the `transactions` table every 6 hours. Connected accounts managed from the Settings screen.

---

## Overview

- User connects a bank account via Teller Connect (JS widget, Flutter web interop)
- Access token is sent immediately to a Supabase Edge Function and stored server-side — never persists in Flutter
- A scheduled Edge Function (`teller-sync`) runs every 6 hours, pulls transactions from Teller, deduplicates, and inserts into `transactions` with `source='teller'`, `category='Uncategorized'`, `subcategory='Uncategorized'`
- All Teller API calls are made server-side (Edge Functions) using the Teller certificate + key stored as environment secrets
- User can manually trigger sync, view connected accounts, and disconnect from Settings

---

## Architecture

```
Flutter (web)
  └─ Teller Connect JS widget (dart:js_interop)
       └─ onSuccess → POST enrollment to teller-enroll edge function

Supabase Edge Functions
  ├─ teller-enroll   — stores access token in teller_enrollments
  ├─ teller-sync     — pulls + imports transactions (called by cron + manual trigger)
  └─ teller-disconnect — deactivates enrollment, notifies Teller

Supabase pg_cron
  └─ every 6 hours → calls teller-sync for all active enrollments

Flutter (settings screen)
  └─ reads teller_enrollments, shows account list, connect/sync/disconnect buttons
```

---

## Database Changes

### New table: `teller_enrollments`

```sql
create table teller_enrollments (
  id                    uuid primary key default gen_random_uuid(),
  org_id                uuid not null references organizations(id) on delete cascade,
  profile_id            uuid not null references profiles(id),
  teller_enrollment_id  text not null,
  teller_access_token   text not null,        -- stored server-side only, never sent to Flutter
  institution_name      text not null,
  account_name          text not null,
  account_last_four     text,
  account_type          text not null,        -- 'depository' | 'credit'
  account_subtype       text,                 -- 'checking' | 'savings' | 'credit_card' etc.
  last_synced_at        timestamptz,
  is_active             boolean not null default true,
  created_at            timestamptz not null default now()
);

alter table teller_enrollments enable row level security;

-- Members can view their org's enrollments
create policy "org members can view enrollments"
  on teller_enrollments for select
  using (org_id in (select org_id from org_members where profile_id = auth.uid()));

-- Only the enrolling user can insert
create policy "user can insert own enrollment"
  on teller_enrollments for insert
  with check (
    profile_id = auth.uid()
    and org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Only owner/admin can update (last_synced_at, is_active)
create policy "admin can update enrollment"
  on teller_enrollments for update
  using (org_id in (
    select org_id from org_members
    where profile_id = auth.uid() and role in ('owner', 'admin')
  ));
```

**Important:** The `teller_access_token` column is only readable by Edge Functions (service role key). The Flutter client reads all other columns but the RLS select policy returns the full row. To prevent the token leaking to the client, the `teller-enroll` function writes directly using service role, and the Flutter-facing view (or select policy) should exclude `teller_access_token`. Implement via a Postgres view or by selecting specific columns in all Flutter queries.

### New table: `teller_sync_log`

```sql
create table teller_sync_log (
  id                     uuid primary key default gen_random_uuid(),
  enrollment_id          uuid not null references teller_enrollments(id) on delete cascade,
  synced_at              timestamptz not null default now(),
  transactions_imported  integer not null default 0,
  error                  text
);

alter table teller_sync_log enable row level security;

create policy "org members can view sync log"
  on teller_sync_log for select
  using (
    enrollment_id in (
      select id from teller_enrollments
      where org_id in (select org_id from org_members where profile_id = auth.uid())
    )
  );
```

### Alter `transactions` table

```sql
-- Track source (manual vs teller-imported)
alter table transactions add column source text not null default 'manual';

-- Dedup guard — Teller transaction IDs are unique per account
alter table transactions add column teller_transaction_id text unique;
```

---

## Dart Models

### `TellerEnrollment` (Freezed)

File: `lib/features/teller/models/teller_enrollment.dart`

```dart
@freezed
abstract class TellerEnrollment with _$TellerEnrollment {
  const factory TellerEnrollment({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'teller_enrollment_id') required String tellerEnrollmentId,
    @JsonKey(name: 'institution_name') required String institutionName,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'account_last_four') String? accountLastFour,
    @JsonKey(name: 'account_type') required String accountType,
    @JsonKey(name: 'account_subtype') String? accountSubtype,
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TellerEnrollment;

  factory TellerEnrollment.fromJson(Map<String, dynamic> json) =>
      _$TellerEnrollmentFromJson(json);
}
```

**Note:** No `accessToken` field — never returned to Flutter.

---

## Edge Functions

All three functions live in `supabase/functions/`. They use the service role key (available as `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')`) to bypass RLS. JWT verification is disabled — functions call `supabase.auth.getUser(jwt)` manually from the `Authorization` header.

### Environment variables (set in Supabase dashboard → Edge Functions → Secrets)

```
TELLER_CERT          — PEM certificate content (base64 or raw)
TELLER_KEY           — PEM private key content (base64 or raw)
TELLER_ENV           — 'sandbox' | 'development' | 'production'
```

---

### `teller-enroll`

**File:** `supabase/functions/teller-enroll/index.ts`

**Trigger:** POST from Flutter after Teller Connect `onSuccess`

**Request body:**
```json
{
  "enrollmentId": "enr_...",
  "accessToken": "token_...",
  "orgId": "uuid"
}
```

**Steps:**
1. Verify JWT from `Authorization` header — get `userId`
2. Confirm `userId` is a member of `orgId`
3. Call Teller API `GET /accounts` with the access token to fetch account details (institution name, account name/type/last four)
4. Insert row into `teller_enrollments` using service role (so `teller_access_token` is written but excluded from Flutter selects)
5. Call `teller-sync` inline for this enrollment to do the initial 90-day import
6. Return `{ success: true, enrollmentId: uuid }`

**Teller API call pattern (mTLS):**
```ts
// Teller requires mutual TLS — provide cert + key on every request
const cert = Deno.env.get('TELLER_CERT')!;
const key = Deno.env.get('TELLER_KEY')!;

const response = await fetch('https://api.teller.io/accounts', {
  headers: {
    'Authorization': `Basic ${btoa(accessToken + ':')}`,
  },
  client: Deno.createHttpClient({ certChain: cert, privateKey: key }),
});
```

---

### `teller-sync`

**File:** `supabase/functions/teller-sync/index.ts`

**Trigger:**
- POST from Flutter (manual sync) with `{ orgId, enrollmentId? }` — syncs one or all accounts for the org
- Called internally from `teller-enroll` for initial import
- Called by pg_cron every 6 hours for all active enrollments

**Steps:**
1. Verify caller (JWT auth for Flutter calls; service role for cron)
2. Fetch active enrollments for the org (or all orgs if called by cron with no orgId)
3. For each enrollment:
   a. Call `GET /accounts/{accountId}/transactions?from_date=YYYY-MM-DD` — for cron syncs, use `last_synced_at - 1 day` (overlap buffer); for initial sync, use 90 days ago
   b. For each Teller transaction:
      - Skip if `teller_transaction_id` already exists in `transactions`
      - Map to transaction row (see mapping below)
      - Insert via service role
   c. Update `teller_enrollments.last_synced_at = now()`
   d. Insert row into `teller_sync_log`
4. Return `{ imported: N }`

**Teller → transaction mapping:**

| Teller field | transactions column | Notes |
|---|---|---|
| `id` | `teller_transaction_id` | dedup key |
| `date` | `date` | `YYYY-MM-DD` |
| `amount` | `amount` | `abs(parseFloat(amount))` — Teller uses negative for debits on some account types |
| `description` | `merchant` | trim, max 200 chars |
| `description` | `description` | same value |
| `type` | — | used to determine income vs expense (see below) |
| — | `category` | `'Uncategorized'` |
| — | `subcategory` | `'Uncategorized'` |
| — | `biz_pct` | `0` |
| — | `is_split` | `false` |
| — | `source` | `'teller'` |
| — | `org_id` | from enrollment |
| — | `created_by` | enrollment's `profile_id` |

**Income detection:**
- If Teller `type = 'credit'` AND account type is `'depository'`: set `category = 'Income'`, `subcategory = 'Other Income'`
- All credits on credit card accounts are payments, not income — leave as `'Uncategorized'`

---

### `teller-disconnect`

**File:** `supabase/functions/teller-disconnect/index.ts`

**Trigger:** POST from Flutter with `{ enrollmentId }` (the Supabase UUID)

**Steps:**
1. Verify JWT — confirm user is member of the enrollment's org
2. Fetch `teller_access_token` and `teller_enrollment_id` via service role
3. Call Teller `DELETE /enrollments/{teller_enrollment_id}` (notifies Teller to revoke)
4. Set `teller_enrollments.is_active = false` — do NOT delete the row (preserve sync history)
5. Return `{ success: true }`

---

## Periodic Sync (pg_cron)

In Supabase dashboard → Database → Extensions → enable `pg_cron`.

```sql
-- Run teller-sync every 6 hours for all active enrollments
select cron.schedule(
  'teller-sync-6h',
  '0 */6 * * *',
  $$
  select net.http_post(
    url := 'https://xzjfxqkdzeawfnhfusut.supabase.co/functions/v1/teller-sync',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer <SERVICE_ROLE_KEY>"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
```

The `teller-sync` function, when called with no body (cron call), syncs all active enrollments across all orgs.

---

## Flutter Service

File: `lib/features/teller/data/teller_service.dart`

```dart
class TellerService {
  const TellerService(this._client);
  final SupabaseClient _client;

  // Fetch all active enrollments for the org
  Future<List<TellerEnrollment>> fetchEnrollments(String orgId) async {
    final rows = await _client
        .from('teller_enrollments')
        .select('id, org_id, profile_id, teller_enrollment_id, institution_name, '
                'account_name, account_last_four, account_type, account_subtype, '
                'last_synced_at, is_active, created_at')  // explicitly exclude access_token
        .eq('org_id', orgId)
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return rows.cast<Map<String, dynamic>>().map(TellerEnrollment.fromJson).toList();
  }

  // Called after Teller Connect onSuccess — passes token to edge function
  Future<void> enroll({
    required String orgId,
    required String enrollmentId,
    required String accessToken,
  }) async {
    final session = _client.auth.currentSession!;
    await _client.functions.invoke('teller-enroll', body: {
      'enrollmentId': enrollmentId,
      'accessToken': accessToken,
      'orgId': orgId,
    }, headers: {
      'Authorization': 'Bearer ${session.accessToken}',
    });
  }

  // Manual sync trigger
  Future<int> syncNow(String orgId, String enrollmentId) async {
    final session = _client.auth.currentSession!;
    final response = await _client.functions.invoke('teller-sync', body: {
      'orgId': orgId,
      'enrollmentId': enrollmentId,
    }, headers: {
      'Authorization': 'Bearer ${session.accessToken}',
    });
    return (response.data as Map<String, dynamic>)['imported'] as int? ?? 0;
  }

  // Disconnect
  Future<void> disconnect(String enrollmentId) async {
    final session = _client.auth.currentSession!;
    await _client.functions.invoke('teller-disconnect', body: {
      'enrollmentId': enrollmentId,
    }, headers: {
      'Authorization': 'Bearer ${session.accessToken}',
    });
  }
}
```

---

## Flutter Providers

File: `lib/features/teller/presentation/providers/teller_provider.dart`

```dart
@riverpod
TellerService tellerService(Ref ref) =>
    TellerService(ref.watch(supabaseClientProvider));

@riverpod
Future<List<TellerEnrollment>> tellerEnrollments(Ref ref, String orgId) async {
  return ref.read(tellerServiceProvider).fetchEnrollments(orgId);
}

@riverpod
class TellerController extends _$TellerController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> enroll(String orgId, String enrollmentId, String accessToken) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tellerServiceProvider).enroll(
        orgId: orgId, enrollmentId: enrollmentId, accessToken: accessToken);
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });
  }

  Future<int> syncNow(String orgId, String enrollmentId) async {
    state = const AsyncLoading();
    int imported = 0;
    state = await AsyncValue.guard(() async {
      imported = await ref.read(tellerServiceProvider).syncNow(orgId, enrollmentId);
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });
    return imported;
  }

  Future<void> disconnect(String orgId, String enrollmentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(tellerServiceProvider).disconnect(enrollmentId);
      ref.invalidate(tellerEnrollmentsProvider(orgId));
    });
  }
}
```

---

## Teller Connect (Flutter Web JS Interop)

File: `lib/features/teller/helpers/teller_connect.dart`

Teller Connect is a JS widget loaded from `https://cdn.teller.io/connect/connect.js`. On Flutter web, inject the script and call the widget via `dart:js_interop`.

```dart
// web/index.html — add before </body>:
// <script src="https://cdn.teller.io/connect/connect.js"></script>

// teller_connect.dart
import 'dart:js_interop';
import 'package:web/web.dart';

@JS('TellerConnect.setup')
external JSObject _tellerConnectSetup(JSObject options);

void launchTellerConnect({
  required String appId,            // from .env: TELLER_APP_ID
  required void Function(String enrollmentId, String accessToken) onSuccess,
}) {
  final handler = _tellerConnectSetup({
    'appId': appId,
    'environment': 'development',   // or 'production'
    'onSuccess': (JSObject enrollment) {
      final id = (enrollment['enrollment'] as JSObject)['id'].toString();
      final token = enrollment['accessToken'].toString();
      onSuccess(id, token);
    }.toJS,
  }.jsify()! as JSObject);

  // call open() on the returned handler
  (handler as JSObject).callMethod('open'.toJS);
}
```

Add `TELLER_APP_ID` to `.env` and `.env.example`.

---

## Settings UI — Connected Accounts Card

Add a new card to `SettingsEditor` (desktop) and `SettingsMobileScreen` (mobile), shown to all users.

### Card: "Connected Bank Accounts"

**Empty state:**
```
No bank accounts connected.
[Connect Account]  ← ElevatedButton
```

**With accounts — one row per enrollment:**
```
🏦  Chase Checking  ••••1234     Last synced: Mar 17 at 2:00 PM
    [Sync Now]  [Disconnect]
```

Row fields:
- Institution name + account name + last four
- Last synced timestamp (or "Never" if null)
- "Sync Now" button (OutlinedButton) — calls `syncNow`, shows snackbar with import count
- "Disconnect" button (TextButton, red) — shows confirmation dialog before calling `disconnect`

**Connect Account button** → calls `launchTellerConnect` → on success → calls `TellerController.enroll` → shows loading → on complete → shows snackbar "Connected! Importing transactions..." → refreshes list

### Placement in `SettingsEditor`

- Desktop: new card below the invite code card, above mileage rate
- Mobile: same position in the single-column scroll

---

## File Map

| File | What |
|---|---|
| `supabase/migrations/YYYYMMDD_teller.sql` | New tables + alter transactions |
| `supabase/functions/teller-enroll/index.ts` | Enrollment edge function |
| `supabase/functions/teller-sync/index.ts` | Sync edge function |
| `supabase/functions/teller-disconnect/index.ts` | Disconnect edge function |
| `lib/features/teller/models/teller_enrollment.dart` | Freezed model |
| `lib/features/teller/data/teller_service.dart` | Supabase + edge function calls |
| `lib/features/teller/presentation/providers/teller_provider.dart` | Riverpod providers |
| `lib/features/teller/helpers/teller_connect.dart` | JS interop for Teller Connect widget |
| `lib/features/settings/presentation/widgets/settings_editor.dart` | Add connected accounts card |
| `web/index.html` | Add Teller Connect script tag |
| `.env` / `.env.example` | Add `TELLER_APP_ID` |

---

## Acceptance Criteria

- [ ] `teller_enrollments` and `teller_sync_log` tables created with RLS
- [ ] `transactions.source` and `transactions.teller_transaction_id` columns added
- [ ] `teller-enroll` edge function stores token, fetches account details, triggers initial 90-day sync
- [ ] `teller-sync` deduplicates by `teller_transaction_id`, imports with `source='teller'`, `category='Uncategorized'`
- [ ] Income credits on depository accounts set `category='Income'`, `subcategory='Other Income'`
- [ ] `teller-disconnect` marks enrollment inactive and notifies Teller
- [ ] pg_cron job runs every 6 hours
- [ ] Flutter Settings screen shows connected accounts list
- [ ] "Connect Account" launches Teller Connect widget
- [ ] "Sync Now" triggers sync and shows imported count in snackbar
- [ ] "Disconnect" shows confirmation and removes account
- [ ] Access token never appears in any Flutter-readable query response
- [ ] `flutter analyze` — zero issues
- [ ] `build_runner` runs clean

---

## Key Rules

- `TELLER_CERT`, `TELLER_KEY`, `TELLER_ENV` live only in Supabase Edge Function secrets — never in `.env`
- `TELLER_APP_ID` is safe for client — goes in `.env`
- All Teller HTTP calls use mTLS (`Deno.createHttpClient` with cert + key)
- Always use `abs()` on Teller amounts — sign convention varies by account type
- `teller_transaction_id` unique constraint is the only dedup mechanism — never delete synced transactions
- Edge Function imports: use `https://esm.sh/` not `jsr:`
- JWT verification disabled on all functions — verify manually via `supabase.auth.getUser()`
