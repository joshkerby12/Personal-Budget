-- Teller bank integration schema (TASK-018)

-- teller_enrollments
create table teller_enrollments (
  id                    uuid primary key default gen_random_uuid(),
  org_id                uuid not null references organizations(id) on delete cascade,
  profile_id            uuid not null references profiles(id),
  teller_enrollment_id  text not null,
  teller_access_token   text not null,
  institution_name      text not null,
  account_name          text not null,
  account_last_four     text,
  account_type          text not null,
  account_subtype       text,
  last_synced_at        timestamptz,
  is_active             boolean not null default true,
  created_at            timestamptz not null default now()
);

alter table teller_enrollments enable row level security;

create policy "org members can view enrollments"
  on teller_enrollments for select
  using (org_id in (select org_id from org_members where profile_id = auth.uid()));

create policy "user can insert own enrollment"
  on teller_enrollments for insert
  with check (
    profile_id = auth.uid()
    and org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "admin can update enrollment"
  on teller_enrollments for update
  using (org_id in (
    select org_id from org_members
    where profile_id = auth.uid() and role in ('owner', 'admin')
  ));

-- teller_sync_log
create table teller_sync_log (
  id                     uuid primary key default gen_random_uuid(),
  enrollment_id          uuid not null references teller_enrollments(id) on delete cascade,
  synced_at              timestamptz not null default now(),
  transactions_imported  integer not null default 0,
  error                  text
);

alter table teller_sync_log enable row level security;

create policy "org members can view sync log"
  on teller_sync_log for select
  using (
    enrollment_id in (
      select id from teller_enrollments
      where org_id in (select org_id from org_members where profile_id = auth.uid())
    )
  );

-- alter transactions
alter table transactions add column source text not null default 'manual';
alter table transactions add column teller_transaction_id text unique;
