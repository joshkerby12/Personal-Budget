# Implementation Plan

> Tasks must be executed in phase order. Do not start a phase until the previous phase's acceptance criteria are met.

---

## Phase 1 · Foundation ← CURRENT PHASE

**What gets built:** TASK-001 through TASK-005

- Supabase full schema (all tables, RLS, triggers)
- Core app scaffold (theme, routing, dotenv, Supabase init)
- Auth (sign up, sign in, sign out, forgot password)
- Org onboarding (create org, become owner)
- App shell + responsive navigation (mobile bottom nav, desktop tab nav)

**Acceptance criteria:**
- [ ] User can sign up — profile auto-created
- [ ] User can sign in and is redirected to the app
- [ ] User with no org is redirected to `/onboarding`
- [ ] User can create an org and is added as owner
- [ ] Mobile bottom nav and desktop tab nav both render correctly
- [ ] App theme matches design guidelines

---

## Phase 2 · Transactions ← Next after Phase 1

**What gets built:** TASK-006 through TASK-010

- Category management (default 13 categories / ~60 subcategories seeded per org)
- Budget defaults + Settings screen (IRS rate, per-subcategory monthly budget, default biz %, subcategory add/rename/delete)
- Transaction data layer (model, service, CRUD, calculations helper)
- Add/Edit Transaction form (bottom sheet/dialog, live split preview, biz% auto-apply)
- Transactions list screen (mobile chip/list, desktop toolbar/table, filters, empty state)

**Acceptance criteria:**
- [ ] Default categories seeded on new org
- [ ] IRS rate and budget defaults save correctly
- [ ] Transaction CRUD works, all scoped to org_id
- [ ] Personal/business split preview is live and accurate
- [ ] Filters work (month, category, personal/business)
- [ ] Edit opens pre-filled form correctly

---

## Phase 3 · Dashboard & Monthly View

**What gets built:** TASK-011 through TASK-012

- Dashboard screen (summary tiles, charts, category list, recent transactions)
- Monthly Budget View (month pill selector, budget vs actual table, edit mode, charts)
- Add `fl_chart` package

**Acceptance criteria:**
- [ ] Charts render with real data (bar, donut)
- [ ] Budget vs actual is accurate per subcategory
- [ ] Progress bars color correctly (green/amber/red)
- [ ] Per-month budget overrides work and fall back to global defaults
- [ ] Collapsible categories work on mobile

---

## Phase 4 · Mileage & Business Summary

**What gets built:** TASK-013 through TASK-014

- Mileage Log (CRUD, round trip, IRS rate deduction calculation, summary tiles)
- Business Summary screen (deductions by category, mileage summary, year/month filter)

**Acceptance criteria:**
- [ ] Round trip doubles miles correctly
- [ ] Deductible value uses current IRS rate
- [ ] Business summary totals match transaction biz% calculations
- [ ] Mileage deduction section is accurate

---

## Phase 5 · Receipts

**What gets built:** TASK-015

- File upload to Supabase Storage (JPG, PNG, PDF, 10MB max)
- Receipt metadata table (`receipts`)
- Receipt list screen (searchable, filterable)
- Download to local disk (signed URL → browser download)
- Link receipt to transaction (from receipt list or transaction form)
- Storage usage indicator in Settings

**Acceptance criteria:**
- [ ] Upload works for JPG, PNG, PDF
- [ ] Metadata saved and searchable
- [ ] Download triggers browser file download
- [ ] Receipt linkable to a transaction
- [ ] Storage usage shown in Settings

---

## Completed Phases

*(none yet)*
