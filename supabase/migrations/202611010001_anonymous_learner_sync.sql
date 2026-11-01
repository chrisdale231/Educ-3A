-- Create a safe student identity for the learner app's anonymous Auth session.
-- Teacher accounts continue to use email/password and must be assigned by an
-- administrator; client metadata can never promote a learner to teacher.

alter table public.profiles add column if not exists age integer;
alter table public.profiles add column if not exists gender text;

do $$ begin
  alter table public.profiles
    add constraint profiles_age_range check (age is null or age between 5 and 100);
exception when duplicate_object then null;
end $$;

do $$ begin
  alter table public.profiles
    add constraint profiles_gender_values check (gender is null or gender in ('male', 'female'));
exception when duplicate_object then null;
end $$;

create or replace function public.create_student_profile_for_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.is_anonymous is true then
    insert into public.profiles(id, role, display_name)
    values (new.id, 'student', '')
    on conflict (id) do nothing;
  end if;
  return new;
end;
$$;

drop trigger if exists create_student_profile_after_auth_signup on auth.users;
create trigger create_student_profile_after_auth_signup
after insert on auth.users
for each row execute function public.create_student_profile_for_auth_user();

-- Repair anonymous users created before this trigger existed.
insert into public.profiles(id, role, display_name)
select id, 'student', ''
from auth.users
where is_anonymous is true
on conflict (id) do nothing;

-- A learner may update profile fields but never their role.
revoke update on public.profiles from authenticated;
grant update(display_name, age, grade_level, section, gender, updated_at)
  on public.profiles to authenticated;

create or replace function public.apply_student_sync_operation(
  p_operation_id uuid, p_entity_type text, p_entity_id text, p_operation text,
  p_payload jsonb, p_client_updated_at timestamptz)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_user uuid := auth.uid(); v_class uuid; v_session uuid; v_quiz uuid;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if not exists(select 1 from profiles where id=v_user and role='student') then
    raise exception 'Student account required';
  end if;
  if exists(select 1 from sync_operations where operation_id=p_operation_id and user_id=v_user) then
    return jsonb_build_object('status','duplicate','operation_id',p_operation_id);
  end if;

  -- Profile setup is allowed before class enrollment. Enrollment is a separate
  -- authorized teacher/admin action and controls which teacher can see a learner.
  if p_entity_type='learner_profile' then
    update profiles set
      display_name=coalesce(p_payload->>'name',display_name),
      age=coalesce(nullif(p_payload->>'age','')::integer,age),
      grade_level=coalesce(p_payload->>'grade_level',grade_level),
      section=coalesce(p_payload->>'section',section),
      gender=coalesce(p_payload->>'gender',gender),
      updated_at=p_client_updated_at
    where id=v_user
      and (updated_at <= p_client_updated_at or display_name = '');

    insert into sync_operations values(
      p_operation_id,v_user,p_entity_type,p_entity_id,p_operation,
      p_client_updated_at,now()
    );
    return jsonb_build_object('status','applied','operation_id',p_operation_id);
  end if;

  select class_id into v_class from class_enrollments
  where student_id=v_user order by enrolled_at limit 1;
  if v_class is null then raise exception 'Student is not enrolled in a class'; end if;

  if p_entity_type in ('quiz_attempt','game_attempt','simulation_attempt','concept_progress') then
    select id into v_session from sessions where class_id=v_class
      and session_number=coalesce((p_payload->>'session_number')::integer,(p_payload->>'session')::integer,1);
    insert into activity_events(client_event_id,student_id,class_id,session_id,activity_type,score,total,payload,occurred_at)
    values(p_entity_id::uuid,v_user,v_class,v_session,
      case p_entity_type when 'quiz_attempt' then 'quiz' when 'game_attempt' then 'game' when 'simulation_attempt' then 'simulation' else 'concept' end,
      nullif(p_payload->>'score','')::integer,nullif(p_payload->>'total','')::integer,p_payload,
      coalesce((p_payload->>'occurred_at')::timestamptz,(p_payload->>'completed_at')::timestamptz,p_client_updated_at))
    on conflict(client_event_id) do nothing;
    if v_session is not null then
      insert into student_progress(student_id,session_id,completion_percent,updated_at)
      values(v_user,v_session,least(100,greatest(0,coalesce(
        nullif(p_payload->>'completion_percent','')::integer,
        case when nullif(p_payload->>'total','')::integer > 0
          then (100 * nullif(p_payload->>'score','')::integer / nullif(p_payload->>'total','')::integer)
          else 0 end))),p_client_updated_at)
      on conflict(student_id,session_id) do update set
        completion_percent=greatest(student_progress.completion_percent,excluded.completion_percent),
        updated_at=greatest(student_progress.updated_at,excluded.updated_at);
    end if;
    if p_entity_type='quiz_attempt' then
      select q.id into v_quiz from quizzes q where q.session_id=v_session and q.is_published
      order by q.updated_at desc limit 1;
      if v_quiz is not null then
        insert into submissions(client_submission_id,quiz_id,class_id,student_id,score,total,submitted_at)
        values(p_entity_id::uuid,v_quiz,v_class,v_user,(p_payload->>'score')::integer,(p_payload->>'total')::integer,
          coalesce((p_payload->>'occurred_at')::timestamptz,(p_payload->>'completed_at')::timestamptz,p_client_updated_at))
        on conflict(client_submission_id) do nothing;
      end if;
    end if;
  else
    raise exception 'Unsupported entity type: %', p_entity_type;
  end if;
  insert into sync_operations values(p_operation_id,v_user,p_entity_type,p_entity_id,p_operation,p_client_updated_at,now());
  return jsonb_build_object('status','applied','operation_id',p_operation_id);
end $$;

grant execute on function public.apply_student_sync_operation(uuid,text,text,text,jsonb,timestamptz)
  to authenticated;
