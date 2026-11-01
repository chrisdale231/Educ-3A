import 'dart:typed_data';

class OfflineDatabase {
  Future<bool> open() async => false;
  Future<bool> isInitialized() async => false;
  Future<void> markInitialized() async {}
  Future<Map<String, Object?>> readState() async => <String, Object?>{};
  Future<void> saveSetting(String key, Object value) async {}
  Future<void> saveProfile({
    required String name,
    required int? age,
    required String grade,
    required String section,
    required String gender,
    Uint8List? photo,
  }) async {}
  Future<void> saveProgress({
    required int bestGameScore,
    required int bestQuizScore,
    required int multipleChoiceUnlockedLevel,
    required int enumerationUnlockedLevel,
  }) async {}
  Future<void> addQuizAttempt({
    required String clientId,
    required int level,
    required int score,
    required int total,
    required bool enumeration,
    List<Map<String, Object?>> answers = const <Map<String, Object?>>[],
  }) async {}
  Future<void> addGameAttempt(String clientId, int score) async {}
  Future<void> queueMutation({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  }) async {}
  Future<void> bindUnownedMutations(String userId) async {}
  Future<List<Map<String, Object?>>> pendingMutations(
    String userId, {
    int limit = 50,
  }) async =>
      <Map<String, Object?>>[];
  Future<int> pendingMutationCount({String? userId}) async => 0;
  Future<void> markMutationSyncing(String id) async {}
  Future<void> markMutationSynced(String id) async {}
  Future<void> markMutationError(String id, String message) async {}
  Future<void> resetInterruptedMutations() async {}
  Future<void> cacheDownloadedContent(
    List<Map<String, Object?>> records,
  ) async {}
  Future<void> resetAllProgress() async {}
  Future<void> resetQuizProgress() async {}
  Future<void> resetGameProgress() async {}
  Future<void> resetSimulationProgress() async {}
}
