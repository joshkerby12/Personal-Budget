-- Add sort_order to budgets table for user-defined subcategory ordering
alter table budgets add column if not exists sort_order integer not null default 0;
