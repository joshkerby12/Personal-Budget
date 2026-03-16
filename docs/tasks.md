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

### TASK-001 · Supabase full schema + RLS + triggers
- **Status:** done
- **Phase:** Phase 1 · Foundation
- **Spec:** `docs/data_structure.md` — all tables defined there
- **What to build:** Run ALL SQL from `docs/data_structure.md` in the Supabase SQL editor:
  - `organizations`, `profiles`, `org_members` tables + RLS + auto-create-profile trigger
  - `categories` table + RLS
  - `budgets` table + RLS
  - `transactions` table + RLS
  - `mileage_trips` table + RLS
  - `receipts` table + RLS
  - `app_settings` table + RLS
  - Disable email confirmation in Supabase Auth settings (Auth → Providers → Email → uncheck "Confirm email")
- **Acceptance criteria:**
  - [ ] All tables exist in Supabase dashboard with correct columns
  - [ ] RLS is enabled on every table
  - [ ] Auto-create-profile trigger deployed — sign up a test user and confirm a profile row is auto-created
  - [ ] Email confirmation is disabled
- **Files to create/modify:** None — Supabase SQL editor only
- **When done:** Change status to `ready-to-review`, notify Claude

---

### TASK-002 · Core app scaffold
- **Status:** done
- **Phase:** Phase 1 · Foundation
- **Spec:** `docs/design_guidelines.md` (all theme values), `docs/architecture.md`
- **What to build:**
  - `lib/core/theme/app_colors.dart` — all color constants from `design_guidelines.md`
  - `lib/core/theme/app_text_styles.dart` — text style constants
  - `lib/core/theme/app_theme.dart` — ThemeData using above constants
  - `lib/core/constants/app_constants.dart` — breakpoints (mobile < 600, tablet 600–1200, desktop ≥ 1200), spacing scale (xs=4, sm=8, md=12, lg=16, xl=20, xxl=24)
  - `lib/core/constants/supabase_constants.dart` — load URL and anon key from `dotenv`
  - `lib/core/network/supabase_client_provider.dart` — `@riverpod` provider returning `SupabaseClient`
  - `lib/core/routing/app_routes.dart` — route name string constants
  - `lib/core/routing/app_router.dart` — GoRouter with shell routes for all screens
  - `lib/core/routing/router_notifier.dart` — auth-aware redirect: unauth → `/login`, no org → `/onboarding`, else allow
  - `lib/core/widgets/loading_overlay.dart` — full-screen loading indicator
  - `lib/core/widgets/error_view.dart` — reusable error card widget
  - `lib/main.dart` — `await dotenv.load()`, `Supabase.initialize()`, `ProviderScope`, `runApp`
  - `lib/app.dart` — `MaterialApp.router` with theme and GoRouter
- **Acceptance criteria:**
  - [ ] `flutter run -d chrome` starts with no errors
  - [ ] Unauthenticated user is redirected to `/login`
  - [ ] Theme colors match `design_guidelines.md`
  - [ ] No hardcoded keys or strings
  - [ ] `flutter pub run build_runner build --delete-conflicting-outputs` runs clean
- **When done:** Run `flutter run -d chrome`, confirm redirect, change status to `ready-to-review`

---

### TASK-003 · Auth feature (sign up, sign in, sign out, forgot password)
- **Status:** done
- **Phase:** Phase 1 · Foundation
- **Spec:** `specs/auth_spec.md` ← Claude writes this before Codex starts TASK-003
- **What to build:** Auth service + screens — fully defined in spec
- **When done:** Change status to `ready-to-review`

---

### TASK-004 · Org onboarding (create org → become owner)
- **Status:** ready
- **Phase:** Phase 1 · Foundation
- **Spec:** `specs/orgs_spec.md` ← Claude writes this before Codex starts TASK-004
- **What to build:** Org creation screen + service — fully defined in spec
- **When done:** Change status to `ready-to-review`

---

### TASK-005 · App shell + responsive navigation
- **Status:** blocked — waiting on TASK-004
- **Phase:** Phase 1 · Foundation
- **Spec:** `specs/shell_spec.md` ← Claude writes this before Codex starts TASK-005
- **What to build:**
  - Responsive shell widget using layout router pattern
  - **Mobile (< 600px):** Navy top bar (app name, year), `BottomNavigationBar` with 5 slots: Home, Monthly, [FAB], Transactions, More. FAB = teal/navy gradient circle, opens Add Transaction bottom sheet
  - **Desktop (≥ 600px):** Navy gradient header (app name "Kerby Family Budget [year]", subtitle), horizontal tab row below header (navy bg, white text, light-blue underline for active tab): Dashboard | Monthly | Transactions | Mileage | Business | Settings
  - Active tab/nav item highlighted correctly
  - All navigation uses GoRouter `context.go()`
- **When done:** Change status to `ready-to-review`

---

### TASK-006 · Category management + default seed
- **Status:** blocked — waiting on TASK-005
- **Phase:** Phase 2 · Transactions
- **Spec:** `specs/categories_spec.md` ← Claude writes this before Codex starts TASK-006
- **What to build:**
  - `Category` model (Freezed): `{ id, orgId, parentCategory, subcategory, sortOrder }`
  - Category service: load by org, seed defaults on new org
  - `categoriesProvider` — `@riverpod` watching categories for current org
  - Seed the full default category list (13 parent categories, ~60 subcategories — see TASK-001 description for full list)
  - No UI in this task — data layer only
- **When done:** Change status to `ready-to-review`

---

### TASK-007 · Budget defaults + Settings screen
- **Status:** blocked — waiting on TASK-006
- **Phase:** Phase 2 · Transactions
- **Spec:** `specs/settings_spec.md` ← Claude writes this before Codex starts TASK-007
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
- **Status:** blocked — waiting on TASK-007
- **Phase:** Phase 2 · Transactions
- **Spec:** `specs/transactions_spec.md` ← Claude writes this before Codex starts TASK-008
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

### TASK-009 · Add/Edit Transaction form
- **Status:** blocked — waiting on TASK-008
- **Phase:** Phase 2 · Transactions
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

### TASK-010 · Transactions list screen
- **Status:** blocked — waiting on TASK-009
- **Phase:** Phase 2 · Transactions
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

### TASK-011 · Dashboard screen
- **Status:** blocked — waiting on TASK-010
- **Phase:** Phase 3 · Dashboard & Monthly View
- **Spec:** `specs/dashboard_spec.md` ← Claude writes this before Codex starts TASK-011
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

### TASK-012 · Monthly Budget View screen
- **Status:** blocked — waiting on TASK-011
- **Phase:** Phase 3 · Dashboard & Monthly View
- **Spec:** `specs/monthly_spec.md` ← Claude writes this before Codex starts TASK-012
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

### TASK-013 · Mileage Log
- **Status:** blocked — waiting on TASK-012
- **Phase:** Phase 4 · Mileage & Business
- **Spec:** `specs/mileage_spec.md` ← Claude writes this before Codex starts TASK-013
- **What to build:**
  - `MileageTrip` model (Freezed): `{ id, orgId, createdBy, date, purpose, fromAddress, toAddress, onemileMiles, isRoundTrip, bizPct, category, createdAt }`
  - Mileage service: CRUD
  - Pure helpers in `lib/features/mileage/helpers/mileage_calculations.dart`:
    - `totalMiles(oneWayMiles, isRoundTrip)` → ×2 if round trip
    - `deductibleMiles(totalMiles, bizPct)`
    - `deductibleValue(deductibleMiles, irsRate)`
  - **Summary tiles** (4): Total Trips, Total Miles, Deductible Miles, Deductible Value ($)
  - **Add/Edit Trip form** (bottom sheet mobile, dialog desktop): Date, Business Category (dropdown of business-flagged categories), Trip Purpose, From Address, To Address, Miles (one way), Round Trip (yes/no), Biz% (default 100), live deductible value preview (green box: "$X.XX deductible")
  - **Mobile list:** trip items (purpose bold, date, miles, deductible $), tap to edit
  - **Desktop:** month filter toolbar, table (Date | Purpose | From | To | Miles | RT | Biz% | Ded. Miles | Ded. Value | Actions)
- **When done:** Change status to `ready-to-review`

---

### TASK-014 · Business Summary screen
- **Status:** blocked — waiting on TASK-013
- **Phase:** Phase 4 · Mileage & Business
- **Spec:** `specs/business_spec.md` ← Claude writes this before Codex starts TASK-014
- **What to build:**
  - Year/month filter
  - Summary stat cards: Total Business Expenses, Mileage Deduction $, Combined Deductions, Business Expense % (of total)
  - Business expenses by category table: Category | Business $ | % of Total
  - Mileage deduction summary block: Total Trips | Total Miles | Deductible Miles | IRS Rate | Total Deduction
  - **Mobile:** same content in cards/lists (not table)
- **When done:** Change status to `ready-to-review`

---

### TASK-015 · Receipt upload + management
- **Status:** blocked — waiting on TASK-014
- **Phase:** Phase 5 · Receipts
- **Spec:** `specs/receipts_spec.md` ← Claude writes this before Codex starts TASK-015
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

---

## Review Escalations

| Task ID | Question | Raised by | Status |
|---|---|---|---|
| TASK-001 | Should `organizations` select/insert policies be adjusted to allow returning the new org row on insert (for onboarding), or should onboarding always insert with client-generated UUID + `return=minimal`? | Codex | open |

---

## Task Summary

| Task | Description | Depends On | Status |
|---|---|---|---|
| TASK-001 | Supabase full schema | none | done |
| TASK-002 | Core app scaffold | TASK-001 | done |
| TASK-003 | Auth feature | TASK-002 | done |
| TASK-004 | Org onboarding | TASK-003 | ready |
| TASK-005 | App shell + navigation | TASK-004 | blocked |
| TASK-006 | Category management + seed | TASK-005 | blocked |
| TASK-007 | Budget defaults + Settings screen | TASK-006 | blocked |
| TASK-008 | Transaction data layer | TASK-007 | blocked |
| TASK-009 | Add/Edit Transaction form | TASK-008 | blocked |
| TASK-010 | Transactions list screen | TASK-009 | blocked |
| TASK-011 | Dashboard screen | TASK-010 | blocked |
| TASK-012 | Monthly Budget View | TASK-011 | blocked |
| TASK-013 | Mileage Log | TASK-012 | blocked |
| TASK-014 | Business Summary | TASK-013 | blocked |
| TASK-015 | Receipt upload + management | TASK-014 | blocked |

**TASK-004 is ready. Claude needs to write `specs/orgs_spec.md` before Codex starts.**
