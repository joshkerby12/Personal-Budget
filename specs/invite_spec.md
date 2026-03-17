# Invite Spec — TASK-016 + TASK-017

Household invite system. Allows the owner to share a join code with a spouse/family member who can then join the existing org instead of creating a new one.

Two tasks:
- **TASK-016** — Schema + backend: add `invite_code` to `organizations`, seed on creation, `InviteService`
- **TASK-017** — UI: fork onboarding into "Create" vs "Join", owner code display in Settings

---

## How It Works

1. When an org is created, a random 6-character alphanumeric code is generated and stored on the `organizations` row (e.g. `KRB4X2`)
2. Owner shares this code with their spouse out-of-band (text, email, etc.)
3. Spouse signs up → reaches onboarding → chooses "Join a household" → enters code → gets added as `member`
4. Owner can view/copy/regenerate the code from the Settings screen

---

## TASK-016 · Schema + Invite Service

### Database Change

Run this SQL in the Supabase SQL editor:

```sql
-- Add invite_code to organizations
alter table organizations
  add column if not exists invite_code text unique;

-- Backfill existing orgs with a random code
update organizations
  set invite_code = upper(substring(replace(gen_random_uuid()::text, '-', ''), 1, 6))
  where invite_code is null;

-- Make it not null going forward
alter table organizations
  alter column invite_code set not null;

-- Allow org members to read their org's invite code (already covered by existing select policy)
-- Allow any authenticated user to look up an org by invite_code (needed for join flow)
create policy "authenticated users can look up org by invite code"
  on organizations for select
  using (auth.uid() is not null);
```

> Note: The new select policy allows any authenticated user to read `organizations` rows. This is acceptable because org names/codes are not sensitive — the join code itself is the access control.

### `OrgService` changes

File: `lib/features/onboarding/data/org_service.dart`

Add to `createOrg` — generate a 6-char code and include it in the insert:

```dart
String _generateInviteCode() {
  const String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusable chars
  final Random random = Random.secure();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}
```

Update the `organizations` insert to include `invite_code`:
```dart
await _supabaseClient
    .from('organizations')
    .insert({'id': orgId, 'name': trimmedName, 'invite_code': _generateInviteCode()});
```

### New `InviteService`

File: `lib/features/onboarding/data/invite_service.dart`

```dart
class InviteService {
  const InviteService(this._client);
  final SupabaseClient _client;

  /// Look up org by invite code. Returns org id + name, or null if not found.
  Future<({String orgId, String orgName})?> findOrgByCode(String code) async {
    final rows = await _client
        .from('organizations')
        .select('id, name')
        .eq('invite_code', code.trim().toUpperCase())
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return (orgId: rows[0]['id'] as String, orgName: rows[0]['name'] as String);
  }

  /// Add current user to an org as member.
  Future<void> joinOrg({required String orgId, required String userId}) async {
    await _client.from('org_members').insert({
      'org_id': orgId,
      'profile_id': userId,
      'role': 'member',
    });
  }

  /// Get the invite code for the current user's org.
  Future<String?> getInviteCode(String orgId) async {
    final row = await _client
        .from('organizations')
        .select('invite_code')
        .eq('id', orgId)
        .single();
    return row['invite_code'] as String?;
  }

  /// Regenerate invite code for org (owner only).
  Future<String> regenerateCode(String orgId) async {
    final String newCode = _generateInviteCode();
    await _client
        .from('organizations')
        .update({'invite_code': newCode})
        .eq('id', orgId);
    return newCode;
  }
}
```

Add `@Riverpod(keepAlive: true) InviteService inviteService(Ref ref)` to `onboarding_provider.dart`.

Run `build_runner` after.

---

## TASK-017 · Onboarding Fork + Settings Code Display

### Onboarding Screen Fork

Replace the current single-step `OnboardingScreen` with a two-option screen:

**Step 1 — Choose path** (shown first):

```
┌─────────────────────────────────┐
│  Kerby Family Budget            │
│  Set up your household          │
├─────────────────────────────────┤
│                                 │
│  [Create a new household]       │  ← teal primary button
│                                 │
│  [Join an existing household]   │  ← ghost button
│                                 │
└─────────────────────────────────┘
```

**Step 2a — Create household** (same as current `OnboardingScreen`):
- Organization Name field
- "Create Household" button
- Back link

**Step 2b — Join household**:
- "Enter your invite code" label
- Single text field — 6 chars, auto-uppercase, monospace font
- "Join Household" button (teal)
- Back link
- On submit: call `InviteService.findOrgByCode` → if found, show org name with confirm "Join [Org Name]?" → call `InviteService.joinOrg` → `clearOrgCache()` + `router.refresh()`
- If code not found: show error "No household found with that code. Check the code and try again."

Both steps can be implemented as separate widgets within `onboarding_screen.dart` or as separate files — Codex's choice.

### Settings Screen Addition

In the Settings screen (both mobile and desktop), add an **"Invite" section** above the IRS rate section:

```
┌─────────────────────────────────┐
│  Household Invite Code          │
│                                 │
│  KRB4X2   [Copy]  [Regenerate] │
│                                 │
│  Share this code with family    │
│  members so they can join.      │
└─────────────────────────────────┘
```

- Load code via `InviteService.getInviteCode(orgId)`
- "Copy" button copies to clipboard (`Clipboard.setData`)
- "Regenerate" button shows confirm dialog "Generate a new code? The old code will stop working." → calls `InviteService.regenerateCode` → updates displayed code
- Only show Regenerate to owners (check `org_members.role == 'owner'` for current user)

---

## File Map

### TASK-016
| File | What |
|---|---|
| Supabase SQL editor | Add `invite_code` column + policy |
| `lib/features/onboarding/data/org_service.dart` | Add `_generateInviteCode()`, include in insert |
| `lib/features/onboarding/data/invite_service.dart` | New service |
| `lib/features/onboarding/presentation/providers/onboarding_provider.dart` | Add `inviteServiceProvider` |

### TASK-017
| File | What |
|---|---|
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Fork into choose/create/join flow |
| `lib/features/settings/layouts/web/settings_web_screen.dart` | Add invite code section |
| `lib/features/settings/layouts/mobile/settings_mobile_screen.dart` | Add invite code section |

---

## Acceptance Criteria

### TASK-016
- [ ] `invite_code` column exists on `organizations` table, not null, unique
- [ ] Existing orgs have been backfilled with a code
- [ ] New org creation includes a generated invite code
- [ ] `InviteService.findOrgByCode` returns org info for a valid code, null for invalid
- [ ] `InviteService.joinOrg` inserts `org_members` row as `member`
- [ ] `build_runner` runs clean, `flutter analyze` zero issues

### TASK-017
- [ ] Onboarding shows "Create" vs "Join" choice on first load
- [ ] Create flow works as before
- [ ] Join flow: valid code → shows org name → confirms → joins → redirects to dashboard
- [ ] Join flow: invalid code → shows clear error message
- [ ] Settings shows invite code, Copy works, Regenerate works with confirmation
- [ ] Regenerate only visible to org owners
- [ ] `flutter analyze` zero issues

---

## Key Rules

- `build_runner` after any `@riverpod` changes
- Capture `GoRouter`/`ScaffoldMessenger` before any `await`
- Call `ref.read(routerNotifierProvider).clearOrgCache()` before `router.refresh()` in join flow
- Code display: always uppercase, monospace font (`FontFeature` or just a fixed-width style)
- No email sending — code is shared manually by the owner
