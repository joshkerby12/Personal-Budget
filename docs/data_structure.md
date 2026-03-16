# Data Structure

Full Supabase schema. Run this SQL in the Supabase SQL editor.

---

## Org / User Architecture

Every table in this app (except `organizations`, `profiles`, and `org_members`) must have an `org_id` column that references `organizations.id`. No query may return data without an org scope.

- `organizations` — one row per family/org
- `profiles` — 1:1 with `auth.users`, auto-created via trigger on sign-up
- `org_members` — junction table: which profile belongs to which org, with what role

Roles: `owner | admin | member`

---

## Core Tables

### `organizations`

```sql
create table organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_at  timestamptz not null default now()
);

alter table organizations enable row level security;
```

### `profiles`

```sql
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

alter table profiles enable row level security;
```

### `org_members`

```sql
create table org_members (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references organizations(id) on delete cascade,
  profile_id  uuid not null references profiles(id) on delete cascade,
  role        text not null check (role in ('owner', 'admin', 'member')),
  created_at  timestamptz not null default now(),
  unique (org_id, profile_id)
);

alter table org_members enable row level security;
```

---

## Auto-Create Profile Trigger

Runs automatically when a new user signs up via Supabase Auth.

```sql
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

---

## RLS Policies

### `organizations`

```sql
-- Members of an org can view it
create policy "org members can view their org"
  on organizations for select
  using (
    id in (
      select org_id from org_members
      where profile_id = auth.uid()
    )
  );

-- Owners/admins can update their org
create policy "org admins can update their org"
  on organizations for update
  using (
    id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );

-- Anyone authenticated can create an org (during onboarding)
create policy "authenticated users can create orgs"
  on organizations for insert
  with check (auth.uid() is not null);
```

### `profiles`

```sql
-- Users can view their own profile
create policy "users can view own profile"
  on profiles for select
  using (id = auth.uid());

-- Users can view profiles of org members in shared orgs
create policy "org members can view each other profiles"
  on profiles for select
  using (
    id in (
      select profile_id from org_members
      where org_id in (
        select org_id from org_members
        where profile_id = auth.uid()
      )
    )
  );

-- Users can update their own profile
create policy "users can update own profile"
  on profiles for update
  using (id = auth.uid());
```

### `org_members`

```sql
-- Members can view their org's member list
create policy "org members can view org membership"
  on org_members for select
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
    )
  );

-- Owners/admins can insert new members
create policy "org admins can add members"
  on org_members for insert
  with check (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );

-- Allow inserting self as owner during org creation
create policy "allow self insert as owner on org create"
  on org_members for insert
  with check (profile_id = auth.uid());

-- Owners/admins can update member roles
create policy "org admins can update member roles"
  on org_members for update
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );
```

---

## Project-Specific Tables

Run all SQL below in the Supabase SQL editor as part of TASK-001.

---

### `categories` ← Phase 2

```sql
create table categories (
  id               uuid primary key default gen_random_uuid(),
  org_id           uuid not null references organizations(id) on delete cascade,
  parent_category  text not null,
  subcategory      text not null,
  sort_order       integer not null default 0,
  created_at       timestamptz not null default now(),
  unique (org_id, parent_category, subcategory)
);

alter table categories enable row level security;

-- Org members can view categories
create policy "org members can view categories"
  on categories for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can insert categories
create policy "org members can insert categories"
  on categories for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can update categories
create policy "org members can update categories"
  on categories for update
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Admins/owners can delete categories
create policy "org admins can delete categories"
  on categories for delete
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

### `app_settings` ← Phase 2

```sql
create table app_settings (
  id                uuid primary key default gen_random_uuid(),
  org_id            uuid not null unique references organizations(id) on delete cascade,
  irs_rate_per_mile numeric(6,4) not null default 0.6700,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

alter table app_settings enable row level security;

-- Org members can view settings
create policy "org members can view app settings"
  on app_settings for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org admins can insert settings
create policy "org admins can insert app settings"
  on app_settings for insert
  with check (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

-- Org admins can update settings
create policy "org admins can update app settings"
  on app_settings for update
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

### `budgets` ← Phase 2

`month` is nullable — null = global default; non-null (first day of month) = per-month override.

```sql
create table budgets (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references organizations(id) on delete cascade,
  category        text not null,
  subcategory     text not null,
  monthly_amount  numeric(12,2) not null default 0,
  default_biz_pct numeric(5,4) not null default 0,  -- 0.0 to 1.0 (e.g. 0.75 = 75%)
  month           date,  -- null = global default; '2026-01-01' = January override
  created_at      timestamptz not null default now(),
  unique (org_id, category, subcategory, month)
);

alter table budgets enable row level security;

-- Org members can view budgets
create policy "org members can view budgets"
  on budgets for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can insert budgets
create policy "org members can insert budgets"
  on budgets for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can update budgets
create policy "org members can update budgets"
  on budgets for update
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Admins/owners can delete budgets
create policy "org admins can delete budgets"
  on budgets for delete
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

### `transactions` ← Phase 2

```sql
create table transactions (
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
  receipt_id   uuid,  -- FK added after receipts table created
  notes        text,
  created_at   timestamptz not null default now()
);

alter table transactions enable row level security;

-- Org members can view transactions
create policy "org members can view transactions"
  on transactions for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can insert transactions
create policy "org members can insert transactions"
  on transactions for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Creator or admin can update
create policy "creator or admin can update transactions"
  on transactions for update
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

-- Creator or admin can delete
create policy "creator or admin can delete transactions"
  on transactions for delete
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

### `mileage_trips` ← Phase 4

```sql
create table mileage_trips (
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

-- Org members can view mileage
create policy "org members can view mileage"
  on mileage_trips for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can insert mileage
create policy "org members can insert mileage"
  on mileage_trips for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Creator or admin can update
create policy "creator or admin can update mileage"
  on mileage_trips for update
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

-- Creator or admin can delete
create policy "creator or admin can delete mileage"
  on mileage_trips for delete
  using (
    created_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

### `receipts` ← Phase 5

```sql
create table receipts (
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

-- Add FK from transactions to receipts (run after both tables exist)
alter table transactions
  add constraint transactions_receipt_id_fkey
  foreign key (receipt_id) references receipts(id) on delete set null;

alter table receipts enable row level security;

-- Org members can view receipts
create policy "org members can view receipts"
  on receipts for select
  using (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Org members can insert receipts
create policy "org members can insert receipts"
  on receipts for insert
  with check (
    org_id in (select org_id from org_members where profile_id = auth.uid())
  );

-- Uploader or admin can update
create policy "uploader or admin can update receipts"
  on receipts for update
  using (
    uploaded_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );

-- Uploader or admin can delete
create policy "uploader or admin can delete receipts"
  on receipts for delete
  using (
    uploaded_by = auth.uid()
    or org_id in (
      select org_id from org_members
      where profile_id = auth.uid() and role in ('owner', 'admin')
    )
  );
```

---

## Storage Buckets

### `receipts` bucket

- Bucket name: `receipts`
- Access: private (authenticated only)
- Max file size: 10MB per file
- Allowed types: image/jpeg, image/png, application/pdf
- Storage path pattern: `{org_id}/{receipt_id}/{file_name}`

Create in Supabase dashboard → Storage → New bucket → `receipts`, private.

---

## Notes

- Supabase free plan: 1GB storage — use wisely for receipts
- Receipt download: retrieve signed URL from Supabase Storage, trigger browser download to local disk
- All money amounts stored as `numeric(12,2)` — never `float`
- All dates stored as `date` (not `timestamptz`) for budget/transaction dates; `timestamptz` for `created_at`
