-- Add a partial unique index on (org_id, date, amount, merchant) for teller-sourced
-- transactions. This prevents re-authentication from re-importing the same real
-- transaction even when Teller issues a new teller_transaction_id.
create unique index if not exists transactions_teller_fingerprint_idx
  on transactions (org_id, date, amount, merchant)
  where source = 'teller';
