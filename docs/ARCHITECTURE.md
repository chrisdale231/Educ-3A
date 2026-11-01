# BEACON architecture

## Data flow

```text
Flutter student app             Supabase/PostgreSQL             RN Windows teacher app
-------------------             -------------------             ----------------------
profile.db + session DBs  <-->  Auth + RLS tables/RPCs   <-->  beacon_teacher.db
local outbox                    authoritative shared data       local outbox
downloaded content cache        assigned-class boundary         authorized cache
```

Each client writes locally first. A queued mutation has a UUID, entity type, entity ID, operation, JSON payload, timestamp, attempt count, and sync state. A successful remote acknowledgement marks it `synced`; failures remain in the database as `error` or `pending` and can be retried.

Student work is not visible to teachers while it exists only in the student's SQLite file. It becomes visible after the student app uploads it and Supabase accepts it under Row Level Security.

## Local databases

The Flutter app preserves its packaged `profile.db` and `session1` through `session8` concept/simulation/game/quiz databases. On first use they are copied to writable application storage. `profile.db` also contains:

- `sync_outbox` for retryable local mutations;
- `downloaded_content` for authorized published lessons and quizzes;
- `sync_cursors` for incremental synchronization metadata.

Each completed multiple-choice attempt also stores its selected answer, correct choice, and correctness in the writable session quiz database. The same answer list travels inside the queued append-only activity payload, so it remains available while offline and across retries.

The teacher app creates `beacon_teacher.db` in the operating system's writable document directory. It caches authorized classes, students, lessons, quizzes, synchronized submissions, and its own `sync_outbox`.

## Conflict and idempotency rules

1. Attempts, submissions, answers, and activity events are append-only. Their client UUID is unique, so retrying an upload cannot create a duplicate.
2. Student profile edits use last-write-wins by `client_updated_at`; the server timestamp breaks an exact tie.
3. Published lesson and quiz content from Supabase is authoritative for students.
4. A teacher's pending local lesson/quiz edit is retained until acknowledged. Otherwise, the higher `updated_at` wins; `revision` breaks equal timestamps.
5. A sync error never deletes local work. The status remains visible and manual/periodic retry is available.

## Authorization

Supabase Auth supplies the user identity. Clients contain only the public project URL and anon key, never a service-role key. Migration policies enforce:

- students can read only classes in which they are enrolled and only published lesson/quiz data;
- students can read/write only their own profile, progress, submissions, and answers;
- teachers can read/write only classes assigned through `class_teachers` and their enrolled students;
- answer keys are teacher-only, even though quiz prompts and choices can be downloaded by students.

The student and teacher sync RPCs authenticate the caller, check class membership/assignment, and are idempotent through `sync_operations`. They are `security definer` functions with an explicit `public` search path and do not accept a user ID from either client.

## Supported offline behavior

The student can continue using packaged lessons, concepts, simulations, games, and quizzes, and can save results/progress. The teacher can read cached dashboard data and change cached lesson/quiz publication state. Authentication and first-time authorization require a connection; synchronization resumes periodically or on demand when connectivity returns.

## Production content still required

The project does not infer official curriculum content. Supply final lesson bodies, quiz questions/options/answer keys, class rosters, teacher assignments, grading rules, and reporting requirements. The rows in `supabase/seed.sql` and the initial teacher SQLite seed are labeled samples.
