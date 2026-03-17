create table if not exists teller_enrollments (
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

drop policy if exists "org members can view enrollments" on teller_enrollments;
drop policy if exists "user can insert own enrollment" on teller_enrollments;
drop policy if exists "admin can update enrollment" on teller_enrollments;

create policy "org members can view enrollments"
  on teller_enrollments for select
  using (
    auth.uid() is not null
    and public.is_org_member(org_id, auth.uid())
  );

create policy "user can insert own enrollment"
  on teller_enrollments for insert
  with check (
    profile_id = auth.uid()
    and public.is_org_member(org_id, auth.uid())
  );

create policy "admin can update enrollment"
  on teller_enrollments for update
  using (
    auth.uid() is not null
    and public.is_org_admin(org_id, auth.uid())
  )
  with check (
    auth.uid() is not null
    and public.is_org_admin(org_id, auth.uid())
  );

create table if not exists teller_sync_log (
  id                     uuid primary key default gen_random_uuid(),
  enrollment_id          uuid not null references teller_enrollments(id) on delete cascade,
  synced_at              timestamptz not null default now(),
  transactions_imported  integer not null default 0,
  error                  text
);

alter table teller_sync_log enable row level security;

drop policy if exists "org members can view sync log" on teller_sync_log;

create policy "org members can view sync log"
  on teller_sync_log for select
  using (
    enrollment_id in (
      select te.id
      from teller_enrollments te
      where auth.uid() is not null
        and public.is_org_member(te.org_id, auth.uid())
    )
  );

alter table transactions
  add column if not exists source text not null default 'manual';

alter table transactions
  add column if not exists teller_transaction_id text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'transactions_teller_transaction_id_key'
  ) then
    alter table transactions
      add constraint transactions_teller_transaction_id_key
      unique (teller_transaction_id);
  end if;
end
$$;
