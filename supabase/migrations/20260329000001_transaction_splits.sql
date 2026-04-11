create table transaction_splits (
  id uuid primary key default gen_random_uuid(),
  transaction_id uuid not null references transactions(id) on delete cascade,
  org_id uuid not null references organizations(id) on delete cascade,
  category text not null,
  subcategory text not null,
  amount numeric(12,2) not null,
  biz_pct numeric(5,4) not null default 0,
  created_at timestamptz not null default now()
);

alter table transaction_splits enable row level security;

create policy "org members can manage transaction_splits"
  on transaction_splits for all
  using (org_id in (select org_id from org_members where profile_id = auth.uid()))
  with check (org_id in (select org_id from org_members where profile_id = auth.uid()));
