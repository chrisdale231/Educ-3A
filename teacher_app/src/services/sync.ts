import { cacheRemoteData, markOutbox, pendingOutbox } from '../data/database';
import { supabase } from './supabase';

/**
 * Conflict rules:
 * - submissions/events are append-only and de-duplicated by client UUID;
 * - teacher lesson/quiz edits are last-write-wins by updated_at and revision;
 * - published server content is authoritative when pulled to a student.
 */
export async function syncTeacherChanges(): Promise<{
  synced: number;
  error?: string;
}> {
  const client = supabase;
  if (!client || !client.auth.getSession)
    return { synced: 0, error: 'Supabase public configuration is not set.' };
  let session;
  try {
    session = await client.auth.getSession();
  } catch {
    return { synced: 0, error: 'Offline - changes remain queued locally.' };
  }
  if (!session.data.session)
    return { synced: 0, error: 'Sign in before syncing.' };
  let synced = 0;
  for (const item of await pendingOutbox()) {
    await markOutbox(item.id, 'syncing');
    if (item.entityType !== 'lesson' && item.entityType !== 'quiz') {
      await markOutbox(
        item.id,
        'error',
        `Unsupported entity ${item.entityType}`,
      );
      continue;
    }
    const payload = JSON.parse(item.payload);
    const result = await client.rpc('apply_teacher_sync_operation', {
      p_operation_id: item.id,
      p_entity_type: item.entityType,
      p_entity_id: item.entityId,
      p_payload: payload,
      p_client_updated_at: payload.updated_at,
    });
    if (result.error) {
      await markOutbox(item.id, 'error', result.error.message);
    } else {
      await markOutbox(item.id, 'synced');
      synced += 1;
    }
  }
  const [classes, enrollments, progress, lessons, quizzes, results] =
    await Promise.all([
      client
        .from('classes')
        .select('id,name,grade_level,school_year,created_at'),
      client
        .from('class_enrollments')
        .select(
          'class_id,profiles!class_enrollments_student_id_fkey(id,display_name),classes!inner(name)',
        ),
      client.from('student_progress').select('student_id,completion_percent'),
      client
        .from('lessons')
        .select(
          'id,title,summary,is_published,revision,updated_at,sessions!inner(session_number)',
        ),
      client
        .from('quizzes')
        .select(
          'id,title,passing_score,is_published,revision,updated_at,sessions!inner(session_number)',
        ),
      client
        .from('submissions')
        .select(
          'id,score,total,synced_at,profiles!submissions_student_id_fkey(display_name),quizzes(title)',
        )
        .order('synced_at', { ascending: false }),
    ]);
  const pullError =
    classes.error ??
    enrollments.error ??
    progress.error ??
    lessons.error ??
    quizzes.error ??
    results.error;
  if (pullError)
    return {
      synced,
      error: `Uploads kept; download failed: ${pullError.message}`,
    };
  const progressByStudent = new Map<string, number[]>();
  for (const row of progress.data ?? []) {
    const values = progressByStudent.get(row.student_id) ?? [];
    values.push(row.completion_percent);
    progressByStudent.set(row.student_id, values);
  }
  const students = (enrollments.data ?? []).map(row => {
    const profile = Array.isArray(row.profiles)
      ? row.profiles[0]
      : row.profiles;
    const classRecord = Array.isArray(row.classes)
      ? row.classes[0]
      : row.classes;
    const values = progressByStudent.get(profile?.id ?? '') ?? [];
    return {
      id: profile?.id,
      class_id: row.class_id,
      name: profile?.display_name ?? 'Student',
      class_name: classRecord?.name ?? 'Class',
      completion:
        values.length === 0
          ? 0
          : Math.round(
              values.reduce((sum, value) => sum + value, 0) / values.length,
            ),
    };
  });
  await cacheRemoteData({
    classes: classes.data ?? [],
    students,
    lessons: lessons.data ?? [],
    quizzes: quizzes.data ?? [],
    results: results.data ?? [],
  });
  return { synced };
}
