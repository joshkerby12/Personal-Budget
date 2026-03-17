# Architecture

> Every agent reads this file first at the start of every session. Do not skip it.

---

## System Overview

- **App name:** Personal Budget App
- **Platform:** Flutter Web only (mobile + desktop breakpoints via responsive layouts — no native app)
- **Framework:** Flutter / Dart
- **State management:** Riverpod (`@riverpod` annotations, `riverpod_generator`)
- **Auth:** Supabase Auth
- **Database:** Supabase (Postgres)
- **Supabase project ref:** `xzjfxqkdzeawfnhfusut`
- **Supabase URL:** `https://xzjfxqkdzeawfnhfusut.supabase.co`
- **Routing:** GoRouter
- **Models:** Freezed v3.x
- **Secrets:** `flutter_dotenv` — loaded from `.env` at runtime

---

## Org / User Model

Every project uses this pattern — no exceptions.

- `organizations` — one row per family/org
- `profiles` — 1:1 with `auth.users`, auto-created via trigger on sign-up
- `org_members` — junction table linking profiles to orgs, with a `role` field (`owner | admin | member`)

All feature data is scoped to `org_id`. No query may return data without an org scope. No hardcoded IDs.

---

## Navigation Flow

`RouterNotifier` watches auth state:
- Unauthenticated → redirect to `/login`
- Authenticated, no org → redirect to `/onboarding`
- Authenticated, has org → allow through to app routes

---

## Responsive Breakpoints

| Breakpoint | Width |
|---|---|
| Mobile | < 600px |
| Tablet | 600–1200px |
| Web/Desktop | > 1200px |

Each feature has three layout files. The `_screen.dart` (layout router) selects which to render based on screen width.

---

## Known Gotchas

- **`AuthException` name clash** — in auth files, always: `import 'package:supabase_flutter/supabase_flutter.dart' as supa;`
- **`BuildContext` across async gaps** — capture `GoRouter.of(context)` and `ScaffoldMessenger.of(context)` before any `await`
- **Supabase RLS** — silent insert/update failures are almost always RLS. Check policies first
- **Edge Function imports** — use `https://esm.sh/@supabase/supabase-js@2`, never `jsr:`
- **Edge Function JWT** — "Verify JWT" is disabled on all functions; always call `supabase.auth.getUser()` manually
- **Flutter → Edge Function** — always include `headers: {'Authorization': 'Bearer ${session.accessToken}'}`

---

## `.env` Strategy

`flutter_dotenv` — loaded from `.env` at app startup via `await dotenv.load()` in `main.dart`. The `.env` file is listed in `pubspec.yaml` assets and is excluded from git via `.gitignore`. See `.env.example` for required keys.

---

## Doc Tree

```
docs/
├── architecture.md         ← you are here
├── master_plan.md
├── implementation_plan.md
├── design_guidelines.md
├── rules.md
├── agents.md
├── errors.md
├── tasks.md
└── data_structure.md

specs/
├── _spec_template.md
└── [feature]_spec.md       ← one per feature, added as features are designed
```

---

## Spec Sheet Index

> Updated as spec sheets are added.

- `auth_spec.md` — email/password sign up, sign in, sign out, forgot password
- `orgs_spec.md` — create organization, become owner, redirect to dashboard
- `shell_spec.md` — app shell, responsive nav (mobile bottom nav + FAB, desktop header + tab bar)
- `categories_spec.md` — category model, service, provider, default seed (~60 subcategories across 13 parents)
- `mileage_spec.md` — mileage trip model, CRUD, calculation helpers, full mobile/desktop UI
- `settings_spec.md` — AppSettings + BudgetDefault models, settings service, settings screen (IRS rate + budget defaults table)
- `invite_spec.md` — invite code schema, InviteService, onboarding fork (create vs join), invite code display in Settings
- `transactions_spec.md` — Transaction model, service, helpers, Add/Edit form, mobile list + desktop table (TASK-008, 010, 011)
- `dashboard_spec.md` — Dashboard screen, DashboardSummary, bar chart + donut chart, category progress, recent transactions (TASK-012)
- `monthly_spec.md` — Monthly Budget View, budget vs actual, per-month overrides, edit mode, MonthlyBudgetData (TASK-013)
- `business_spec.md` — Business Summary screen, business expense totals, mileage deduction, by-category table (TASK-014)
- `receipts_spec.md` — Receipt upload to Supabase Storage, Receipt model, receipt list, link to transaction, signed URL download (TASK-015)

---

## Folder Conventions

```
lib/features/[feature]/
├── helpers/       — pure functions: calculations, validators, formatters, mappers
├── widgets/       — reusable UI components for this feature
├── models/        — data models specific to this feature
├── layouts/
│   ├── mobile/    — mobile UI screens (< 600px)
│   ├── tablet/    — tablet UI screens (600–1200px)
│   └── web/       — desktop UI screens (> 1200px)
├── [feature]_[page]_screen.dart     — layout router (entry point)
└── [feature]_[page]_provider.dart   — Riverpod state (shared across all layouts)
```

---

## What's Working

- Auth (sign up, sign in, sign out, forgot password)
- Org onboarding (create household, join via invite code)
- App shell — responsive nav (mobile bottom nav + FAB, desktop header + tab bar)
- Category data layer — model, service, categoriesProvider, ~60 subcategory seed
- Budget defaults + Settings screen — AppSettings, BudgetDefault, SettingsService, SettingsEditor (desktop + mobile), invite code section
- Transactions feature — Transaction model, TransactionService CRUD + filters, calculation helpers, Add/Edit form, mobile list screen, desktop table screen
- Mileage Log — MileageTrip model, MileageService, helpers, Add/Edit form, mobile list + desktop table
- Monthly Budget View — MonthlyBudgetData provider, month selector, budget vs actual rows, per-month override edit/save/clear flows, desktop charts, mobile collapsible groups + bottom-sheet row editing
- Dashboard screen — DashboardSummary provider, mobile summary/chart/category/recent cards, desktop year filter + bar/donut charts + category totals table
- Business Summary screen — BusinessSummaryData provider, shared year/month filters, desktop summary/table view, mobile card/list view
- Household invite system — invite_code on organizations, InviteService, onboarding fork (Create vs Join)
- Receipt upload + management — Receipt Freezed model, ReceiptService (upload/download/link/delete), FilePicker, dart:html download, transaction form integration

---

## What Still Needs Building

- Pre-launch: re-enable email confirmation in Supabase Auth

## Additional Packages (to be added as phases progress)

- `fl_chart: ^0.69.0` — used for Dashboard and Monthly charts

---

## Pre-Launch Dependencies

- **Remote git repo** — created at `git@github.com:joshkerby12/Personal-Budget.git`
- **Email confirmation** — currently disabled in Supabase Auth for development. Re-enable before production launch.
- **Hosting** — Flutter web build deployed via GitHub Pages (workflow already in place). Confirm custom domain if desired.

---

## Maintenance Rule

After every task — whether creating a new file, adding a function, moving code, or renaming anything — both Claude and Codex must update this file. The doc tree, spec sheet index, and folder conventions must reflect the current state of the project at all times. A task is not done until the map is updated.
