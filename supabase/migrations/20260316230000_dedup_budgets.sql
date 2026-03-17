-- Remove duplicate budget rows, keeping the one with the lowest id per (org_id, category, subcategory, month).
-- Duplicates were created by a race condition in ensureGlobalDefaults that has since been fixed.
DELETE FROM budgets
WHERE id NOT IN (
  SELECT DISTINCT ON (org_id, category, subcategory, month) id
  FROM budgets
  ORDER BY org_id, category, subcategory, month, id
);
