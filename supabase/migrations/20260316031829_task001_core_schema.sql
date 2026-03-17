create table organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_at  timestamptz not null default now()
);

alter table organizations enable row level security;

create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  avatar_url  text,
  created_at  timestamptz not null default now()
);

alter table profiles enable row level security;

create table org_members (
  id          uuid primary key default gen_random_uuid(),
  org_id      uuid not null references organizations(id) on delete cascade,
  profile_id  uuid not null references profiles(id) on delete cascade,
  role        text not null check (role in ('owner', 'admin', 'member')),
  created_at  timestamptz not null default now(),
  unique (org_id, profile_id)
);

alter table org_members enable row level security;

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

create policy "org members can view their org"
  on organizations for select
  using (
    id in (
      select org_id from org_members
      where profile_id = auth.uid()
    )
  );

create policy "org admins can update their org"
  on organizations for update
  using (
    id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );

create policy "authenticated users can create orgs"
  on organizations for insert
  with check (auth.uid() is not null);

create policy "users can view own profile"
  on profiles for select
  using (id = auth.uid());

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

create policy "users can update own profile"
  on profiles for update
  using (id = auth.uid());

create policy "org members can view org membership"
  on org_members for select
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
    )
  );

create policy "org admins can add members"
  on org_members for insert
  with check (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );

create policy "allow self insert as owner on org create"
  on org_members for insert
  with check (profile_id = auth.uid());

create policy "org admins can update member roles"
  on org_members for update
  using (
    org_id in (
      select org_id from org_members
      where profile_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );
