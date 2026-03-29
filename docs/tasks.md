# Tasks

Active task queue. Claude authors and scopes all tasks. Codex picks up `ready` tasks and implements them.

---

## Status Rules — Non-Negotiable

### Codex must:
1. When you **start** a task → change status from `ready` to `in-progress`
2. When you **finish** a task → mark status `done`, move it to the **Completed Tasks** table (summary line only), and check if the next dependent task can now be unblocked
3. When you are **blocked** → change status to `blocked`, log in `docs/errors.md`, stop immediately

---

## Status Key

| Status | Meaning |
|---|---|
| `ready` | Scoped by Claude, ready for Codex to pick up |
| `in-progress` | Codex is actively working on it |
| `done` | Completed — moved to Completed Tasks table by Codex |
| `blocked` | Codex hit a problem — see `docs/errors.md` |

---

## Active Tasks

> No active tasks. All tasks complete. Awaiting new tasks from Claude.

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
| TASK-018 | Teller bank integration | Codex | teller_enrollments + sync_log tables, 3 edge functions, TellerService + provider, JS interop, Settings UI, pg_cron doc |
| TASK-019 | Monthly subcategory drill-down | Codex | Desktop + mobile expand/collapse, transaction sub-rows, budget suggestion label |
| TASK-021 | Auto-categorization suggestions | Codex | recentCategorizedTransactionsProvider, merchant normalization, suggestion UI in uncategorized panel |
| TASK-022 | Missing miles panel | Codex | no_miles migration + model field, desktop missing miles panel, inline miles entry + No Miles button |
| TASK-020 | Monthly uncategorized panel | Codex | Collapsible uncategorized card in monthly view with edit-sheet routing + refresh on save |
| TASK-023 | Monthly mobile expand + desktop suggestion label | Codex | Mobile subcategory expand rows with edit/rename/delete controls; desktop prior-month suggested budget label |
| TASK-024 | Monthly per-month subcategory add | Codex | Desktop inline add + mobile bottom-sheet add for month-scoped subcategories |
| TASK-025 | Monthly default fallback fix | Codex | Provider now includes month override keys so month-scoped rows and fallback/default resolution remain intact |
| TASK-026 | Transaction form improvements | Codex | Source label for imported transactions, drag-dismiss mobile sheet, sort-order category/subcategory picker improvements |
| TASK-027 | Dashboard time range filter | Codex | Range selector (This Month/3M/6M/YTD) wired into provider + mobile/web charts and totals |
| TASK-028 | Mobile safe-area bottom padding | Codex | SafeArea bottom handling across all mobile layout screens |
| TASK-029 | Transaction form suggestion prefill | Codex | Uncategorized edit form now pre-fills merchant-history suggestion and supports blank unselected state when none |
| TASK-030 | CSV transaction import | Codex | CSV institution mapping + parse/dedup + import log tables/service/providers; desktop/mobile import flow with history drill-down |

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
| TASK-018 | Teller bank integration | TASK-008, TASK-007 | done |
| TASK-019 | Monthly subcategory drill-down | TASK-013 | done |
| TASK-021 | Auto-categorization suggestions | TASK-020 | done |
| TASK-022 | Missing miles panel | TASK-013 | done |
| TASK-020 | Monthly uncategorized panel | TASK-019 | done |
| TASK-023 | Monthly mobile expand + desktop budget suggestion | TASK-019 | done |
| TASK-024 | Monthly per-month subcategory add | TASK-013 | done |
| TASK-025 | Monthly future month budget defaults fix | TASK-013 | done |
| TASK-026 | Transaction form improvements | TASK-010, TASK-018 | done |
| TASK-027 | Dashboard time range filter | TASK-012 | done |
| TASK-028 | Mobile safe area bottom padding | none | done |
| TASK-029 | Uncategorized transaction form auto-fill | TASK-021 | done |
| TASK-030 | CSV transaction import | TASK-008 | done |
