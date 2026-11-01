import { Platform } from 'react-native';
import TurboSqlite, { type Database } from 'react-native-turbo-sqlite';
import type { DashboardData, OutboxRecord } from '../types';

const androidFilesPath = '/data/data/com.beaconteacher/files';
const documentDirectoryPath =
  Platform.OS === 'windows'
    ? // The module is Windows-only in this project; Android uses its private files directory.
      require('@dr.pogodin/react-native-fs').DocumentDirectoryPath
    : androidFilesPath;
const databasePath = `${documentDirectoryPath}/beacon_teacher.db`;
let database: Database | undefined;
type Row = Record<string, string | number | null>;

const schema = [
  `CREATE TABLE IF NOT EXISTS classes (id TEXT PRIMARY KEY, name TEXT NOT NULL, grade_level TEXT NOT NULL, school_year TEXT NOT NULL, updated_at TEXT NOT NULL)`,
  `CREATE TABLE IF NOT EXISTS students (id TEXT PRIMARY KEY, class_id TEXT NOT NULL, name TEXT NOT NULL, completion INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL)`,
  `CREATE TABLE IF NOT EXISTS lessons (id TEXT PRIMARY KEY, session_number INTEGER NOT NULL, title TEXT NOT NULL, summary TEXT NOT NULL, published INTEGER NOT NULL DEFAULT 0, revision INTEGER NOT NULL DEFAULT 1, updated_at TEXT NOT NULL)`,
  `CREATE TABLE IF NOT EXISTS quizzes (id TEXT PRIMARY KEY, session_number INTEGER NOT NULL, title TEXT NOT NULL, passing_score INTEGER NOT NULL DEFAULT 6, published INTEGER NOT NULL DEFAULT 0, revision INTEGER NOT NULL DEFAULT 1, updated_at TEXT NOT NULL)`,
  `CREATE TABLE IF NOT EXISTS results (id TEXT PRIMARY KEY, student_name TEXT NOT NULL, quiz_title TEXT NOT NULL, score INTEGER NOT NULL, total INTEGER NOT NULL, synced_at TEXT NOT NULL)`,
  `CREATE TABLE IF NOT EXISTS sync_outbox (id TEXT PRIMARY KEY, entity_type TEXT NOT NULL, entity_id TEXT NOT NULL, operation TEXT NOT NULL, payload TEXT NOT NULL, state TEXT NOT NULL DEFAULT 'pending', attempts INTEGER NOT NULL DEFAULT 0, last_error TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)`,
  `CREATE INDEX IF NOT EXISTS sync_outbox_state_idx ON sync_outbox(state, created_at)`,
  `CREATE TABLE IF NOT EXISTS sync_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)`,
];

function uid(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, token => {
    const random = Math.floor(Math.random() * 16);
    const value = token === 'x' ? random : 8 + (random % 4);
    return value.toString(16);
  });
}

export async function openTeacherDatabase(): Promise<void> {
  database ??= await TurboSqlite.openDatabaseAsync(databasePath);
  for (const statement of schema) {
    await database.executeSqlAsync(statement, []);
  }
  await seedSampleData();
}

async function db(): Promise<Database> {
  if (!database) await openTeacherDatabase();
  return database!;
}

async function seedSampleData(): Promise<void> {
  const d = database!;
  const now = new Date().toISOString();
  await d.executeSqlAsync(`INSERT OR IGNORE INTO classes VALUES (?,?,?,?,?)`, [
    'sample-class',
    'Grade 11 - Fluid Mechanics',
    '11',
    '2026-2027',
    now,
  ]);
  await d.executeSqlAsync(`INSERT OR IGNORE INTO students VALUES (?,?,?,?,?)`, [
    'sample-student',
    'sample-class',
    'Sample Student',
    68,
    now,
  ]);
  const titles = [
    'Introduction to Fluids',
    'Properties of Fluids',
    'Pressure',
    'Buoyancy',
    'Density',
    'Fluid Flow',
    'Applications',
    'Review and Assessment',
  ];
  for (let i = 0; i < titles.length; i += 1) {
    await d.executeSqlAsync(
      `INSERT OR IGNORE INTO lessons VALUES (?,?,?,?,?,?,?)`,
      [
        `sample-lesson-${i + 1}`,
        i + 1,
        titles[i],
        'SAMPLE: Replace with approved Grade 11 lesson content.',
        i === 0 ? 1 : 0,
        1,
        now,
      ],
    );
    await d.executeSqlAsync(
      `INSERT OR IGNORE INTO quizzes VALUES (?,?,?,?,?,?,?)`,
      [
        `sample-quiz-${i + 1}`,
        i + 1,
        `${titles[i]} Quiz`,
        6,
        i === 0 ? 1 : 0,
        1,
        now,
      ],
    );
  }
}

export async function loadDashboard(): Promise<DashboardData> {
  const d = await db();
  const classes = (
    await d.executeSqlAsync(
      `SELECT c.id,c.name,c.grade_level,COUNT(s.id) student_count FROM classes c LEFT JOIN students s ON s.class_id=c.id GROUP BY c.id ORDER BY c.name`,
      [],
    )
  ).rows;
  const students = (
    await d.executeSqlAsync(
      `SELECT s.id,s.name,c.name class_name,s.completion FROM students s JOIN classes c ON c.id=s.class_id ORDER BY s.name`,
      [],
    )
  ).rows;
  const lessons = (
    await d.executeSqlAsync(
      `SELECT id,title,session_number,published FROM lessons ORDER BY session_number`,
      [],
    )
  ).rows;
  const quizzes = (
    await d.executeSqlAsync(
      `SELECT id,title,passing_score,published FROM quizzes ORDER BY session_number`,
      [],
    )
  ).rows;
  const results = (
    await d.executeSqlAsync(
      `SELECT id,student_name,quiz_title,score,total,synced_at FROM results ORDER BY synced_at DESC`,
      [],
    )
  ).rows;
  return {
    classes: (classes as Row[]).map(row => ({
      id: String(row.id),
      name: String(row.name),
      gradeLevel: String(row.grade_level),
      studentCount: Number(row.student_count),
    })),
    students: (students as Row[]).map(row => ({
      id: String(row.id),
      name: String(row.name),
      className: String(row.class_name),
      completion: Number(row.completion),
    })),
    lessons: (lessons as Row[]).map(row => ({
      id: String(row.id),
      title: String(row.title),
      sessionNumber: Number(row.session_number),
      published: row.published === 1,
    })),
    quizzes: (quizzes as Row[]).map(row => ({
      id: String(row.id),
      title: String(row.title),
      passingScore: Number(row.passing_score),
      published: row.published === 1,
    })),
    results: (results as Row[]).map(row => ({
      id: String(row.id),
      studentName: String(row.student_name),
      quizTitle: String(row.quiz_title),
      score: Number(row.score),
      total: Number(row.total),
      syncedAt: String(row.synced_at),
    })),
  };
}

export async function setPublished(
  kind: 'lessons' | 'quizzes',
  id: string,
  published: boolean,
): Promise<void> {
  const d = await db();
  const updatedAt = new Date().toISOString();
  await d.executeSqlAsync(
    `UPDATE ${kind} SET published=?,revision=revision+1,updated_at=? WHERE id=?`,
    [published ? 1 : 0, updatedAt, id],
  );
  const revisionRows = (
    await d.executeSqlAsync(`SELECT revision FROM ${kind} WHERE id=?`, [id])
  ).rows as Row[];
  await queueChange(kind.slice(0, -1), id, {
    id,
    is_published: published,
    revision: Number(revisionRows[0]?.revision ?? 1),
    updated_at: updatedAt,
  });
}

export async function queueChange(
  entityType: string,
  entityId: string,
  payload: object,
): Promise<void> {
  const d = await db();
  const now = new Date().toISOString();
  await d.executeSqlAsync(
    `INSERT INTO sync_outbox(id,entity_type,entity_id,operation,payload,state,created_at,updated_at) VALUES(?,?,?,?,?,'pending',?,?)`,
    [uid(), entityType, entityId, 'upsert', JSON.stringify(payload), now, now],
  );
}

export async function pendingOutbox(): Promise<OutboxRecord[]> {
  const d = await db();
  const rows = (
    await d.executeSqlAsync(
      `SELECT id,entity_type,entity_id,operation,payload,attempts FROM sync_outbox WHERE state IN ('pending','error') ORDER BY created_at`,
      [],
    )
  ).rows;
  return (rows as Row[]).map(row => ({
    id: String(row.id),
    entityType: String(row.entity_type),
    entityId: String(row.entity_id),
    operation: String(row.operation),
    payload: String(row.payload),
    attempts: Number(row.attempts),
  }));
}

export async function outboxCount(): Promise<number> {
  const d = await db();
  return Number(
    (
      await d.executeSqlAsync(
        `SELECT COUNT(*) count FROM sync_outbox WHERE state!='synced'`,
        [],
      )
    ).rows[0]?.count ?? 0,
  );
}

export async function markOutbox(
  id: string,
  state: 'syncing' | 'synced' | 'error',
  error?: string,
): Promise<void> {
  const d = await db();
  await d.executeSqlAsync(
    `UPDATE sync_outbox SET state=?,attempts=attempts+1,last_error=?,updated_at=? WHERE id=?`,
    [state, error ?? null, new Date().toISOString(), id],
  );
}

export async function cacheRemoteData(remote: {
  classes?: Array<Record<string, any>>;
  students?: Array<Record<string, any>>;
  lessons?: Array<Record<string, any>>;
  quizzes?: Array<Record<string, any>>;
  results?: Array<Record<string, any>>;
}): Promise<void> {
  const d = await db();
  for (const item of remote.classes ?? []) {
    await d.executeSqlAsync(
      `INSERT INTO classes(id,name,grade_level,school_year,updated_at) VALUES(?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET name=excluded.name,grade_level=excluded.grade_level,school_year=excluded.school_year,updated_at=excluded.updated_at`,
      [
        item.id,
        item.name,
        item.grade_level,
        item.school_year,
        item.updated_at ?? new Date().toISOString(),
      ],
    );
  }
  for (const item of remote.students ?? []) {
    if (!item.id) continue;
    await d.executeSqlAsync(
      `INSERT INTO students(id,class_id,name,completion,updated_at) VALUES(?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET class_id=excluded.class_id,name=excluded.name,completion=excluded.completion,updated_at=excluded.updated_at`,
      [
        item.id,
        item.class_id,
        item.name,
        item.completion ?? 0,
        new Date().toISOString(),
      ],
    );
  }
  for (const item of remote.lessons ?? []) {
    const session = Array.isArray(item.sessions)
      ? item.sessions[0]
      : item.sessions;
    const pending =
      (
        await d.executeSqlAsync(
          `SELECT 1 found FROM sync_outbox WHERE entity_type='lesson' AND entity_id=? AND state!='synced' LIMIT 1`,
          [item.id],
        )
      ).rows.length > 0;
    if (!pending)
      await d.executeSqlAsync(
        `INSERT INTO lessons(id,session_number,title,summary,published,revision,updated_at) VALUES(?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET session_number=excluded.session_number,title=excluded.title,summary=excluded.summary,published=excluded.published,revision=excluded.revision,updated_at=excluded.updated_at`,
        [
          item.id,
          session?.session_number ?? 1,
          item.title,
          item.summary ?? '',
          item.is_published ? 1 : 0,
          item.revision ?? 1,
          item.updated_at,
        ],
      );
  }
  for (const item of remote.quizzes ?? []) {
    const session = Array.isArray(item.sessions)
      ? item.sessions[0]
      : item.sessions;
    const pending =
      (
        await d.executeSqlAsync(
          `SELECT 1 found FROM sync_outbox WHERE entity_type='quiz' AND entity_id=? AND state!='synced' LIMIT 1`,
          [item.id],
        )
      ).rows.length > 0;
    if (!pending)
      await d.executeSqlAsync(
        `INSERT INTO quizzes(id,session_number,title,passing_score,published,revision,updated_at) VALUES(?,?,?,?,?,?,?) ON CONFLICT(id) DO UPDATE SET session_number=excluded.session_number,title=excluded.title,passing_score=excluded.passing_score,published=excluded.published,revision=excluded.revision,updated_at=excluded.updated_at`,
        [
          item.id,
          session?.session_number ?? 1,
          item.title,
          item.passing_score ?? 6,
          item.is_published ? 1 : 0,
          item.revision ?? 1,
          item.updated_at,
        ],
      );
  }
  for (const item of remote.results ?? []) {
    const profile = Array.isArray(item.profiles)
      ? item.profiles[0]
      : item.profiles;
    const quiz = Array.isArray(item.quizzes) ? item.quizzes[0] : item.quizzes;
    await d.executeSqlAsync(
      `INSERT OR REPLACE INTO results VALUES(?,?,?,?,?,?)`,
      [
        item.id,
        profile?.display_name ?? 'Student',
        quiz?.title ?? 'Quiz',
        item.score,
        item.total,
        item.synced_at,
      ],
    );
  }
}

export const teacherDatabaseFile = databasePath;
