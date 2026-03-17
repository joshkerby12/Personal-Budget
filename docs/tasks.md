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

**Phase 2 is fully open. All specs written. Codex may pick up any `ready` task.**
