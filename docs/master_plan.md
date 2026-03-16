# Master Plan

## What This App Is

Personal Budget App is a web-based family budget tracker that covers both personal and business finances in one place. It gives the Kerby family a single source of truth for tracking income, expenses, and budgets — replacing a spreadsheet workflow with a purpose-built tool accessible from any device.

## The Problem It Solves

Managing a family budget that includes both personal and business transactions in a spreadsheet is error-prone and hard to share. This app gives the family a clean, always-accessible tool where transactions are logged, budgets are set, and spending is visible at a glance — without requiring accounting expertise.

## Core Features (v1)

1. **Track income & expenses** — Log transactions by category, type (personal vs business), and month. Manual entry only.
2. **Budget vs actuals** — Set monthly budgets per category and compare against real spending.
3. **Charts & reports** — Visual summaries of income, spending, and net by month and year.
4. **Receipt management** — Upload receipts to Supabase Storage, download to local disk, searchable/filterable for audit purposes.

## What Success Looks Like (v1 Done)

- Family members can sign in, log transactions, and see their budget status
- Monthly budget vs actual is clearly visible per category
- Charts show meaningful trends across months
- Receipts can be uploaded, found, and downloaded without hunting through folders
- The app works well on both mobile (phone browser) and desktop (laptop browser)

## What This App Is NOT (Explicit Out of Scope for v1)

- No bank sync (Plaid) — manual entry only
- No tax preparation or accountant exports
- No investment tracking or net worth dashboard
- No multi-family/multi-org support — single family only in v1

## References

- [Implementation Plan](implementation_plan.md)
- [Design Guidelines](design_guidelines.md)
- [Data Structure](data_structure.md)
