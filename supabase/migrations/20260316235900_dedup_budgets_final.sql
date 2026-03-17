-- Final dedup: keep lowest id per (org_id, category, subcategory, month).
DELETE FROM budgets
WHERE id NOT IN (
  SELECT DISTINCT ON (org_id, category, subcategory, month) id
  FROM budgets
  ORDER BY org_id, category, subcategory, month, id
);
