# Monthly Budget View Spec — TASK-013

---

## Overview

Per-month budget tracking screen. Shows budget vs actual for every category/subcategory. Supports per-month budget overrides on top of global defaults. This is the "Monthly" tab on desktop and bottom nav on mobile.

---

## Budget Logic

Budget for a given month/category/subcategory is resolved in this order:

1. Look for a `BudgetDefault` where `org_id = orgId AND category = c AND subcategory = s AND month = DateTime(year, m, 1)`
2. If not found, fall back to global default: `month IS NULL`
3. If neither found, budget = 0 — show "—" in UI, hide progress bar

A month has "custom budgets" if any `BudgetDefault` rows exist with `month = DateTime(year, m, 1)`.

Per-month `BudgetDefault.month` is always `DateTime(year, month, 1)` — first of month, midnight UTC.

---

## Providers

File: `lib/features/monthly/presentation/providers/monthly_provider.dart`

```dart
@riverpod
Future<String?> monthlyOrgId(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return null;
  final row = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .single();
  return row['org_id'] as String?;
}

@riverpod
Future<MonthlyBudgetData> monthlyBudgetData(
  Ref ref,
  String orgId,
  int year,
  int month,
) async {
  // fetch transactions for year+month
  // fetch global budget defaults (month IS NULL)
  // fetch per-month overrides for DateTime(year, month, 1)
  // compute actuals per category/subcategory
  // resolve effective budget: override > global > 0
  // return MonthlyBudgetData
}

@riverpod
class MonthlyController extends _$MonthlyController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveMonthBudgets(
    String orgId,
    int year,
    int month,
    List<BudgetDefault> budgets,
  ) async { ... }

  Future<void> clearMonthOverrides(
    String orgId,
    int year,
    int month,
  ) async { ... }
}
```

Run `build_runner` after.

---

### MonthlyBudgetData

Plain Dart class (NOT Freezed).

| Field | Type | Notes |
|---|---|---|
| `year` | `int` | Selected year |
| `month` | `int` | Selected month (1–12) |
| `hasCustomBudgets` | `bool` | True if per-month overrides exist for this month |
| `rows` | `List<MonthlyRow>` | One row per category/subcategory |
| `categorySubtotals` | `Map<String, ({double budget, double actual, double business})>` | Keyed by category name |

---

### MonthlyRow

Plain Dart class (NOT Freezed).

| Field | Type | Notes |
|---|---|---|
| `category` | `String` | Parent category |
| `subcategory` | `String` | Subcategory name |
| `budget` | `double` | Effective budget for this month (0 if unset) |
| `actual` | `double` | Sum of transactions for this category/subcategory |
| `remaining` | `double` | `budget - actual`, can be negative |
| `personal` | `double` | `calculatePersonalAmount(actual, bizPct)` |
| `business` | `double` | `calculateBusinessAmount(actual, bizPct)` |
| `bizPct` | `double` | 0.0–1.0 — weighted average across all transactions for this row |
| `hasCustomBudget` | `bool` | True if this row has a per-month override |

---

## Layout Router

File: `lib/features/monthly/monthly_screen.dart`

```dart
class MonthlyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const MonthlyMobileScreen()
        : const MonthlyWebScreen();
  }
}
```

---

## Month Selector (shared widget)

File: `lib/features/monthly/widgets/month_selector.dart`

Horizontal scrollable row of pill chips: Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

- Active month: `AppColors.teal` background, white text
- Inactive: white background, teal border, teal text
- Always scroll active month into view on build (`ScrollController` + `WidgetsBinding.addPostFrameCallback`)

---

## View Mode UI

### Toolbar row

- Left: "[Month] [Year] Budgets" label (e.g. "March 2026 Budgets"), bold navy
- Badge: "Using default budgets" (gray chip, `AppColors.lightGray` background) OR "✔ Custom budgets set" (teal chip, `AppColors.teal` background, white text) — based on `hasCustomBudgets`
- Right: "✏ Edit Budgets" button (outlined teal) + "✕ Clear Overrides" button (outlined red) — Clear Overrides only shown if `hasCustomBudgets`

### Table — grouped by category

**Category header row** (navy background, white bold text, full width):
- Category name (left, bold) + category subtotal: `Actual $X.XX / Budget $Y.YY` (right)

**Subcategory rows:**

| Subcategory | Budget | Actual | Remaining | Progress | Personal | Business | Biz% |
|---|---|---|---|---|---|---|---|

- Budget: `$X.XX` or `—` if 0
- Actual: `$X.XX`
- Remaining: bold green if ≥ 0, bold red if < 0
- Progress bar: `actual / budget`, capped at 100% visually. Color: `AppColors.green` if actual < 80% of budget, `AppColors.amber` if 80–99%, `AppColors.red` if ≥ 100%. Hidden if `budget = 0`.
- Personal/Business: calculated via `calculatePersonalAmount` / `calculateBusinessAmount`
- Biz%: `XX%` (multiply stored 0.0–1.0 by 100)

**Category subtotal row** (`AppColors.tealLight` background, bold):
- Spans: Category Total | $budget | $actual | $remaining | [progress bar] | $personal | $business | —

### Charts (desktop only — hidden on mobile)

- Horizontal bar chart: budget vs actual per category (`fl_chart` `BarChart`, horizontal orientation)
- Donut chart: business expense breakdown by category (`fl_chart` `PieChart`, center hole)
- Both must handle empty data gracefully (show placeholder text, no chart crash)

### Empty state

"No transactions for [Month] [Year]" — centered, `AppColors.textMuted`, 14px.

---

## Edit Mode UI

Activated by tapping "✏ Edit Budgets".

### Toolbar changes

- Amber pill badge: "✏ EDITING [Month]" (`AppColors.amber` background, white text)
- Amber left border on the entire toolbar card (`AppColors.amber`, 4px)
- Buttons: "📋 Copy Defaults" (outlined gray) | "✕ Cancel" (outlined red) | "💾 Save [Month] Budgets" (filled teal)

### Table changes

- Budget column becomes editable `TextField` (number keyboard, `$` prefix widget, no `$` inside the field itself)
- Rows with an existing per-month override: amber left border (`AppColors.amber`, 3px)
- Rows that have been edited in the current session: `AppColors.amberFill` row background

### Copy Defaults

Fills all budget `TextEditingController` values from the global defaults (does not save — user must tap Save).

### Cancel

Discards all in-progress edits. Returns to View mode. No Supabase calls.

### Save

Calls `MonthlyController.saveMonthBudgets` → shows `SnackBar` "✅ March budgets saved" → returns to View mode → badge updates to "✔ Custom budgets set".

Capture `ScaffoldMessenger` before any `await`.

### Clear Overrides

Shows confirmation `AlertDialog`:
> "Remove custom budgets for [Month]? This will use your default budgets instead."

Confirm → `MonthlyController.clearMonthOverrides` → `SnackBar` "March overrides cleared" → reloads `monthlyBudgetData`.

---

## Mobile Layout

File: `lib/features/monthly/layouts/mobile/monthly_mobile_screen.dart`

- Month selector at top
- Summary row below selector: `Income: $X | Expenses: $X | Net: $X` (12px muted, horizontally scrollable)
- Category groups — collapsible. Tap category header to expand/collapse subcategory rows. Default: all expanded.
- No charts on mobile
- Edit mode: tapping a subcategory row opens a bottom sheet (`showModalBottomSheet`) with a single budget `TextField` for that subcategory. Save from the bottom sheet updates that row's controller value. Full Save/Cancel remains in the toolbar.
- "✏ Edit" button in toolbar (not the global FAB — global FAB stays for adding transactions)

---

## Desktop Layout

File: `lib/features/monthly/layouts/web/monthly_web_screen.dart`

- Month selector at top
- Full table with all columns (see View Mode UI above)
- Charts below table
- Edit mode inline in the table
- Max content width 1100px, centered

---

## File Map

| File | What |
|---|---|
| `lib/features/monthly/presentation/providers/monthly_provider.dart` | Providers + `MonthlyBudgetData` + `MonthlyRow` classes |
| `lib/features/monthly/widgets/month_selector.dart` | Shared month pill selector |
| `lib/features/monthly/monthly_screen.dart` | Layout router |
| `lib/features/monthly/layouts/mobile/monthly_mobile_screen.dart` | Mobile layout |
| `lib/features/monthly/layouts/web/monthly_web_screen.dart` | Desktop layout |
| `lib/core/routing/app_router.dart` | Wire `/monthly` to `MonthlyScreen` |

---

## Key Rules

- `build_runner` after any `@riverpod` changes
- Org scope on every Supabase query — no unscoped selects
- `TextEditingController` for all budget input fields in edit mode — no autoDispose providers for text state
- Capture `ScaffoldMessenger` before any `await`
- `bizPct` stored 0.0–1.0 in DB; display and input as 0–100 in UI — convert on read/write
- Per-month `BudgetDefault.month` is always `DateTime(year, month, 1)` — first of month, midnight UTC
- `fl_chart` must handle empty `List` gracefully — guard before building chart data
- All amounts stored as positive — use `isIncome(category)` to determine income vs expense

---

## Acceptance Criteria

- [ ] Month selector renders all 12 months, active month highlighted and scrolled into view
- [ ] Budget vs actual loads correctly for the selected month
- [ ] Budget resolution order correct: per-month override > global default > 0 (shown as "—")
- [ ] "Custom budgets set" badge shows only when per-month overrides exist for that month
- [ ] Progress bars use correct color thresholds: green < 80%, amber 80–99%, red ≥ 100%
- [ ] Progress bars hidden when budget = 0
- [ ] Category subtotal rows show correct rollups
- [ ] Category header rows show category-level actual / budget summary
- [ ] Edit mode: budget fields are editable `TextField` widgets
- [ ] Copy Defaults fills all budget fields from global defaults without saving
- [ ] Save persists per-month `BudgetDefault` rows to Supabase, scoped to `orgId`
- [ ] Clear Overrides shows confirmation dialog, deletes per-month rows, reverts badge to "Using default budgets"
- [ ] Charts render on desktop; hidden on mobile
- [ ] `fl_chart` handles empty data without crash or exception
- [ ] Mobile: collapsible category groups expand and collapse on tap
- [ ] Mobile: edit mode opens per-subcategory bottom sheet
- [ ] Desktop: edit mode inline in table, amber highlight on edited rows
- [ ] Empty state shown when no transactions exist for the selected month
- [ ] `flutter analyze` — zero issues
- [ ] `build_runner` runs clean
