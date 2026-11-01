-- SAMPLE CONTENT ONLY. Replace titles/content with the approved Grade 11 curriculum.
-- Create Auth users first, then insert their UUIDs into profiles/class memberships.
insert into public.classes (id,name,grade_level,school_year)
values ('10000000-0000-4000-8000-000000000001','Grade 11 - Sample Fluid Mechanics','11','2026-2027')
on conflict do nothing;
insert into public.sessions(class_id,session_number,title,is_published)
select '10000000-0000-4000-8000-000000000001',n,
  (array['Introduction to Fluids','Properties of Fluids','Pressure','Buoyancy','Density','Fluid Flow','Applications','Review and Assessment'])[n],true
from generate_series(1,8) n on conflict do nothing;

insert into public.lessons(id,session_id,title,summary,content,is_published,published_at)
select format('20000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  s.id,s.title,'Sample Grade 11 lesson - replace before production.',
  jsonb_build_object('sample',true,'body','Teacher-approved lesson content goes here.'),
  true,now()
from public.sessions s
where s.class_id='10000000-0000-4000-8000-000000000001'
on conflict(id) do nothing;

insert into public.quizzes(id,session_id,title,instructions,passing_score,is_published,published_at)
select format('30000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  s.id,format('Sample Session %s Quiz',s.session_number),
  'Sample only - replace with approved questions.',6,true,now()
from public.sessions s
where s.class_id='10000000-0000-4000-8000-000000000001'
on conflict(id) do nothing;

insert into public.quiz_questions(id,quiz_id,prompt,position,explanation)
select format('40000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  format('30000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  format('Sample question for Session %s?',s.session_number),1,
  'Sample explanation - replace before production.'
from public.sessions s
where s.class_id='10000000-0000-4000-8000-000000000001'
on conflict(id) do nothing;

insert into public.quiz_options(id,question_id,label,position)
select format('50000000-0000-4000-%s-%s',
    lpad(s.session_number::text,4,'0'),lpad(o.position::text,12,'0'))::uuid,
  format('40000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  o.label,o.position
from public.sessions s
cross join (values (1,'Sample correct answer'),(2,'Sample option B'),
  (3,'Sample option C'),(4,'Sample option D')) as o(position,label)
where s.class_id='10000000-0000-4000-8000-000000000001'
on conflict(id) do nothing;

insert into public.quiz_answer_keys(question_id,correct_option_id)
select format('40000000-0000-4000-8000-%s',lpad(s.session_number::text,12,'0'))::uuid,
  format('50000000-0000-4000-%s-%s',lpad(s.session_number::text,4,'0'),lpad('1',12,'0'))::uuid
from public.sessions s
where s.class_id='10000000-0000-4000-8000-000000000001'
on conflict(question_id) do nothing;

