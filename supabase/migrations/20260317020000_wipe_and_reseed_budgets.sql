-- Wipe all global budget defaults and let the app re-seed on next Reset to Defaults.
alter table budgets disable row level security;
DELETE FROM budgets WHERE month IS NULL;
alter table budgets enable row level security;
