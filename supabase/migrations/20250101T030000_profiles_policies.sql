-- Profiles RLS policies: self read/update/insert

alter table public.profiles enable row level security;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and polname = 'profiles_self_select'
  ) then
    create policy profiles_self_select on public.profiles for select using (id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and polname = 'profiles_self_update'
  ) then
    create policy profiles_self_update on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
  end if;
end $$;

do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'profiles' and polname = 'profiles_self_insert'
  ) then
    create policy profiles_self_insert on public.profiles for insert with check (id = auth.uid());
  end if;
end $$;

