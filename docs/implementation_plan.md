# Implementation Plan

> Tasks must be executed in phase order. Do not start a phase until the previous phase's acceptance criteria are met.

---

## Phase 1 · Foundation ← CURRENT PHASE

**What gets built:**
- Supabase schema: `organizations`, `profiles`, `org_members`
- RLS policies for all core tables
- Auto-create-profile trigger on `auth.users`
- Auth flow: sign up, sign in, sign out
- Org creation and membership
- Core routing with `RouterNotifier` redirect logic
- Core theme, colors, text styles

**Prerequisites:** None — this is the starting point.

**Acceptance criteria:**
- [ ] User can sign up and a profile row is auto-created
- [ ] User can sign in and is redirected to the app
- [ ] User can create an org and is added as owner in `org_members`
- [ ] Unauthenticated users are redirected to `/login`
- [ ] Users with no org are redirected to `/onboarding`
- [ ] App theme matches design guidelines (colors, typography, spacing)

---

## Phase 2 · Transactions

**What gets built:**
- `transactions` table + RLS
- Transaction entry form (amount, category, type: personal/business, date, notes)
- Transaction list view — filterable by month, type, category
- Edit and delete transactions

**Prerequisites:** Phase 1 complete (auth + org in place)

**Acceptance criteria:**
- [ ] User can log a transaction with all fields
- [ ] Transaction list shows current month by default
- [ ] Filtering by type (personal/business) and category works
- [ ] Edit and delete work correctly
- [ ] All queries scoped to `org_id`

---

## Phase 3 · Budget vs Actuals

**What gets built:**
- `budgets` table (monthly budget per category) + RLS
- Budget entry UI — set amounts per category per month
- Budget vs actuals comparison view — planned vs spent per category

**Prerequisites:** Phase 2 complete (transactions must exist to compare against)

**Acceptance criteria:**
- [ ] Admin can set budget amounts per category per month
- [ ] Budget vs actuals view shows planned, actual, and variance per category
- [ ] Over-budget categories are visually highlighted
- [ ] All queries scoped to `org_id`

---

## Phase 4 · Reports & Charts

**What gets built:**
- Monthly summary: income, expenses, net
- Category breakdown chart (pie/donut)
- Monthly trend chart (bar/line over 12 months)
- Business vs personal split view

**Prerequisites:** Phase 3 complete (transactions + budgets must exist)

**Acceptance criteria:**
- [ ] Dashboard shows income, expenses, net for current month
- [ ] Charts render correctly on mobile and desktop
- [ ] Month selector allows navigating to prior months
- [ ] Year-to-date summary is accurate

---

## Phase 5 · Receipt Management

**What gets built:**
- Receipt upload to Supabase Storage
- `receipts` table (metadata: merchant, amount, date, category, transaction_id) + RLS
- Receipt list view — searchable/filterable
- Download receipt to local disk
- Link receipt to a transaction

**Prerequisites:** Phase 2 complete (transactions must exist to attach receipts)

**Acceptance criteria:**
- [ ] User can upload a receipt image (JPG, PNG, PDF)
- [ ] Receipt metadata is saved and searchable
- [ ] Receipt can be downloaded to local disk
- [ ] Receipt can be linked to a transaction
- [ ] Receipt list is filterable by date, category, merchant

---

## Completed Phases

*(none yet)*
