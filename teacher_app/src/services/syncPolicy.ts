export type VersionedRecord = { updated_at: string; revision?: number };

/** Deterministic conflict resolution shared by sync tests and documentation. */
export function chooseLatest<T extends VersionedRecord>(
  local: T,
  remote: T,
): T {
  const localTime = Date.parse(local.updated_at);
  const remoteTime = Date.parse(remote.updated_at);
  if (localTime !== remoteTime) return localTime > remoteTime ? local : remote;
  return (local.revision ?? 0) > (remote.revision ?? 0) ? local : remote;
}

export function isAppendOnlyEntity(entityType: string): boolean {
  return [
    'submission',
    'quiz_attempt',
    'game_attempt',
    'simulation_attempt',
    'activity_event',
  ].includes(entityType);
}
