# Tasks

Active task queue. Claude authors and scopes all tasks. Codex picks up `ready` tasks and implements them.

---

## Status Rules — Non-Negotiable

### Codex must:
1. When you **start** a task → change status from `ready` to `in-progress`
2. When you **finish** a task → change status from `in-progress` to `ready-to-review`. Never mark `done` yourself.
3. When you are **blocked** → change status to `blocked`, log in `docs/errors.md`, stop immediately

### Claude must:
1. When reviewing a `ready-to-review` task → test acceptance criteria, then either:
   - Mark `done` and move it to the **Completed Tasks** table (summary line only)
   - Or send back to Codex with specific feedback and revert status to `in-progress`
2. When a task is marked `done` → check if the next dependent task can now be unblocked (change from `blocked` to `ready`)
3. Never leave a `ready-to-review` task sitting — review it before writing new tasks

---

## Status Key

| Status | Meaning |
|---|---|
| `ready` | Scoped by Claude, ready for Codex to pick up |
| `in-progress` | Codex is actively working on it |
| `ready-to-review` | Codex finished — Claude or director must review |
| `review-escalation` | Codex flagged a decision that needs Claude or director input |
| `done` | Confirmed working — moved to Completed Tasks table |
| `blocked` | Codex hit a problem — see `docs/errors.md` |

---

## Active Tasks

---

### TASK-022 · Missing miles panel on Monthly Budget View
- **Status:** ready-to-review
- **Depends on:** TASK-013
- **What to build:**
  On the desktop Monthly Budget View, show a collapsible panel (similar to the uncategorized panel) that flags Business and Healthcare transactions that are missing mileage data. Users can log miles inline or mark a transaction as "No Miles" to dismiss it.

  **Database migration** — create `supabase/migrations/20260326000000_add_no_miles_to_transactions.sql`:
  ```sql
  alter table transactions add column if not exists no_miles boolean not null default false;
  ```
  Run this in the Supabase dashboard SQL editor.

  **`lib/features/transactions/models/transaction.dart`** — add field:
  ```dart
  @JsonKey(name: 'no_miles') @Default(false) bool noMiles,
  ```
  Place it after `notes`. Re-run `build_runner` after this change.

  **`lib/features/transactions/data/transaction_service.dart`** — add `'no_miles': transaction.noMiles` to both `insertTransaction` and `updateTransaction` maps.

  **`lib/features/monthly/widgets/monthly_budget_view.dart`:**

  1. Add state field: `bool _isMissingMilesExpanded = true;`

  2. Add helper `_filterMissingMilesTransactions(MonthlyBudgetData data)`:
     - Returns transactions where `category == 'Business' || category == 'Healthcare'`
     - AND `noMiles == false`
     - Filter client-side from `data.transactions`

  3. Add `_buildMissingMilesPanel(BuildContext context, { required String orgId, required MonthlyBudgetData data, required List<Transaction> transactions })`:
     - Returns `SizedBox.shrink()` if transactions is empty
     - Same card/header pattern as `_buildUncategorizedPanel` (amber background `Color(0xFFFFF7E6)` → use `AppColors.amberFill` instead to visually distinguish)
     - Header: "Missing Miles (N)" with chevron toggle
     - Navy header row: Date | Merchant | Category | Amount | Miles
     - Per row (alternating white/lightGray):
       - Date, Merchant, Category/Subcategory, Amount (right-aligned)
       - Miles column: a small `TextFormField` (width ~80px) for miles input + a round-trip checkbox icon toggle, and a green `IconButton(Icons.directions_car)` to save the trip, OR a grey `TextButton('No Miles')` that marks the transaction
       - Tapping elsewhere on the row opens `showTransactionForm`
     - Use a `Map<String, TextEditingController> _milesControllers` and `Map<String, bool> _roundTripStates` keyed by transaction ID for the inline inputs — initialize lazily in the build method
     - On the car icon tap:
       1. Parse miles from controller; if <= 0, show snackbar "Enter miles first"
       2. Create a `MileageTrip` (same logic as transaction_form.dart: merchant as purpose, transaction date, bizPct, isRoundTrip from toggle, category = `'Business - Other'` or `'Healthcare'`)
       3. Call `ref.read(mileageControllerProvider.notifier).saveTrip(trip)`
       4. Call `ref.read(transactionControllerProvider.notifier).save(transaction.copyWith(noMiles: false), isEdit: true)` — noMiles stays false, trip is created
       5. Invalidate `monthlyBudgetDataProvider`
     - On "No Miles" tap:
       1. Call `ref.read(transactionControllerProvider.notifier).save(transaction.copyWith(noMiles: true), isEdit: true)`
       2. Invalidate `monthlyBudgetDataProvider`

  4. In `_buildScaffold`, call `_buildMissingMilesPanel` between the uncategorized panel and `_buildDesktopTable` (desktop only). Add spacer if panel is non-empty.

  5. In `_handleMonthChange` (or wherever `_isUncategorizedExpanded` is reset to true), also reset `_isMissingMilesExpanded = true`.

  **Do NOT:**
  - Touch mobile layout
  - Add a new provider or network call — use `data.transactions` and existing controllers
  - Modify `monthly_provider.dart`

  **Run `build_runner` after the model change:**
  ```
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- **When done:** Change status to `ready-to-review`

---

### TASK-019 · Monthly subcategory transaction drill-down
- **Status:** ready-to-review
- **Depends on:** TASK-013
- **What to build:**
  On the desktop Monthly Budget View, each subcategory row should be expandable to show the individual transactions that make up its actual spend. Default state is collapsed.

  **Behaviour:**
  - Add a small chevron/arrow to the left of the subcategory name (inside the `flex: 3` cell, to the right of the edit pencil icon)
  - Tapping the chevron expands an inline transaction list beneath the row (not a separate page or sheet)
  - Expanded state shows each transaction as a sub-row with: Date | Merchant | Amount | Biz%
  - Rows are read-only in this view — tapping a transaction row opens the existing `showTransactionForm` edit sheet
  - Only one subcategory can be expanded at a time per category group (expanding another collapses the previous), OR allow multiple open — your call, keep it simple
  - The expanded rows should be visually indented / slightly different background so they read as children of the subcategory row
  - The transaction data is already loaded in `monthlyBudgetData` — use the `transactions` list that is currently only used to compute `actualByKey`. You will need to expose it from `MonthlyBudgetData` so the widget can access it.

  **Files to modify:**
  - `lib/features/monthly/presentation/providers/monthly_provider.dart` — add `transactions` field to `MonthlyBudgetData`, expose the raw transaction list
  - `lib/features/monthly/widgets/monthly_budget_view.dart` — add expand/collapse state notifier, chevron icon, and transaction sub-rows in `_buildSectionTable`

  **Do NOT:**
  - Add a new provider or network call — transactions are already fetched
  - Touch mobile layout
  - Run `build_runner` (no `@riverpod` or `@freezed` changes needed)

- **When done:** Change status to `ready-to-review`

---

### TASK-020 · Monthly uncategorized transactions panel
- **Status:** ready
- **Depends on:** TASK-019
- **What to build:**
  On the desktop Monthly Budget View, show a collapsible panel between the charts section and the budget table. The panel lists all transactions for the current month that landed in `Other / Uncategorized` (i.e. their original `category`/`subcategory` did not match any known budget row).

  **Behaviour:**
  - Panel is expanded by default when there are uncategorized transactions; hidden entirely when there are none
  - Header row: "Uncategorized Transactions (N)" with a chevron toggle to collapse/expand
  - Each row shows: Date | Merchant | Original Category / Subcategory | Amount
  - Tapping a row opens the existing `showTransactionForm` edit sheet so the user can re-categorize
  - After saving the form, the monthly data invalidates and the transaction disappears from this list if it now matches a known subcategory

  **Data:**
  - `MonthlyBudgetData` already has a `transactions` list (added in TASK-019). Filter it client-side: keep transactions whose `category + subcategory` key does NOT appear in any non-Uncategorized `MonthlyRow`. Do NOT add a new provider or network call.
  - The catch-all key is `Other\x00Uncategorized` (built by `_budgetKey('Other', 'Uncategorized')` in the provider)

  **Files to modify:**
  - `lib/features/monthly/widgets/monthly_budget_view.dart` — add `_isUncategorizedExpanded` bool state (default true), add `_buildUncategorizedPanel` method, call it between the charts widget and `_buildDesktopTable`

  **Do NOT:**
  - Add a new provider or network call
  - Touch mobile layout
  - Run `build_runner`

- **When done:** Change status to `ready-to-review`

---

### TASK-021 · Auto-categorization suggestions for uncategorized transactions
- **Status:** ready-to-review
- **Depends on:** TASK-020
- **What to build:**
  When the uncategorized panel (TASK-020) displays a Teller-synced transaction, automatically suggest a category/subcategory based on merchant history from past transactions. The user must confirm the suggestion before it is saved.

  **How suggestions work:**
  1. For each uncategorized transaction, normalize its merchant string: uppercase, strip all digits and punctuation, split on whitespace, take the first 4 tokens, rejoin as a prefix (e.g. `"CHEROKEE METRO CO UTIL 719-597-5080"` → `"CHEROKEE METRO CO UTIL"`).
  2. Fetch the last 90 days of categorized transactions from Supabase (category != 'Uncategorized'). This is a one-time fetch when the uncategorized panel loads — add a new `@riverpod` provider `recentCategorizedTransactionsProvider(orgId)` that queries `transactions` with `date >= now - 90 days AND category != 'Uncategorized'`. This is the only allowed new provider/query.
  3. For each history transaction, apply the same normalization to its merchant. If the normalized prefix matches the uncategorized transaction's prefix, count a vote for that `category/subcategory` pair.
  4. The suggestion is the `category/subcategory` pair with the highest vote count. If there are no votes, show no suggestion.

  **UI changes to the uncategorized panel row (built in TASK-020):**
  - If a suggestion exists: show it inline as a muted label `"Suggested: Housing / Utilities - Water"` with a green checkmark `IconButton` to confirm
  - Tapping the checkmark calls `TransactionController.save(transaction.copyWith(category: suggestion.category, subcategory: suggestion.subcategory), isEdit: true)` then invalidates `monthlyBudgetDataProvider`
  - If no suggestion: row looks the same as TASK-020 (tap to open edit form)
  - Tapping anywhere else on the row (not the checkmark) still opens `showTransactionForm` for manual categorization

  **Normalization helper — add as a top-level function in `monthly_budget_view.dart`:**
  ```dart
  String _normalizeMerchant(String merchant) {
    final String upper = merchant.toUpperCase();
    final String stripped = upper.replaceAll(RegExp(r'[^A-Z ]'), '');
    final List<String> tokens = stripped.split(' ').where((t) => t.isNotEmpty).toList();
    return tokens.take(4).join(' ');
  }
  ```

  **Files to modify:**
  - `lib/features/transactions/presentation/providers/transaction_provider.dart` — add `recentCategorizedTransactionsProvider(orgId)` fetching last 90 days of non-Uncategorized transactions
  - `lib/features/transactions/presentation/providers/transaction_provider.g.dart` — run `build_runner` after adding the provider
  - `lib/features/monthly/widgets/monthly_budget_view.dart` — watch `recentCategorizedTransactionsProvider`, add `_normalizeMerchant`, add `_buildSuggestion(Transaction t, List<Transaction> history)` helper returning `({String category, String subcategory})?`, update the uncategorized panel row UI

  **Do NOT:**
  - Touch mobile layout
  - Show suggestions for manually-entered transactions (only show for transactions where `category == 'Uncategorized' && subcategory == 'Uncategorized'`)

- **Review feedback (sent back from ready-to-review):** The initial implementation scanned only `data.transactions` (current month). This is insufficient — most months will have no categorized history to match against. Rework the data source as specified above: add `recentCategorizedTransactionsProvider(orgId)` fetching the last 90 days of non-Uncategorized transactions, and use that as the matching corpus instead.

- **When done:** Change status to `ready-to-review`

---

## Phase 1 · Build (TASK-005 → TASK-009)

Work through these in order. When you finish one task, immediately pick up the next one in this phase without waiting — unless the next task says it needs Claude's spec first. After TASK-009 is marked `ready-to-review`, **stop and wait for Claude to review all of Phase 1 before starting anything in Phase 2.**

TASK-009 (Mileage) only depends on TASK-005 — it can be picked up any time after TASK-005 is done, in parallel with TASK-006/007/008 if you have capacity.

---

### TASK-005 · App shell + responsive navigation
- **Status:** done
- **Depends on:** TASK-004
- **Spec:** `specs/shell_spec.md`
- **What to build:**
  - Responsive shell widget using layout router pattern
  - **Mobile (< 600px):** Navy top bar, `BottomNavigationBar` with 5 slots: Home, Monthly, [FAB], Transactions, More. FAB opens Add Transaction placeholder sheet
  - **Desktop (≥ 600px):** Navy gradient header ("Kerby Family Budget [year]"), horizontal tab row: Dashboard | Monthly | Transactions | Mileage | Business | Settings
  - Active tab/nav item highlighted correctly
  - All navigation uses GoRouter `context.go()`
- **When done:** Change status to `ready-to-review`

---

### TASK-006 · Category data layer
- **Status:** done
- **Depends on:** TASK-005
- **Spec:** `specs/categories_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - `Category` model (Freezed): `{ id, orgId, parentCategory, subcategory, sortOrder }`
  - Category service: load by org, seed defaults on new org
  - `categoriesProvider` — `@riverpod` watching categories for current org
  - Seed the full default category list (13 parent categories, ~60 subcategories)
  - No UI in this task — data layer only
- **When done:** Change status to `ready-to-review`

---

### TASK-007 · Budget defaults + Settings screen
- **Status:** done
- **Depends on:** TASK-006
- **Spec:** `specs/settings_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - `AppSettings` model (Freezed): `{ id, orgId, irsRatePerMile }`
  - `BudgetDefault` model (Freezed): `{ id, orgId, category, subcategory, monthlyAmount, defaultBizPct, month (nullable — null = global default) }`
  - Settings service: load/save both models
  - **Settings screen (desktop tab + mobile More screen):**
    - IRS mileage rate input (default $0.670/mile, helper text "update each year")
    - Budget defaults table: category header rows (navy bg) → subcategory rows with: name (editable inline), monthly amount (number input), default biz % (number input)
    - Inline add subcategory (green highlighted row), inline rename (amber border), delete button
    - "Reset to Defaults" button, "Save All Budgets" button
    - Data section (desktop only): Export JSON backup, Import JSON, storage usage
- **When done:** Change status to `ready-to-review`

---

### TASK-008 · Transaction data layer
- **Status:** done
- **Depends on:** TASK-006, TASK-007
- **Spec:** `specs/transactions_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - `Transaction` model (Freezed): `{ id, orgId, createdBy, date, amount, merchant, description, category, subcategory, bizPct, isSplit, receiptId (nullable), notes, createdAt }`
  - Transaction service: `insertTransaction`, `updateTransaction`, `deleteTransaction`, `fetchTransactions(orgId, {month, category, bizFilter})`
  - `transactionsProvider(filter)` — `@riverpod` filtered list
  - Pure helpers in `lib/features/transactions/helpers/transaction_calculations.dart`:
    - `calculatePersonalAmount(amount, bizPct)` → amount × (1 - bizPct)
    - `calculateBusinessAmount(amount, bizPct)` → amount × bizPct
    - `calculateTransactionSummary(List<Transaction>)` → `{ income, expenses, net, businessTotal }`
  - `build_runner` must pass clean
- **When done:** Change status to `ready-to-review`

---

### TASK-009 · Mileage Log
- **Status:** done
- **Depends on:** TASK-005 only — can run in parallel with TASK-006/007/008
- **Spec:** `specs/mileage_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - `MileageTrip` model (Freezed): `{ id, orgId, createdBy, date, purpose, fromAddress, toAddress, oneWayMiles, isRoundTrip, bizPct, category, createdAt }`
  - Mileage service: CRUD
  - Pure helpers in `lib/features/mileage/helpers/mileage_calculations.dart`:
    - `totalMiles(oneWayMiles, isRoundTrip)` → ×2 if round trip
    - `deductibleMiles(totalMiles, bizPct)`
    - `deductibleValue(deductibleMiles, irsRate)`
  - **Summary tiles** (4): Total Trips, Total Miles, Deductible Miles, Deductible Value ($)
  - **Add/Edit Trip form** (bottom sheet mobile, dialog desktop): Date, Business Category (dropdown), Trip Purpose, From Address, To Address, Miles (one way), Round Trip (yes/no), Biz% (default 100), live deductible value preview
  - **Mobile list:** trip items (purpose bold, date, miles, deductible $), tap to edit
  - **Desktop:** month filter toolbar, table (Date | Purpose | From | To | Miles | RT | Biz% | Ded. Miles | Ded. Value | Actions)
- **When done:** Change status to `ready-to-review`

---

## Phase 1.2 · Household Invites (TASK-016 → TASK-017)

Must be done before Phase 2. Sequential — TASK-017 depends on TASK-016.

---

### TASK-016 · Invite code schema + InviteService
- **Status:** done
- **Depends on:** TASK-004 (org creation exists)
- **Spec:** `specs/invite_spec.md`
- **What to build:**
  - Run SQL in Supabase: add `invite_code` column to `organizations`, backfill existing orgs, add RLS policy for code lookup
  - Update `OrgService.createOrg` to generate and include a 6-char invite code on insert
  - New `InviteService`: `findOrgByCode`, `joinOrg`, `getInviteCode`, `regenerateCode`
  - Add `inviteServiceProvider` to `onboarding_provider.dart`
  - `build_runner` after provider changes
- **When done:** Change status to `ready-to-review`

---

### TASK-017 · Onboarding fork + invite code in Settings
- **Status:** done
- **Depends on:** TASK-016, TASK-007 (Settings screen must exist)
- **Spec:** `specs/invite_spec.md`
- **What to build:**
  - Fork `OnboardingScreen` into: Choose path → Create household (existing flow) OR Join household (enter 6-char code → confirm org name → join)
  - Add Invite Code section to Settings screen (desktop + mobile): show code, Copy button, Regenerate button (owners only)
  - Call `clearOrgCache()` + `router.refresh()` after joining
- **When done:** Change status to `ready-to-review`

---

## Phase 2 · Features (TASK-010 → TASK-015)

Phase 1 and Phase 1.2 are approved. **Phase 2 is now open.**

TASK-010/011/012/013/015 can all run simultaneously. TASK-014 needs TASK-008 and TASK-009 (both done).

---

### TASK-010 · Add/Edit Transaction form
- **Status:** ready-to-review
- **Depends on:** TASK-008
- **Spec:** `specs/transactions_spec.md`
- **What to build:**
  - Bottom sheet (mobile) / dialog (desktop) for Add and Edit Transaction
  - Fields: Date, Total Amount ($), Merchant/Payee, Description (optional), Category (dropdown), Subcategory (dropdown — filtered by selected category), Business % 0–100 (number input), Split Transaction? (yes/no dropdown), Notes (textarea)
  - Live personal/business split preview: shows when biz% > 0 — "Personal: $X | Biz %: Y% | Business: $Z" in teal-light bg box
  - Auto-apply default biz% when subcategory selected (from `BudgetDefault` for that subcategory)
  - Validation: date required, amount > 0, category required, subcategory required
  - Receipt placeholder: "📎 Attach Receipt" button — disabled/greyed out with tooltip "Available in a future update"
  - Edit mode: pre-populate all fields from existing transaction
- **When done:** Change status to `ready-to-review`

---

### TASK-011 · Transactions list screen
- **Status:** done
- **Depends on:** TASK-008, TASK-010
- **Spec:** `specs/transactions_spec.md`
- **What to build:**
  - **Mobile layout** (`lib/features/transactions/layouts/mobile/`):
    - Month pill chips (scrollable row: All, Jan–Dec)
    - Category filter chips (scrollable row: All Categories, then each category name)
    - Summary row: "N transactions | Total: $X | Business: $Y | Personal: $Z"
    - Transaction list items: left icon circle (teal for expense, green for income, purple for biz), merchant name (bold), category/sub below, date right-aligned, amount bold, biz badge if applicable
    - Tap item → opens Edit form
  - **Desktop layout** (`lib/features/transactions/layouts/web/`):
    - Toolbar: search input, month dropdown, category dropdown, personal/business dropdown filter
    - Summary bar below toolbar
    - Table: Date | Merchant | Description | Amount | Category | Subcategory | Personal | Business | Biz% | Receipt | Notes | Actions (✏️ 🗑)
    - Alternating row colors (white / light-gray)
    - Sticky navy header row
  - Empty state: icon + "No transactions found" + "Add your first transaction above"
  - Toast on save/delete
- **When done:** Change status to `ready-to-review`

---

### TASK-012 · Dashboard screen
- **Status:** done
- **Depends on:** TASK-008 — parallel with TASK-010/011/013/015
- **Spec:** `specs/dashboard_spec.md` ← Claude writes this before Codex starts
- **pubspec addition needed:** Add `fl_chart: ^0.69.0` to `pubspec.yaml`, run `flutter pub get`
- **What to build:**
  - **Mobile (Home screen)** (`lib/features/dashboard/layouts/mobile/`):
    - 2×2 summary tiles: Income (green left border), Expenses (teal), Net (amber, green/red text), Business (purple)
    - Monthly bar chart: 12-month income vs expenses (fl_chart BarChart)
    - "This Month — By Category" collapsible card: each category row is tappable to expand/collapse subcategory list with progress bars (green < 80%, amber 80–99%, red ≥ 100%)
    - "Recent Transactions" card: last 5 transactions, "See all →" link
  - **Desktop (Dashboard tab)** (`lib/features/dashboard/layouts/web/`):
    - Year/month filter dropdown top-right
    - 4 summary stat cards in a row (Income, Expenses, Net, Business)
    - 2-column chart grid: left = bar chart (monthly income vs expenses), right = donut chart (expense breakdown by category)
    - Category totals table: Category | Actual | Budget/mo | Business $ | Biz%
- **When done:** Change status to `ready-to-review`

---

### TASK-013 · Monthly Budget View screen
- **Status:** done
- **Depends on:** TASK-007, TASK-008 — parallel with TASK-010/011/012/015
- **Spec:** `specs/monthly_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - Month pill selector (Jan–Dec, scrollable, current month active by default)
  - **View mode:**
    - Toolbar: "[Month] Budgets" label, "Using default budgets" or "✔ Custom budgets set" badge, "✏️ Edit Budgets" button, "✕ Clear Overrides" button (only if custom set)
    - Table/list: category header row → subcategory rows: Budget | Actual | Remaining (green if ≥ 0, red if < 0) | Progress bar | Personal | Business | Biz%
    - Category subtotal rows (teal-light bg, bold)
    - Charts below: horizontal bar chart (budget vs actual per category), donut (business breakdown)
  - **Edit mode:**
    - Amber "✏️ EDITING" badge, amber border on toolbar
    - Budget column becomes input fields
    - "📋 Copy Defaults" button, "✕ Cancel" button, "💾 Save [Month] Budgets" button
    - Toast on save: "✅ [Month] budgets saved"
  - Budget logic: per-month override (stored in `budgets` where month = first day of month) falls back to global default (month = null)
  - **Mobile:** Collapsible category groups, edit mode opens bottom sheet for each subcategory
- **When done:** Change status to `ready-to-review`

---

### TASK-014 · Business Summary screen
- **Status:** done
- **Depends on:** TASK-008, TASK-009
- **Spec:** `specs/business_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - Year/month filter
  - Summary stat cards: Total Business Expenses, Mileage Deduction $, Combined Deductions, Business Expense % (of total)
  - Business expenses by category table: Category | Business $ | % of Total
  - Mileage deduction summary block: Total Trips | Total Miles | Deductible Miles | IRS Rate | Total Deduction
  - **Mobile:** same content in cards/lists (not table)
- **When done:** Change status to `ready-to-review`

---

### TASK-015 · Receipt upload + management
- **Status:** done
- **Depends on:** TASK-008 — parallel with TASK-010/011/012/013
- **Spec:** `specs/receipts_spec.md` ← Claude writes this before Codex starts
- **What to build:**
  - File picker → upload to Supabase Storage bucket `receipts` at path `{org_id}/{year}/{month}/{receipt_id}_{filename}`
  - Save metadata to `receipts` table
  - Receipt list screen: searchable/filterable (date range, category, merchant, linked/unlinked)
  - Download: generate signed URL → trigger browser download (use `url_launcher` or `dart:html` `AnchorElement`)
  - Link receipt to transaction: from receipt list or from Add/Edit Transaction form (replace placeholder button)
  - Storage usage indicator in Settings (fetch from Supabase Storage API)
- **When done:** Change status to `ready-to-review`

---

## Completed Tasks

| Task ID | Description | Completed | Notes |
|---|---|---|---|
| TASK-001 | Supabase full schema + RLS + triggers | Claude/Codex | 9 tables, RLS on all, trigger deployed, email confirm disabled |
| TASK-002 | Core app scaffold | Codex | theme, routing, dotenv, Supabase init, RouterNotifier — analyzer clean |
| TASK-003 | Auth feature | Codex | sign in/up/out/forgot password — `as supa` alias correct, no manual nav, analyzer clean |
| TASK-004 | Org onboarding | Codex | OrgService, OnboardingController, OnboardingScreen — router.refresh() after create, analyzer clean |
| TASK-005 | App shell + navigation | Codex | StatefulShellRoute, desktop header+tabs, mobile AppBar+BottomNav+FAB+More sheet — analyzer clean |
| TASK-006 | Category data layer | Codex | Category Freezed model, CategoryService, categoriesProvider, ~60 subcategory seed |
| TASK-007 | Budget defaults + Settings screen | Codex | AppSettings + BudgetDefault models, SettingsService, SettingsEditor widget, desktop + mobile layouts |
| TASK-008 | Transaction data layer | Codex | Transaction + TransactionFilter Freezed models, TransactionService, transaction_calculations helpers, providers |
| TASK-009 | Mileage Log | Codex | MileageTrip model, MileageService, mileage_calculations helpers, Add/Edit form, mobile list + desktop table |
| TASK-016 | Invite code schema + InviteService | Codex | invite_code column on organizations, OrgService updated, InviteService, inviteServiceProvider |
| TASK-017 | Onboarding fork + invite code in Settings | Codex | Choose/Create/Join flow, join confirmation dialog, invite code section in SettingsEditor |
| TASK-010 | Add/Edit Transaction form | Codex | ConsumerStatefulWidget + TextEditingController, auto biz% from defaults, live split preview, mobile sheet + desktop dialog |
| TASK-011 | Transactions list screen | Codex | Mobile month/category filters + list, desktop search/filter/table, FAB wired, empty states |
| TASK-012 | Dashboard screen | Codex | DashboardSummary provider, fl_chart bar + donut charts, category progress bars, recent transactions, year filter on desktop |
| TASK-013 | Monthly Budget View | Codex | MonthlyBudgetData provider, view/edit modes, per-month overrides, progress bars, collapsible mobile + inline desktop edit |
| TASK-015 | Receipt upload + management | Codex | Receipt Freezed model, ReceiptService (upload/download/link/delete), FilePicker, dart:html download, transaction form integration |
| TASK-014 | Business Summary screen | Codex | BusinessSummaryData provider, year/month filter, desktop table + mobile cards, mileage deduction block, wired to /business |

---

## Review Escalations

| Task ID | Question | Raised by | Status |
|---|---|---|---|
| TASK-001 | Should `organizations` select/insert policies be adjusted to allow returning the new org row on insert (for onboarding), or should onboarding always insert with client-generated UUID + `return=minimal`? | Codex | resolved — use client-generated UUID (TASK-016 adds open select policy for invite lookup) |

---

## Task Summary

| Task | Description | Depends On | Status |
|---|---|---|---|
| TASK-001 | Supabase full schema | none | done |
| TASK-002 | Core app scaffold | TASK-001 | done |
| TASK-003 | Auth feature | TASK-002 | done |
| TASK-004 | Org onboarding | TASK-003 | done |
| TASK-005 | App shell + navigation | TASK-004 | done |
| TASK-006 | Category data layer | TASK-005 | done |
| TASK-007 | Budget defaults + Settings screen | TASK-006 | done |
| TASK-008 | Transaction data layer | TASK-006, TASK-007 | done |
| TASK-009 | Mileage Log | TASK-005 | done |
| TASK-016 | Invite code schema + InviteService | TASK-004 | done |
| TASK-017 | Onboarding fork + invite code in Settings | TASK-016, TASK-007 | done |
| TASK-010 | Add/Edit Transaction form | TASK-008 | done |
| TASK-011 | Transactions list screen | TASK-008, TASK-010 | done |
| TASK-012 | Dashboard screen | TASK-008 | done |
| TASK-013 | Monthly Budget View | TASK-007, TASK-008 | done |
| TASK-014 | Business Summary | TASK-008, TASK-009 | done |
| TASK-015 | Receipt upload + management | TASK-008 | done |
| TASK-018 | Teller bank integration | TASK-008, TASK-007 | ready-to-review |
| TASK-019 | Monthly subcategory transaction drill-down | TASK-013 | ready-to-review |

**Phase 2 is fully open. All specs written. Codex may pick up any `ready` task.**

---

## Phase 3 · Teller Bank Integration (TASK-018)

---

### TASK-018 · Teller bank account integration
- **Status:** ready-to-review
- **Depends on:** TASK-008 (transactions table), TASK-007 (settings screen)
- **Spec:** `specs/teller_spec.md`
- **What to build:**

  **Step 1 — Database migration**
  - Create `teller_enrollments` table with RLS (see spec)
  - Create `teller_sync_log` table with RLS (see spec)
  - Alter `transactions`: add `source text not null default 'manual'`, add `teller_transaction_id text unique`
  - Migration file: `supabase/migrations/20260317030000_teller.sql`

  **Step 2 — Edge Functions (3 files)**
  - `supabase/functions/teller-enroll/index.ts` — receives enrollment from Flutter, calls Teller `/accounts`, stores token + account details, triggers initial 90-day sync
  - `supabase/functions/teller-sync/index.ts` — syncs transactions for one or all enrollments; called by cron and manually; deduplicates by `teller_transaction_id`; sets `category='Uncategorized'` except income credits on depository accounts → `category='Income'`, `subcategory='Other Income'`
  - `supabase/functions/teller-disconnect/index.ts` — marks enrollment inactive, calls Teller DELETE
  - All functions: JWT disabled, verify manually; use `esm.sh` imports; mTLS via `Deno.createHttpClient`

  **Step 3 — Flutter data layer**
  - `lib/features/teller/models/teller_enrollment.dart` — Freezed model (no `accessToken` field)
  - `lib/features/teller/data/teller_service.dart` — `fetchEnrollments`, `enroll`, `syncNow`, `disconnect`
  - `lib/features/teller/presentation/providers/teller_provider.dart` — `tellerEnrollmentsProvider`, `TellerController`
  - `lib/features/teller/helpers/teller_connect.dart` — JS interop to launch Teller Connect widget
  - Run `build_runner` after providers

  **Step 4 — web/index.html**
  - Add `<script src="https://cdn.teller.io/connect/connect.js"></script>` before `</body>`

  **Step 5 — .env**
  - Add `TELLER_APP_ID=` to `.env` and `.env.example`

  **Step 6 — Settings UI**
  - Add "Connected Bank Accounts" card to `SettingsEditor` (desktop + mobile)
  - Empty state: "No bank accounts connected" + Connect Account button
  - Per-account row: institution name, account name, last four, last synced timestamp, Sync Now button, Disconnect button
  - Connect Account → launches Teller Connect → on success → calls `TellerController.enroll` → shows "Importing transactions..." snackbar → refreshes list
  - Sync Now → calls `syncNow` → snackbar with count: "Imported N transactions"
  - Disconnect → confirmation dialog → calls `disconnect`

  **Step 7 — pg_cron** (manual setup — Codex documents the SQL, director runs it)
  - Write the cron SQL to `docs/teller_cron_setup.md` — do NOT run it; director will set up in Supabase dashboard

- **When done:** Change status to `ready-to-review`
