-- Disable RLS temporarily to delete duplicates as superuser.
alter table budgets disable row level security;

DELETE FROM budgets
WHERE id NOT IN (
  SELECT DISTINCT ON (org_id, category, subcategory, month) id
  FROM budgets
  ORDER BY org_id, category, subcategory, month, id
);

alter table budgets enable row level security;
