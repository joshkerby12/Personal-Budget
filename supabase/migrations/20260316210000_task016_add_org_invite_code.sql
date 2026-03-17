alter table organizations
  add column if not exists invite_code text;

create or replace function public.generate_org_invite_code()
returns text
language plpgsql
as $$
declare
  characters text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  generated_code text;
begin
  loop
    generated_code := '';
    for i in 1..6 loop
      generated_code := generated_code
        || substr(characters, floor(random() * length(characters) + 1)::integer, 1);
    end loop;

    exit when not exists (
      select 1
      from organizations
      where invite_code = generated_code
    );
  end loop;

  return generated_code;
end;
$$;

update organizations
set invite_code = public.generate_org_invite_code()
where invite_code is null or btrim(invite_code) = '';

alter table organizations
  alter column invite_code set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'organizations_invite_code_key'
  ) then
    alter table organizations
      add constraint organizations_invite_code_key unique (invite_code);
  end if;
end
$$;

drop policy if exists "authenticated users can look up org by invite code"
  on organizations;

create policy "authenticated users can look up org by invite code"
  on organizations for select
  using (auth.uid() is not null);
