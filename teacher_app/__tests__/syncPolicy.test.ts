import { chooseLatest, isAppendOnlyEntity } from '../src/services/syncPolicy';

test('newer teacher content wins regardless of revision', () => {
  const local = {
    updated_at: '2026-10-30T01:00:00Z',
    revision: 8,
    title: 'local',
  };
  const remote = {
    updated_at: '2026-10-30T02:00:00Z',
    revision: 3,
    title: 'remote',
  };
  expect(chooseLatest(local, remote).title).toBe('remote');
});

test('revision breaks equal timestamp conflicts', () => {
  const local = { updated_at: '2026-10-30T01:00:00Z', revision: 2 };
  const remote = { updated_at: '2026-10-30T01:00:00Z', revision: 3 };
  expect(chooseLatest(local, remote)).toBe(remote);
});

test('student submissions are append-only records', () => {
  expect(isAppendOnlyEntity('submission')).toBe(true);
  expect(isAppendOnlyEntity('lesson')).toBe(false);
});
