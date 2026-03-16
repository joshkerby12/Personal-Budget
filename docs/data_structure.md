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

*(Added as features are designed — see implementation_plan.md for phase order)*

### `transactions` ← Phase 2

```sql
-- Placeholder — full schema defined when Phase 2 spec is written
create table transactions (
  id           uuid primary key default gen_random_uuid(),
  org_id       uuid not null references organizations(id) on delete cascade,
  created_by   uuid not null references profiles(id),
  amount       numeric(12,2) not null,
  type         text not null check (type in ('income', 'expense')),
  category     text not null,
  finance_type text not null check (finance_type in ('personal', 'business')),
  date         date not null,
  notes        text,
  created_at   timestamptz not null default now()
);

alter table transactions enable row level security;

-- Org members can view transactions
create policy "org members can view transactions"
  on transactions for select
  using (
    org_id in (
      select org_id from org_members where profile_id = auth.uid()
    )
  );

-- Org members can insert transactions
create policy "org members can insert transactions"
  on transactions for insert
  with check (
    org_id in (
      select org_id from org_members where profile_id = auth.uid()
    )
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

### `budgets` ← Phase 3

```sql
-- Placeholder — full schema defined when Phase 3 spec is written
create table budgets (
  id         uuid primary key default gen_random_uuid(),
  org_id     uuid not null references organizations(id) on delete cascade,
  category   text not null,
  month      date not null,  -- stored as first day of month: 2026-01-01
  amount     numeric(12,2) not null,
  created_at timestamptz not null default now(),
  unique (org_id, category, month)
);

alter table budgets enable row level security;
```

### `receipts` ← Phase 5

```sql
-- Placeholder — full schema defined when Phase 5 spec is written
create table receipts (
  id             uuid primary key default gen_random_uuid(),
  org_id         uuid not null references organizations(id) on delete cascade,
  transaction_id uuid references transactions(id) on delete set null,
  uploaded_by    uuid not null references profiles(id),
  merchant       text,
  amount         numeric(12,2),
  date           date,
  category       text,
  storage_path   text not null,  -- Supabase Storage path
  file_name      text not null,
  created_at     timestamptz not null default now()
);

alter table receipts enable row level security;
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
