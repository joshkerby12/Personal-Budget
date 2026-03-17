# Settings Spec — TASK-007

Budget defaults + app settings. Depends on TASK-006 (categories). Provides the data that TASK-008 (transactions) and TASK-009 (mileage) need for biz% defaults and IRS rate.

---

## Overview

Two data models:
1. `AppSettings` — one row per org, stores IRS mileage rate
2. `BudgetDefault` — one row per org/category/subcategory/month, stores monthly budget amount and default biz%

The Settings screen lets the user configure both. On desktop it's the Settings tab; on mobile it's the Settings item in the More sheet.

---

## Data Models

### `AppSettings` (Freezed)

File: `lib/features/settings/models/app_settings.dart`

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required String id,
    required String orgId,
    required double irsRatePerMile,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
```

JSON mapping: `org_id` → `orgId`, `irs_rate_per_mile` → `irsRatePerMile`

---

### `BudgetDefault` (Freezed)

File: `lib/features/settings/models/budget_default.dart`

```dart
@freezed
class BudgetDefault with _$BudgetDefault {
  const factory BudgetDefault({
    required String id,
    required String orgId,
    required String category,
    required String subcategory,
    required double monthlyAmount,
    required double defaultBizPct,  // 0.0–1.0
    DateTime? month,                // null = global default; first-of-month = per-month override
  }) = _BudgetDefault;

  factory BudgetDefault.fromJson(Map<String, dynamic> json) => _$BudgetDefaultFromJson(json);
}
```

JSON mapping: `org_id` → `orgId`, `monthly_amount` → `monthlyAmount`, `default_biz_pct` → `defaultBizPct`

---

## Service

File: `lib/features/settings/data/settings_service.dart`

```dart
class SettingsService {
  const SettingsService(this._client);
  final SupabaseClient _client;

  // AppSettings
  Future<AppSettings?> fetchAppSettings(String orgId) async { ... }
  Future<void> saveAppSettings(AppSettings settings) async { ... }

  // BudgetDefaults
  Future<List<BudgetDefault>> fetchBudgetDefaults(String orgId, {DateTime? month}) async { ... }
  Future<void> saveBudgetDefaults(List<BudgetDefault> defaults) async { ... }
  Future<void> deleteBudgetDefault(String id) async { ... }
  Future<void> clearMonthOverrides(String orgId, DateTime month) async { ... }
}
```

### `fetchAppSettings(orgId)`
- Select from `app_settings` where `org_id = orgId`
- Returns `null` if no row yet (new org)

### `saveAppSettings(settings)`
- Upsert into `app_settings` on conflict `org_id`

### `fetchBudgetDefaults(orgId, {month})`
- If `month` is null: fetch where `org_id = orgId AND month IS NULL` (global defaults)
- If `month` is provided: fetch where `org_id = orgId AND month = firstDayOfMonth`
- Order by `category ASC, subcategory ASC`

### `saveBudgetDefaults(defaults)`
- Upsert all rows on conflict `(org_id, category, subcategory, month)`

### `deleteBudgetDefault(id)`
- Delete by `id`

### `clearMonthOverrides(orgId, month)`
- Delete all rows where `org_id = orgId AND month = firstDayOfMonth`

---

## Providers

File: `lib/features/settings/presentation/providers/settings_provider.dart`

```dart
@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) =>
    SettingsService(ref.watch(supabaseClientProvider));

@riverpod
Future<AppSettings?> appSettings(Ref ref, String orgId) async {
  return ref.read(settingsServiceProvider).fetchAppSettings(orgId);
}

@riverpod
Future<List<BudgetDefault>> budgetDefaults(Ref ref, String orgId) async {
  return ref.read(settingsServiceProvider).fetchBudgetDefaults(orgId);
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveIrsRate(String orgId, double rate) async { ... }
  Future<void> saveBudgets(List<BudgetDefault> defaults) async { ... }
  Future<void> deleteDefault(String id) async { ... }
}
```

Run `build_runner` after creating this file.

---

## Helper: org ID lookup

Both providers need the current org ID. Use this pattern (same as categories):

```dart
Future<String> _getOrgId(SupabaseClient client) async {
  final userId = client.auth.currentUser!.id;
  final row = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .single();
  return row['org_id'] as String;
}
```

---

## Settings Screen UI

### Layout Router

File: `lib/features/settings/settings_screen.dart`

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile ? const SettingsMobileScreen() : const SettingsWebScreen();
  }
}
```

Wire into `app_router.dart` for `/settings` branch (replace `_RoutePlaceholder`).

---

### Shared Structure (both layouts)

**Section 1 — IRS Mileage Rate**

Card with title "Mileage Rate":
- Label: "IRS Rate Per Mile"
- Input: number field, prefixed with `$`, default `0.670`
- Helper text: "Update each January when IRS publishes new rate"
- Save button: "Save Rate" (teal, right-aligned)

**Section 2 — Budget Defaults**

Card with title "Monthly Budget Defaults":
- Toolbar row: "Save All Budgets" button (teal) + "Reset to Defaults" button (ghost/danger)
- Table/list grouped by `parentCategory`:
  - **Category header row:** navy background, white bold text (category name), full width
  - **Subcategory rows:** subcategory name | monthly amount input ($) | default biz% input (0–100) | delete icon

**Inline add subcategory:**
- Below each category group, a small "+ Add subcategory" text button
- Tapping it inserts a new editable row highlighted in `AppColors.greenFill`
- User types name + amount + biz%, then it saves with the rest on "Save All Budgets"

**Inline rename:**
- Tapping a subcategory name makes it editable inline (amber border on the field while editing)

**Reset to Defaults:**
- Shows confirmation `AlertDialog`: "This will reset all global budget defaults. Per-month overrides are not affected. Continue?"
- On confirm: delete all global defaults for org, re-seed from the same default list in `categories_spec.md`, close dialog, reload

---

### Desktop Layout

File: `lib/features/settings/layouts/web/settings_web_screen.dart`

- Max content width: 900px, centered
- Both sections side by side if space allows, otherwise stacked
- Data section at bottom (desktop only):
  - "Export Data" button → exports all budgets + settings as JSON download
  - "Import Data" button → file picker for JSON, parses and upserts
  - Storage usage: text showing `"Receipts storage: X MB used"` (fetch from Supabase Storage API — use `client.storage.getBucket('receipts')` or just show a static placeholder "Available after receipts are uploaded" for now)

---

### Mobile Layout

File: `lib/features/settings/layouts/mobile/settings_mobile_screen.dart`

- Scrollable single-column layout
- IRS rate section first
- Budget defaults below — categories collapsible (tapping category header expands/collapses subcategory list)
- No data export section on mobile

---

## File Map

| File | What |
|---|---|
| `lib/features/settings/models/app_settings.dart` | Freezed model |
| `lib/features/settings/models/budget_default.dart` | Freezed model |
| `lib/features/settings/data/settings_service.dart` | Supabase CRUD |
| `lib/features/settings/presentation/providers/settings_provider.dart` | Riverpod providers |
| `lib/features/settings/layouts/web/settings_web_screen.dart` | Desktop UI |
| `lib/features/settings/layouts/mobile/settings_mobile_screen.dart` | Mobile UI |
| `lib/features/settings/settings_screen.dart` | Layout router |
| `lib/core/routing/app_router.dart` | Replace `/settings` placeholder with `SettingsScreen()` |

---

## Acceptance Criteria

- [ ] `AppSettings` and `BudgetDefault` Freezed models generate cleanly
- [ ] `fetchAppSettings` returns existing row or null for new orgs
- [ ] `saveAppSettings` upserts correctly (no duplicate rows)
- [ ] `fetchBudgetDefaults` returns global defaults when month is null
- [ ] `saveBudgetDefaults` upserts all rows without duplicates
- [ ] Settings screen loads existing IRS rate and budget defaults from Supabase
- [ ] Saving IRS rate persists to `app_settings` table
- [ ] Saving budgets persists to `budgets` table
- [ ] Add subcategory row appears inline, saves with "Save All Budgets"
- [ ] Reset to defaults shows confirmation then re-seeds
- [ ] `flutter analyze` — zero issues
- [ ] `build_runner` runs clean

---

## Key Rules

- `build_runner` after all `@riverpod` and `@freezed` changes
- Org scope on every query — no unscoped reads
- Capture `ScaffoldMessenger` before any `await`
- `defaultBizPct` stored as 0.0–1.0 in DB; UI shows/accepts 0–100 — convert on read/write
- `month` null = global default; always use first-of-month date for per-month overrides
