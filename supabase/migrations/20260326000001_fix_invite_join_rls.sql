create policy "users can join org via invite code"
  on org_members for insert
  with check (
    profile_id = auth.uid()
    and role = 'member'
    and exists (
      select 1 from organizations
      where id = org_id
        and invite_code is not null
    )
  );
