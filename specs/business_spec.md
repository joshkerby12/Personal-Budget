# Business Spec — TASK-014

---

## TASK-014 · Business Summary Screen

**Purpose:** Tax-focused view of all deductible business expenses + mileage deduction. Helps the user see their total deductions at a glance for any month or year. This is the "Business" tab on desktop and in the More sheet on mobile.

---

### Providers

File: `lib/features/business/presentation/providers/business_provider.dart`

```dart
@riverpod
Future<String?> businessOrgId(Ref ref) async {
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
Future<BusinessSummaryData> businessSummary(
  Ref ref,
  String orgId, {
  int? year,
  int? month,
}) async {
  // fetch transactions filtered by year/month, exclude income category
  // fetch mileage trips for the org (filter by date in Dart if year/month set)
  // fetch app settings for IRS rate
  // compute all summary fields
  // return BusinessSummaryData
}
```

`BusinessSummaryData` is a plain Dart class (NOT Freezed) with:
- `totalExpenses` — sum of all expense transaction amounts
- `totalBusinessExpenses` — sum of `calculateBusinessAmount(t.amount, t.bizPct)` for all expense transactions
- `businessExpensePct` — `totalBusinessExpenses / totalExpenses × 100` (0 if no expenses)
- `mileageDeductibleMiles` — sum of `deductibleMiles(totalMiles(t), t.bizPct)` across all trips
- `mileageDeductionValue` — sum of `deductibleValue(dedMiles, irsRate)` across all trips
- `irsRate` — from `AppSettings`, fallback to `fallbackIrsRatePerMile` (0.670)
- `combinedDeductions` — `totalBusinessExpenses + mileageDeductionValue`
- `byCategory` — `List<BusinessCategoryRow>` sorted by business $ descending

`BusinessCategoryRow` is a plain Dart class (NOT Freezed) with:
- `category` (String)
- `totalExpenses` (double) — raw expense total for this category
- `businessAmount` (double) — business portion
- `pctOfTotalBusiness` (double) — this category's business $ / totalBusinessExpenses × 100

**Transaction filtering:** pass `TransactionFilter(year: year, month: month)` to `transactionsProvider`. Exclude any transaction where `isIncome(t.category)` is true.

**Mileage trips filtering:** fetch all org trips via `mileageTripsProvider(orgId)`, then filter in Dart: `trip.date.year == year` and, if month is set, `trip.date.month == month`.

**IRS rate:** read from `appSettingsProvider(orgId)` — use `settings?.irsRatePerMile ?? fallbackIrsRatePerMile`.

Run `build_runner` after.

---

### Layout Router

File: `lib/features/business/business_screen.dart`

```dart
class BusinessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < AppConstants.mobileBreakpoint;
    return isMobile
        ? const BusinessMobileScreen()
        : const BusinessWebScreen();
  }
}
```

Wire into `app_router.dart` for the `/business` route.

---

### Shared Filter Bar

Both layouts show a filter bar at the top. Implement as a shared widget.

File: `lib/features/business/presentation/widgets/business_filter_bar.dart`

- **Year dropdown:** current year − 2 through current year + 2, plus an "All Time" option
- **Month dropdown:** "All Months" | Jan–Dec (January = 1 … December = 12)
- When "All Time" is selected: month dropdown is disabled and resets to "All Months"
- When a year is selected: month dropdown is enabled

---

### Desktop Layout

File: `lib/features/business/layouts/web/business_web_screen.dart`

Filter bar at top. Max content width 900px, centered. Then:

**4 summary stat cards** in a single row:

| Card | Value | Color accent |
|---|---|---|
| Business Expenses | `$X,XXX.XX` | teal left border |
| Mileage Deduction | `$X,XXX.XX` | green left border |
| Combined Deductions | `$X,XXX.XX` | navy left border, bold value |
| Business % of Total | `XX.X%` | amber left border |

**Mileage detail block** (below summary cards, `tealLight` background card):

```
Total Trips: N  |  Total Miles: X.X  |  Deductible Miles: X.X  |  IRS Rate: $X.XXX/mi  |  Total Deduction: $X,XXX.XX
```

Single row, horizontally scrollable if needed. Labels in muted text, values in bold.

**Business Expenses by Category table** (below mileage block):

Sticky navy header row. Alternating white/lightGray rows.

| Category | Business ($) | % of Business Total |
|---|---|---|

- Sorted descending by Business ($)
- Footer row: "Total" | `$X,XXX.XX` | `100%` — bold
- Empty state: centered text "No business expenses for this period"

---

### Mobile Layout

File: `lib/features/business/layouts/mobile/business_mobile_screen.dart`

Filter bar at top. Then all content as stacked cards scrolling vertically.

**1. Summary cards** — 2×2 grid using the same tile style as Dashboard (card with colored left border):
- Business Expenses (teal)
- Mileage Deduction (green)
- Combined Deductions (navy, bold value)
- Business % of Total (amber)

**2. Mileage Summary card** — titled "Mileage Deduction". All 5 fields stacked as label: value rows:
- Total Trips
- Total Miles
- Deductible Miles
- IRS Rate
- Total Deduction

**3. Business by Category card** — titled "By Category". List of rows, one per `BusinessCategoryRow`:
- Category name (bold, left-aligned)
- Business $ right-aligned on the same row
- "X.X% of business" below in 12px muted text

**Empty state** (shown when `byCategory` is empty and mileage totals are zero):
```
[icon: Icons.business_center_outlined]
No business activity for this period
```

---

### File Map

| File | What |
|---|---|
| `lib/features/business/presentation/providers/business_provider.dart` | Providers + data classes |
| `lib/features/business/presentation/widgets/business_filter_bar.dart` | Shared year/month filter bar |
| `lib/features/business/business_screen.dart` | Layout router |
| `lib/features/business/layouts/web/business_web_screen.dart` | Desktop layout |
| `lib/features/business/layouts/mobile/business_mobile_screen.dart` | Mobile layout |
| `lib/core/routing/app_router.dart` | Wire `/business` to `BusinessScreen` |

---

### Acceptance Criteria

- [ ] Filter bar: year + month dropdowns work, month disabled when "All Time" selected
- [ ] Summary cards show correct computed values
- [ ] Mileage block shows correct trip count, total miles, deductible miles, IRS rate, and total deduction
- [ ] IRS rate pulled from `AppSettings` — fallback to `fallbackIrsRatePerMile` (0.670)
- [ ] Category table sorted descending by business $
- [ ] `pctOfTotalBusiness` calculated correctly — 0% when no business expenses
- [ ] `combinedDeductions` = business expenses + mileage deduction
- [ ] Mobile cards match desktop data
- [ ] Empty state shows when no data for selected period
- [ ] `flutter analyze` — zero issues
- [ ] `build_runner` runs clean

---

### Key Rules

- `build_runner` after any `@riverpod` changes
- Org scope on every Supabase query — never query without `orgId`
- `bizPct` stored as 0.0–1.0 — display as percentage by multiplying × 100
- Exclude income transactions (`isIncome(category)`) from all business expense calculations
- IRS rate: always prefer `appSettings?.irsRatePerMile`, fallback to `fallbackIrsRatePerMile` (0.670) from `mileage_calculations.dart`
- Dollar amounts formatted as `$X,XXX.XX` using `NumberFormat.currency`
- `BusinessSummaryData` and `BusinessCategoryRow` are plain Dart classes — do NOT use `@freezed`
- Capture `ScaffoldMessenger` before any `await`
