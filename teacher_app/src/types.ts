export type SyncState = 'local' | 'pending' | 'syncing' | 'synced' | 'error';

export type DashboardData = {
  classes: Array<{
    id: string;
    name: string;
    gradeLevel: string;
    studentCount: number;
  }>;
  students: Array<{
    id: string;
    name: string;
    className: string;
    completion: number;
  }>;
  lessons: Array<{
    id: string;
    title: string;
    sessionNumber: number;
    published: boolean;
  }>;
  quizzes: Array<{
    id: string;
    title: string;
    passingScore: number;
    published: boolean;
  }>;
  results: Array<{
    id: string;
    studentName: string;
    quizTitle: string;
    score: number;
    total: number;
    syncedAt: string;
  }>;
};

export type OutboxRecord = {
  id: string;
  entityType: string;
  entityId: string;
  operation: string;
  payload: string;
  attempts: number;
};
