-- Hard dedup using ctid (physical row identifier), bypassing RLS.
alter table budgets disable row level security;

DELETE FROM budgets b1
WHERE b1.ctid <> (
  SELECT MIN(b2.ctid)
  FROM budgets b2
  WHERE b2.org_id = b1.org_id
    AND b2.category = b1.category
    AND b2.subcategory = b1.subcategory
    AND (b2.month = b1.month OR (b2.month IS NULL AND b1.month IS NULL))
);

alter table budgets enable row level security;
