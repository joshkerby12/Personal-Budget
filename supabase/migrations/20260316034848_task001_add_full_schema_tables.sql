create table if not exists categories (
  id               uuid primary key default gen_random_uuid(),
  org_id           uuid not null references organizations(id) on delete cascade,
  parent_category  text not null,
  subcategory      text not null,
  sort_order       integer not null default 0,
  created_at       timestamptz not null default now(),
  unique (org_id, parent_category, subcategory)
);

alter table categories enable row level security;

drop policy if exists "org members can view categories" on categories;
drop policy if exists "org members can insert categories" on categories;
drop policy if exists "org members can update categories" on categories;
drop policy if exists "org admins can delete categories" on categories;

create policy "org members can view categories"
  on categories for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can insert categories"
  on categories for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can update categories"
  on categories for update
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org admins can delete categories"
  on categories for delete
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create table if not exists app_settings (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null unique references organizations(id) on delete cascade,
  irs_rate_per_mile numeric(6,4) not null default 0.6700,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

alter table app_settings enable row level security;

drop policy if exists "org members can view app settings" on app_settings;
drop policy if exists "org admins can insert app settings" on app_settings;
drop policy if exists "org admins can update app settings" on app_settings;

create policy "org members can view app settings"
  on app_settings for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org admins can insert app settings"
  on app_settings for insert
  with check (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create policy "org admins can update app settings"
  on app_settings for update
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create table if not exists budgets (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references organizations(id) on delete cascade,
  category        text not null,
  subcategory     text not null,
  monthly_amount  numeric(12,2) not null default 0,
  default_biz_pct numeric(5,4) not null default 0,
  month           date,
  created_at      timestamptz not null default now(),
  unique (org_id, category, subcategory, month)
);

alter table budgets enable row level security;

drop policy if exists "org members can view budgets" on budgets;
drop policy if exists "org members can insert budgets" on budgets;
drop policy if exists "org members can update budgets" on budgets;
drop policy if exists "org admins can delete budgets" on budgets;

create policy "org members can view budgets"
  on budgets for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can insert budgets"
  on budgets for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can update budgets"
  on budgets for update
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org admins can delete budgets"
  on budgets for delete
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create table if not exists transactions (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references organizations(id) on delete cascade,
  created_by   uuid not null references profiles(id),
  date         date not null,
  amount       numeric(12,2) not null check (amount > 0),
  merchant     text not null,
  description  text,
  category     text not null,
  subcategory  text not null,
  biz_pct      numeric(5,4) not null default 0 check (biz_pct >= 0 and biz_pct <= 1),
  is_split     boolean not null default false,
  receipt_id   uuid,
  notes        text,
  created_at   timestamptz not null default now()
);

alter table transactions enable row level security;

drop policy if exists "org members can view transactions" on transactions;
drop policy if exists "org members can insert transactions" on transactions;
drop policy if exists "creator or admin can update transactions" on transactions;
drop policy if exists "creator or admin can delete transactions" on transactions;

create policy "org members can view transactions"
  on transactions for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can insert transactions"
  on transactions for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "creator or admin can update transactions"
  on transactions for update
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create policy "creator or admin can delete transactions"
  on transactions for delete
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create table if not exists mileage_trips (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references organizations(id) on delete cascade,
  created_by      uuid not null references profiles(id),
  date            date not null,
  purpose         text not null,
  from_address    text,
  to_address      text,
  one_way_miles   numeric(8,1) not null check (one_way_miles > 0),
  is_round_trip   boolean not null default false,
  biz_pct         numeric(5,4) not null default 1.0,
  category        text,
  created_at      timestamptz not null default now()
);

alter table mileage_trips enable row level security;

drop policy if exists "org members can view mileage" on mileage_trips;
drop policy if exists "org members can insert mileage" on mileage_trips;
drop policy if exists "creator or admin can update mileage" on mileage_trips;
drop policy if exists "creator or admin can delete mileage" on mileage_trips;

create policy "org members can view mileage"
  on mileage_trips for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can insert mileage"
  on mileage_trips for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "creator or admin can update mileage"
  on mileage_trips for update
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create policy "creator or admin can delete mileage"
  on mileage_trips for delete
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create table if not exists receipts (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references organizations(id) on delete cascade,
  transaction_id uuid references transactions(id) on delete set null,
  uploaded_by    uuid not null references profiles(id),
  merchant       text,
  amount         numeric(12,2),
  date           date,
  category       text,
  storage_path   text not null,
  file_name      text not null,
  created_at     timestamptz not null default now()
);

alter table receipts enable row level security;

drop policy if exists "org members can view receipts" on receipts;
drop policy if exists "org members can insert receipts" on receipts;
drop policy if exists "uploader or admin can update receipts" on receipts;
drop policy if exists "uploader or admin can delete receipts" on receipts;

create policy "org members can view receipts"
  on receipts for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "org members can insert receipts"
  on receipts for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

create policy "uploader or admin can update receipts"
  on receipts for update
  using (
    uploaded_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

create policy "uploader or admin can delete receipts"
  on receipts for delete
  using (
    uploaded_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'transactions_receipt_id_fkey'
  ) then
    alter table transactions
      add constraint transactions_receipt_id_fkey
      foreign key (receipt_id) references receipts(id) on delete set null;
  end if;
end $$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'receipts',
  'receipts',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'application/pdf']
)
on conflict (id) do nothing;
