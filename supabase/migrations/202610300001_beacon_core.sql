-- BEACON shared backend. Apply with `supabase db push`.
create extension if not exists pgcrypto;

do $$ begin
  create type public.user_role as enum ('student', 'teacher');
exception when duplicate_object then null;
end $$;
do $$ begin
  create type public.submission_status as enum ('submitted', 'graded');
exception when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.user_role not null,
  display_name text not null default '',
  grade_level text,
  section text,
  updated_at timestamptz not null default now()
);
create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  grade_level text not null default '11',
  school_year text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.class_teachers (
  class_id uuid references public.classes(id) on delete cascade,
  teacher_id uuid references public.profiles(id) on delete cascade,
  primary key (class_id, teacher_id)
);
create table if not exists public.class_enrollments (
  class_id uuid references public.classes(id) on delete cascade,
  student_id uuid references public.profiles(id) on delete cascade,
  enrolled_at timestamptz not null default now(),
  primary key (class_id, student_id)
);
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.classes(id) on delete cascade,
  session_number integer not null check (session_number between 1 and 8),
  title text not null,
  is_published boolean not null default false,
  revision integer not null default 1,
  updated_at timestamptz not null default now(),
  unique (class_id, session_number)
);
create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  title text not null,
  summary text not null default '',
  content jsonb not null default '{}'::jsonb,
  revision integer not null default 1,
  is_published boolean not null default false,
  published_at timestamptz,
  updated_at timestamptz not null default now()
);
create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  title text not null,
  instructions text not null default '',
  passing_score integer not null default 6,
  is_published boolean not null default false,
  revision integer not null default 1,
  published_at timestamptz,
  updated_at timestamptz not null default now()
);
create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  quiz_id uuid not null references public.quizzes(id) on delete cascade,
  prompt text not null,
  position integer not null,
  explanation text not null default '',
  unique (quiz_id, position)
);
create table if not exists public.quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  label text not null,
  position integer not null,
  unique (question_id, position)
);
create table if not exists public.quiz_answer_keys (
  question_id uuid primary key references public.quiz_questions(id) on delete cascade,
  correct_option_id uuid not null references public.quiz_options(id) on delete cascade
);
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  client_submission_id uuid not null unique,
  quiz_id uuid not null references public.quizzes(id),
  class_id uuid not null references public.classes(id),
  student_id uuid not null references public.profiles(id),
  score integer not null,
  total integer not null check (total > 0),
  status public.submission_status not null default 'submitted',
  submitted_at timestamptz not null,
  synced_at timestamptz not null default now(),
  graded_at timestamptz
);
create table if not exists public.submission_answers (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null references public.submissions(id) on delete cascade,
  question_id uuid not null references public.quiz_questions(id),
  selected_option_id uuid references public.quiz_options(id),
  answer_text text,
  is_correct boolean not null,
  unique (submission_id, question_id)
);
create table if not exists public.activity_events (
  id uuid primary key default gen_random_uuid(),
  client_event_id uuid not null unique,
  student_id uuid not null references public.profiles(id),
  class_id uuid not null references public.classes(id),
  session_id uuid references public.sessions(id),
  activity_type text not null check (activity_type in ('concept','simulation','game','quiz')),
  score integer,
  total integer,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null,
  synced_at timestamptz not null default now()
);
create table if not exists public.student_progress (
  student_id uuid not null references public.profiles(id) on delete cascade,
  session_id uuid not null references public.sessions(id) on delete cascade,
  completion_percent integer not null default 0 check (completion_percent between 0 and 100),
  updated_at timestamptz not null default now(),
  primary key (student_id, session_id)
);
create table if not exists public.sync_operations (
  operation_id uuid not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  entity_type text not null,
  entity_id text not null,
  operation text not null,
  client_updated_at timestamptz not null,
  applied_at timestamptz not null default now(),
  primary key (operation_id, user_id)
);

create index if not exists class_teachers_teacher_idx on public.class_teachers(teacher_id);
create index if not exists enrollments_student_idx on public.class_enrollments(student_id);
create index if not exists sessions_class_idx on public.sessions(class_id, is_published);
create index if not exists submissions_student_idx on public.submissions(student_id, submitted_at desc);
create index if not exists submissions_class_idx on public.submissions(class_id, submitted_at desc);
create index if not exists activity_student_idx on public.activity_events(student_id, occurred_at desc);

create or replace function public.is_teacher_of_class(p_class uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from class_teachers where class_id=p_class and teacher_id=auth.uid()) $$;
create or replace function public.is_student_of_class(p_class uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from class_enrollments where class_id=p_class and student_id=auth.uid()) $$;

alter table public.profiles enable row level security;
alter table public.classes enable row level security;
alter table public.class_teachers enable row level security;
alter table public.class_enrollments enable row level security;
alter table public.sessions enable row level security;
alter table public.lessons enable row level security;
alter table public.quizzes enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_options enable row level security;
alter table public.quiz_answer_keys enable row level security;
alter table public.submissions enable row level security;
alter table public.submission_answers enable row level security;
alter table public.activity_events enable row level security;
alter table public.student_progress enable row level security;
alter table public.sync_operations enable row level security;

drop policy if exists profile_self_or_assigned_teacher on public.profiles;
drop policy if exists profile_self_update on public.profiles;
drop policy if exists class_member_read on public.classes;
drop policy if exists class_teacher_links_read on public.class_teachers;
drop policy if exists enrollment_member_read on public.class_enrollments;
drop policy if exists sessions_member_read on public.sessions;
drop policy if exists sessions_teacher_write on public.sessions;
drop policy if exists lessons_member_read on public.lessons;
drop policy if exists lessons_teacher_write on public.lessons;
drop policy if exists quizzes_member_read on public.quizzes;
drop policy if exists quizzes_teacher_write on public.quizzes;
drop policy if exists questions_member_read on public.quiz_questions;
drop policy if exists questions_teacher_write on public.quiz_questions;
drop policy if exists options_member_read on public.quiz_options;
drop policy if exists options_teacher_write on public.quiz_options;
drop policy if exists answer_keys_teacher_read on public.quiz_answer_keys;
drop policy if exists answer_keys_teacher_write on public.quiz_answer_keys;
drop policy if exists submissions_read on public.submissions;
drop policy if exists submissions_teacher_grade on public.submissions;
drop policy if exists answers_read on public.submission_answers;
drop policy if exists activity_read on public.activity_events;
drop policy if exists progress_read on public.student_progress;
drop policy if exists sync_own_read on public.sync_operations;

create policy profile_self_or_assigned_teacher on public.profiles for select using (
  id=auth.uid() or exists(select 1 from class_enrollments e join class_teachers t using(class_id)
    where e.student_id=profiles.id and t.teacher_id=auth.uid()));
create policy profile_self_update on public.profiles for update using (id=auth.uid()) with check (id=auth.uid());
create policy class_member_read on public.classes for select using (is_teacher_of_class(id) or is_student_of_class(id));
create policy class_teacher_links_read on public.class_teachers for select using (teacher_id=auth.uid() or is_student_of_class(class_id));
create policy enrollment_member_read on public.class_enrollments for select using (student_id=auth.uid() or is_teacher_of_class(class_id));
create policy sessions_member_read on public.sessions for select using (is_teacher_of_class(class_id) or (is_student_of_class(class_id) and is_published));
create policy sessions_teacher_write on public.sessions for all using (is_teacher_of_class(class_id)) with check (is_teacher_of_class(class_id));
create policy lessons_member_read on public.lessons for select using (exists(select 1 from sessions s where s.id=session_id and (is_teacher_of_class(s.class_id) or (is_student_of_class(s.class_id) and lessons.is_published))));
create policy lessons_teacher_write on public.lessons for all using (exists(select 1 from sessions s where s.id=session_id and is_teacher_of_class(s.class_id))) with check (exists(select 1 from sessions s where s.id=session_id and is_teacher_of_class(s.class_id)));
create policy quizzes_member_read on public.quizzes for select using (exists(select 1 from sessions s where s.id=session_id and (is_teacher_of_class(s.class_id) or (is_student_of_class(s.class_id) and quizzes.is_published))));
create policy quizzes_teacher_write on public.quizzes for all using (exists(select 1 from sessions s where s.id=session_id and is_teacher_of_class(s.class_id))) with check (exists(select 1 from sessions s where s.id=session_id and is_teacher_of_class(s.class_id)));
create policy questions_member_read on public.quiz_questions for select using (exists(select 1 from quizzes q join sessions s on s.id=q.session_id where q.id=quiz_id and (is_teacher_of_class(s.class_id) or (is_student_of_class(s.class_id) and q.is_published))));
create policy questions_teacher_write on public.quiz_questions for all using (exists(select 1 from quizzes q join sessions s on s.id=q.session_id where q.id=quiz_id and is_teacher_of_class(s.class_id))) with check (exists(select 1 from quizzes q join sessions s on s.id=q.session_id where q.id=quiz_id and is_teacher_of_class(s.class_id)));
create policy options_member_read on public.quiz_options for select using (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and (is_teacher_of_class(s.class_id) or (is_student_of_class(s.class_id) and q.is_published))));
create policy options_teacher_write on public.quiz_options for all using (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and is_teacher_of_class(s.class_id))) with check (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and is_teacher_of_class(s.class_id)));
create policy answer_keys_teacher_read on public.quiz_answer_keys for select using (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and is_teacher_of_class(s.class_id)));
create policy answer_keys_teacher_write on public.quiz_answer_keys for all using (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and is_teacher_of_class(s.class_id))) with check (exists(select 1 from quiz_questions qq join quizzes q on q.id=qq.quiz_id join sessions s on s.id=q.session_id where qq.id=question_id and is_teacher_of_class(s.class_id)));
create policy submissions_read on public.submissions for select using (student_id=auth.uid() or is_teacher_of_class(class_id));
create policy submissions_teacher_grade on public.submissions for update using (is_teacher_of_class(class_id)) with check (is_teacher_of_class(class_id));
create policy answers_read on public.submission_answers for select using (exists(select 1 from submissions s where s.id=submission_id and (s.student_id=auth.uid() or is_teacher_of_class(s.class_id))));
create policy activity_read on public.activity_events for select using (student_id=auth.uid() or is_teacher_of_class(class_id));
create policy progress_read on public.student_progress for select using (student_id=auth.uid() or exists(select 1 from sessions s where s.id=session_id and is_teacher_of_class(s.class_id)));
create policy sync_own_read on public.sync_operations for select using (user_id=auth.uid());

-- Idempotent ingestion point. Attempts are append-only; duplicate UUIDs are acknowledged.
-- Profiles use last-write-wins by client timestamp. Published lesson content is server-authoritative.
create or replace function public.apply_student_sync_operation(
  p_operation_id uuid, p_entity_type text, p_entity_id text, p_operation text,
  p_payload jsonb, p_client_updated_at timestamptz)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_user uuid := auth.uid(); v_class uuid; v_session uuid; v_quiz uuid;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if not exists(select 1 from profiles where id=v_user and role='student') then raise exception 'Student account required'; end if;
  if exists(select 1 from sync_operations where operation_id=p_operation_id and user_id=v_user) then
    return jsonb_build_object('status','duplicate','operation_id',p_operation_id);
  end if;
  select class_id into v_class from class_enrollments where student_id=v_user order by enrolled_at limit 1;
  if v_class is null then raise exception 'Student is not enrolled in a class'; end if;

  if p_entity_type='learner_profile' then
    update profiles set display_name=coalesce(p_payload->>'name',display_name),
      grade_level=coalesce(p_payload->>'grade_level',grade_level), section=coalesce(p_payload->>'section',section),
      updated_at=p_client_updated_at where id=v_user and updated_at <= p_client_updated_at;
  elsif p_entity_type in ('quiz_attempt','game_attempt','simulation_attempt','concept_progress') then
    select id into v_session from sessions where class_id=v_class and session_number=coalesce((p_payload->>'session_number')::integer,(p_payload->>'session')::integer,1);
    insert into activity_events(client_event_id,student_id,class_id,session_id,activity_type,score,total,payload,occurred_at)
    values(p_entity_id::uuid,v_user,v_class,v_session,
      case p_entity_type when 'quiz_attempt' then 'quiz' when 'game_attempt' then 'game' when 'simulation_attempt' then 'simulation' else 'concept' end,
      nullif(p_payload->>'score','')::integer,nullif(p_payload->>'total','')::integer,p_payload,
      coalesce((p_payload->>'occurred_at')::timestamptz,(p_payload->>'completed_at')::timestamptz,p_client_updated_at)) on conflict(client_event_id) do nothing;
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
      select q.id into v_quiz from quizzes q where q.session_id=v_session and q.is_published order by q.updated_at desc limit 1;
      if v_quiz is not null then
        insert into submissions(client_submission_id,quiz_id,class_id,student_id,score,total,submitted_at)
        values(p_entity_id::uuid,v_quiz,v_class,v_user,(p_payload->>'score')::integer,(p_payload->>'total')::integer,
          coalesce((p_payload->>'occurred_at')::timestamptz,(p_payload->>'completed_at')::timestamptz,p_client_updated_at)) on conflict(client_submission_id) do nothing;
      end if;
    end if;
  else
    raise exception 'Unsupported entity type: %', p_entity_type;
  end if;
  insert into sync_operations values(p_operation_id,v_user,p_entity_type,p_entity_id,p_operation,p_client_updated_at,now());
  return jsonb_build_object('status','applied','operation_id',p_operation_id);
end $$;
grant execute on function public.apply_student_sync_operation(uuid,text,text,text,jsonb,timestamptz) to authenticated;

-- Teacher changes are accepted only for assigned classes. If a newer server edit
-- already exists, the older offline edit is acknowledged as a conflict instead
-- of overwriting it. Replayed operation UUIDs are safe.
create or replace function public.apply_teacher_sync_operation(
  p_operation_id uuid, p_entity_type text, p_entity_id uuid,
  p_payload jsonb, p_client_updated_at timestamptz)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_user uuid := auth.uid(); v_changed integer := 0;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if not exists(select 1 from profiles where id=v_user and role='teacher') then
    raise exception 'Teacher account required';
  end if;
  if exists(select 1 from sync_operations where operation_id=p_operation_id and user_id=v_user) then
    return jsonb_build_object('status','duplicate','operation_id',p_operation_id);
  end if;

  if p_entity_type='lesson' then
    if not exists(select 1 from lessons l join sessions s on s.id=l.session_id
      where l.id=p_entity_id and is_teacher_of_class(s.class_id)) then
      raise exception 'Lesson is not assigned to this teacher';
    end if;
    update lessons l set
      is_published=coalesce((p_payload->>'is_published')::boolean,l.is_published),
      published_at=case when coalesce((p_payload->>'is_published')::boolean,l.is_published)
        then coalesce(l.published_at,now()) else null end,
      revision=greatest(l.revision+1,coalesce((p_payload->>'revision')::integer,l.revision+1)),
      updated_at=p_client_updated_at
    from sessions s where l.id=p_entity_id and s.id=l.session_id
      and is_teacher_of_class(s.class_id)
      and (l.updated_at < p_client_updated_at or
        (l.updated_at = p_client_updated_at and l.revision <= coalesce((p_payload->>'revision')::integer,0)));
    get diagnostics v_changed = row_count;
  elsif p_entity_type='quiz' then
    if not exists(select 1 from quizzes q join sessions s on s.id=q.session_id
      where q.id=p_entity_id and is_teacher_of_class(s.class_id)) then
      raise exception 'Quiz is not assigned to this teacher';
    end if;
    update quizzes q set
      is_published=coalesce((p_payload->>'is_published')::boolean,q.is_published),
      published_at=case when coalesce((p_payload->>'is_published')::boolean,q.is_published)
        then coalesce(q.published_at,now()) else null end,
      revision=greatest(q.revision+1,coalesce((p_payload->>'revision')::integer,q.revision+1)),
      updated_at=p_client_updated_at
    from sessions s where q.id=p_entity_id and s.id=q.session_id
      and is_teacher_of_class(s.class_id)
      and (q.updated_at < p_client_updated_at or
        (q.updated_at = p_client_updated_at and q.revision <= coalesce((p_payload->>'revision')::integer,0)));
    get diagnostics v_changed = row_count;
  else
    raise exception 'Unsupported entity type: %', p_entity_type;
  end if;

  insert into sync_operations values(
    p_operation_id,v_user,p_entity_type,p_entity_id::text,'update',
    p_client_updated_at,now());
  return jsonb_build_object(
    'status',case when v_changed=1 then 'applied' else 'server_newer' end,
    'operation_id',p_operation_id);
end $$;
grant execute on function public.apply_teacher_sync_operation(uuid,text,uuid,jsonb,timestamptz) to authenticated;

