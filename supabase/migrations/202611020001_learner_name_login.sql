create or replace function public.find_learner_profile(p_display_name text)
returns table (
  display_name text,
  age integer,
  grade_level text,
  section text,
  gender text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.display_name,
    p.age,
    p.grade_level,
    p.section,
    p.gender
  from public.profiles p
  where p.role = 'student'
    and lower(trim(p.display_name)) = lower(trim(p_display_name))
    and trim(p.display_name) <> ''
  order by p.updated_at desc, p.id
  limit 1;
$$;

revoke all on function public.find_learner_profile(text) from public;
grant execute on function public.find_learner_profile(text)
  to anon, authenticated;

comment on function public.find_learner_profile(text) is
  'Finds the newest complete learner profile for the BEACON name-only login flow.';
