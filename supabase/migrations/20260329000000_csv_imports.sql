create table if not exists csv_import_logs (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  created_by uuid not null references profiles(id),
  institution text not null,
  filename text not null,
  imported_at timestamptz not null default now(),
  transaction_count int not null default 0
);

create table if not exists csv_import_transactions (
  id uuid primary key default gen_random_uuid(),
  import_log_id uuid not null references csv_import_logs(id) on delete cascade,
  transaction_id uuid not null references transactions(id) on delete cascade
);

alter table transactions
  add column if not exists csv_import_log_id uuid references csv_import_logs(id) on delete set null;

alter table csv_import_logs enable row level security;
alter table csv_import_transactions enable row level security;

drop policy if exists "org members can manage csv_import_logs" on csv_import_logs;
create policy "org members can manage csv_import_logs"
  on csv_import_logs for all
  using (
    org_id in (
      select org_id from org_members where profile_id = auth.uid()
    )
  )
  with check (
    org_id in (
      select org_id from org_members where profile_id = auth.uid()
    )
  );

drop policy if exists "org members can manage csv_import_transactions" on csv_import_transactions;
create policy "org members can manage csv_import_transactions"
  on csv_import_transactions for all
  using (
    import_log_id in (
      select id from csv_import_logs
      where org_id in (
        select org_id from org_members where profile_id = auth.uid()
      )
    )
  )
  with check (
    import_log_id in (
      select id from csv_import_logs
      where org_id in (
        select org_id from org_members where profile_id = auth.uid()
      )
    )
  );
