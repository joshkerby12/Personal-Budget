create or replace function public.is_org_member(target_org_id uuid, target_profile_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.org_members
    where org_id = target_org_id
      and profile_id = target_profile_id
  );
$$;

create or replace function public.is_org_admin(target_org_id uuid, target_profile_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.org_members
    where org_id = target_org_id
      and profile_id = target_profile_id
      and role in ('owner', 'admin')
  );
$$;

grant execute on function public.is_org_member(uuid, uuid) to authenticated;
grant execute on function public.is_org_admin(uuid, uuid) to authenticated;

drop policy if exists "org members can view org membership" on org_members;
drop policy if exists "org admins can add members" on org_members;
drop policy if exists "allow self insert as owner on org create" on org_members;
drop policy if exists "org admins can update member roles" on org_members;

create policy "org members can view org membership"
  on org_members for select
  using (
    auth.uid() is not null
    and public.is_org_member(org_id, auth.uid())
  );

create policy "org admins can add members"
  on org_members for insert
  with check (
    auth.uid() is not null
    and public.is_org_admin(org_id, auth.uid())
  );

create policy "allow self insert as owner on org create"
  on org_members for insert
  with check (
    profile_id = auth.uid()
    and role = 'owner'
  );

create policy "org admins can update member roles"
  on org_members for update
  using (
    auth.uid() is not null
    and public.is_org_admin(org_id, auth.uid())
  )
  with check (
    auth.uid() is not null
    and public.is_org_admin(org_id, auth.uid())
  );
