# Dashboard Spec — TASK-012

---

## Overview

High-level financial overview screen. On mobile = the Home tab. On desktop = the Dashboard tab.

Displays summary tiles, a monthly bar chart, a category breakdown, and recent transactions. Desktop adds a year filter, a donut chart, and a full category totals table.

---

## Providers

File: `lib/features/dashboard/presentation/providers/dashboard_provider.dart`

```dart
@riverpod
Future<String?> dashboardOrgId(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser!.id;
  final row = await client
      .from('org_members')
      .select('org_id')
      .eq('profile_id', userId)
      .single();
  return row['org_id'] as String?;
}

@riverpod
Future<DashboardSummary> dashboardSummary(
  Ref ref,
  String orgId,
  int year,
) async {
  // Fetch all transactions for the year
  final allYear = await ref.watch(
    transactionsProvider(orgId, filter: TransactionFilter(year: year)).future,
  );

  // Compute year totals
  final yearSummary = calculateTransactionSummary(allYear);

  // Compute current month totals
  final now = DateTime.now();
  final monthTxns = allYear.where((t) =>
      t.date.year == year && t.date.month == now.month).toList();
  final monthSummary = calculateTransactionSummary(monthTxns);

  // Build monthly breakdown (12 entries)
  final monthlyTotals = List.generate(12, (i) {
    final m = i + 1;
    final txns = allYear.where((t) => t.date.month == m).toList();
    final s = calculateTransactionSummary(txns);
    return (month: m, income: s.income, expenses: s.expenses);
  });

  // Build category expense totals for selected year
  final categoryTotals = <String, double>{};
  for (final t in allYear) {
    if (!isIncome(t.category)) {
      categoryTotals[t.category] =
          (categoryTotals[t.category] ?? 0) + t.amount;
    }
  }

  return DashboardSummary(
    yearIncome: yearSummary.income,
    yearExpenses: yearSummary.expenses,
    yearNet: yearSummary.net,
    yearBusiness: yearSummary.businessTotal,
    monthIncome: monthSummary.income,
    monthExpenses: monthSummary.expenses,
    monthNet: monthSummary.net,
    monthBusiness: monthSummary.businessTotal,
    monthlyTotals: monthlyTotals,
    categoryTotals: categoryTotals,
  );
}
```

`DashboardSummary` is a plain Dart class (not Freezed):

```dart
class DashboardSummary {
  const DashboardSummary({
    required this.yearIncome,
    required this.yearExpenses,
    required this.yearNet,
    required this.yearBusiness,
    required this.monthIncome,
    required this.monthExpenses,
    required this.monthNet,
    required this.monthBusiness,
    required this.monthlyTotals,
    required this.categoryTotals,
  });

  final double yearIncome;
  final double yearExpenses;
  final double yearNet;
  final double yearBusiness;
  final double monthIncome;
  final double monthExpenses;
  final double monthNet;
  final double monthBusiness;
  final List<({int month, double income, double expenses})> monthlyTotals;
  final Map<String, double> categoryTotals;
}
```

Run `build_runner` after.

---

## Layout Router

File: `lib/features/dashboard/dashboard_screen.dart`

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const DashboardMobileScreen()
        : const DashboardWebScreen();
  }
}
```

Wire into `app_router.dart`:
- `/` (mobile shell home tab) → `DashboardScreen`
- `/dashboard` (desktop shell) → `DashboardScreen`

---

## Mobile Layout

File: `lib/features/dashboard/layouts/mobile/dashboard_mobile_screen.dart`

### Header

```
Dashboard — March 2026
```

Format: `"Dashboard — ${MonthName} ${year}"` using current date.

---

### Summary Tiles

2×2 grid of summary tiles. All show **current month** values formatted as `$X,XXX.XX`.

| Tile | Left border color | Value text color |
|---|---|---|
| Income | `AppColors.green` | `AppColors.green` |
| Expenses | `AppColors.teal` | `AppColors.red` |
| Net | `AppColors.amber` | green if ≥ 0, red if < 0 |
| Business | `Color(0xFF7D3C98)` | `AppColors.textMuted` |

Each tile: label (12px muted) above value (18px bold).

---

### Monthly Bar Chart

Title: `"Income vs Expenses — [Year]"`

`fl_chart BarChart` with:
- 12 grouped bars, one per month (Jan–Dec)
- Each group: income bar (green) + expenses bar (red) side by side
- X axis: single-letter month abbreviations — J F M A M J J A S O N D
- Y axis: dollar amounts, auto-scaled from data
- Handle empty list gracefully — render 12 zero-height bars, no crash

---

### "This Month by Category" Card

Title row: `"This Month by Category"` with current month label right-aligned.

For each expense category that has at least one transaction this month:

- Row: category name | actual `$X` | budget `$Y` | progress bar
- Budget comes from `budgetDefaultsProvider(orgId)` — match by category
- Progress bar color thresholds:
  - actual < 80% of budget → `AppColors.green`
  - 80% ≤ actual < 100% → `AppColors.amber`
  - actual ≥ 100% → `AppColors.red`
- If no budget default exists for that category: show actual amount only, no progress bar
- Tapping a category row → `GoRouter.of(context).go('/monthly')`

Capture `GoRouter` before any `await`.

---

### "Recent Transactions" Card

Title: `"Recent Transactions"` with `"See all →"` link right-aligned (navigates to `/transactions`).

Last 5 transactions from `transactionsProvider`, sorted date DESC.

Each row:
- Left: merchant name (bold, 14px) + category/subcategory below (12px muted)
- Right: amount right-aligned, bold — red for expense, green for income; date below (12px muted)

---

### Empty State

Shown when `transactionsProvider` returns an empty list:

```
[Icons.bar_chart]
No transactions yet
Add your first transaction to see your dashboard
```

---

## Desktop Layout

File: `lib/features/dashboard/layouts/web/dashboard_web_screen.dart`

### Toolbar Row

- Left: `"Dashboard"` page title (`AppTextStyles.pageTitle`)
- Right: Year dropdown — current year ± 2 years, defaults to current year. Changing the year re-watches `dashboardSummaryProvider(orgId, selectedYear)`.

---

### Summary Stat Cards

4 cards in a single row. Each card shows:
- Year-to-date total for the selected year (large, bold)
- Subtitle: `"This month: $X"` (12px muted, current month value)

Same tile labels and value colors as mobile. Amounts formatted as `$X,XXX.XX`.

---

### 2-Column Chart Grid

**Left — Bar Chart:**
Same as mobile bar chart but wider. Title: `"Income vs Expenses — [Year]"`.

**Right — Donut Chart:**
`fl_chart PieChart` (hole in center).

- Each slice = one expense category for selected year
- Slice size = category total / year expenses
- Label: category name + percentage (e.g. `"Groceries 18%"`)
- Color palette (cycle in order for as many categories as exist):
  `AppColors.teal`, `AppColors.green`, `AppColors.amber`, `AppColors.navy`, `Color(0xFF7D3C98)`, `AppColors.red`, `AppColors.lightGray`
- Handle empty `categoryTotals` gracefully — show a single gray placeholder slice

---

### Category Totals Table

Sticky navy header. Alternating white/`AppColors.lightGray` rows.

| Category | Actual ($) | Budget/mo ($) | Business ($) | Biz% |
|---|---|---|---|---|

- **Actual** — sum of all transactions in that category for selected year (from `dashboardSummary.categoryTotals`)
- **Budget/mo** — from `budgetDefaultsProvider(orgId)`, global default for that category; show `"—"` if not set
- **Business $** — sum of `calculateBusinessAmount(t.amount, t.bizPct)` for all transactions in that category
- **Biz%** — business / actual × 100, shown as `"XX%"`; show `"—"` if actual is 0
- Footer row: bold totals across all numeric columns
- Empty state (no transactions for selected year): centered message `"No transactions for [Year]"`

---

## File Map

| File | What |
|---|---|
| `lib/features/dashboard/presentation/providers/dashboard_provider.dart` | Riverpod providers + `DashboardSummary` class |
| `lib/features/dashboard/dashboard_screen.dart` | Layout router |
| `lib/features/dashboard/layouts/mobile/dashboard_mobile_screen.dart` | Mobile layout |
| `lib/features/dashboard/layouts/web/dashboard_web_screen.dart` | Desktop layout |
| `pubspec.yaml` | Add `fl_chart: ^0.69.0` |
| `lib/core/routing/app_router.dart` | Wire `/` and `/dashboard` to `DashboardScreen` |

---

## Key Rules

- `build_runner` after any `@riverpod` changes
- Org scope on every Supabase query — pass `orgId` down from `dashboardOrgIdProvider`
- Capture `GoRouter` before any `await` in callbacks
- `fl_chart` data must handle empty lists gracefully — never crash on zero transactions
- All dollar amounts formatted with `NumberFormat.currency(locale: 'en_US', symbol: '\$')`
- Use `calculateTransactionSummary` and `isIncome` from `lib/features/transactions/helpers/transaction_calculations.dart`
- Use `calculateBusinessAmount` from the same helpers file
- IRS mileage rate comes from `appSettingsProvider(orgId)` — fallback to `0.670` if null
- All amounts stored as positive — use `isIncome(category)` to distinguish income from expenses
- `DashboardSummary` is a plain Dart class, not Freezed — no `build_runner` needed for it

---

## Acceptance Criteria

- [ ] `fl_chart: ^0.69.0` added to `pubspec.yaml` and `flutter pub get` runs clean
- [ ] Summary tiles show correct current-month totals on mobile
- [ ] Summary stat cards show correct year-to-date totals on desktop
- [ ] "This month" subtitle on desktop stat cards is correct
- [ ] Bar chart renders 12 months of income vs expenses for selected year
- [ ] Donut chart renders expense breakdown by category for selected year
- [ ] Category totals table shows correct actuals, budgets, business columns, and footer totals
- [ ] Year dropdown on desktop changes all chart and table data
- [ ] Category progress bars use correct color thresholds (green / amber / red)
- [ ] Categories with no budget default show actual only, no progress bar
- [ ] Recent transactions card shows last 5, sorted date DESC
- [ ] "See all →" navigates to `/transactions`
- [ ] Tapping a category row navigates to `/monthly`
- [ ] Empty state renders when no transactions exist
- [ ] Desktop empty state shows `"No transactions for [Year]"` when year has no data
- [ ] `build_runner` runs clean after provider changes
- [ ] `flutter analyze` — zero issues
