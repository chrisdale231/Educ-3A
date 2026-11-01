import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class OfflineDatabase {
  Database? _profileDatabase;
  final Map<String, Database> _sessionDatabases = <String, Database>{};
  String? _databaseRoot;

  Future<bool> open() async {
    try {
      final databasesPath = await getDatabasesPath();
      _databaseRoot = p.join(databasesPath, 'physics_of_fluids');
      await Directory(_databaseRoot!).create(recursive: true);
      final profilePath = p.join(_databaseRoot!, 'profile.db');
      await _copyAssetIfMissing('sqlite/profile.db', profilePath);
      _profileDatabase = await openDatabase(
        profilePath,
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      );
      await _ensureSyncSchema();
      return true;
    } on Object {
      _profileDatabase = null;
      return false;
    }
  }

  Database get _profile {
    final database = _profileDatabase;
    if (database == null) throw StateError('Profile database is not open.');
    return database;
  }

  Future<void> _ensureSyncSchema() async {
    await _profile.execute('''
      CREATE TABLE IF NOT EXISTS sync_outbox (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
          CHECK (status IN ('local', 'pending', 'syncing', 'synced', 'error')),
        attempt_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await _addColumnIfMissing(
      _profile,
      'sync_outbox',
      'owner_user_id',
      'TEXT',
    );
    await _profile.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_outbox_status_created
      ON sync_outbox(status, created_at)
    ''');
    await _profile.execute('''
      CREATE TABLE IF NOT EXISTS sync_cursors (
        scope TEXT PRIMARY KEY,
        cursor TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await _profile.execute('''
      CREATE TABLE IF NOT EXISTS downloaded_content (
        remote_id TEXT PRIMARY KEY,
        content_type TEXT NOT NULL,
        revision INTEGER NOT NULL DEFAULT 1,
        payload_json TEXT NOT NULL,
        published_at TEXT,
        downloaded_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _copyAssetIfMissing(String assetPath, String filePath) async {
    final file = File(filePath);
    if (await file.exists()) return;
    await file.parent.create(recursive: true);
    final data = await rootBundle.load(assetPath);
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
  }

  Future<Database> _sessionDatabase(int session, String type) async {
    if (session < 1 || session > 8) {
      throw RangeError.range(session, 1, 8, 'session');
    }
    const types = <String>{'concept', 'simulation', 'game', 'quiz'};
    if (!types.contains(type)) throw ArgumentError.value(type, 'type');
    final key = '$session/$type';
    final existing = _sessionDatabases[key];
    if (existing != null) return existing;
    final root = _databaseRoot;
    if (root == null) throw StateError('Offline database is not open.');
    final relativePath = 'session$session/$type.db';
    final filePath = p.join(root, 'session$session', '$type.db');
    await _copyAssetIfMissing('sqlite/$relativePath', filePath);
    final database = await openDatabase(
      filePath,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
    if (type == 'quiz') {
      await _addColumnIfMissing(database, 'quiz_attempts', 'client_id', 'TEXT');
      await _addColumnIfMissing(
        database,
        'quiz_attempts',
        'sync_status',
        "TEXT NOT NULL DEFAULT 'local'",
      );
      await database.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_quiz_attempt_client_id
        ON quiz_attempts(client_id) WHERE client_id IS NOT NULL
      ''');
      await database.execute('''
        CREATE TABLE IF NOT EXISTS quiz_attempt_answers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          attempt_client_id TEXT NOT NULL,
          question_index INTEGER NOT NULL,
          selected_choice_index INTEGER,
          correct_choice_index INTEGER NOT NULL,
          is_correct INTEGER NOT NULL CHECK (is_correct IN (0,1)),
          UNIQUE(attempt_client_id, question_index)
        )
      ''');
    } else if (type == 'game') {
      await _addColumnIfMissing(database, 'game_attempts', 'client_id', 'TEXT');
      await _addColumnIfMissing(
        database,
        'game_attempts',
        'sync_status',
        "TEXT NOT NULL DEFAULT 'local'",
      );
    } else if (type == 'simulation') {
      await _addColumnIfMissing(
        database,
        'simulation_attempts',
        'client_id',
        'TEXT',
      );
      await _addColumnIfMissing(
        database,
        'simulation_attempts',
        'sync_status',
        "TEXT NOT NULL DEFAULT 'local'",
      );
    }
    _sessionDatabases[key] = database;
    return database;
  }

  Future<void> _addColumnIfMissing(
    Database database,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await database.rawQuery('PRAGMA table_info($table)');
    if (columns.any((row) => row['name'] == column)) return;
    await database.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  Future<bool> isInitialized() async {
    final rows = await _profile.query(
      'app_metadata',
      columns: <String>['value'],
      where: 'key = ?',
      whereArgs: <Object>['initialized'],
      limit: 1,
    );
    return rows.isNotEmpty && rows.first['value'] == '1';
  }

  Future<void> markInitialized() => _profile.insert(
        'app_metadata',
        <String, Object?>{'key': 'initialized', 'value': '1'},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<Map<String, Object?>> readState() async {
    final settings = await _profile.query('app_settings');
    final profile = await _profile.query('learner_profile', where: 'id = 1');
    final progress = await _profile.query('learner_progress', where: 'id = 1');
    final result = <String, Object?>{};
    for (final row in settings) {
      result[row['key']! as String] = row['value'];
    }
    if (profile.isNotEmpty) result.addAll(profile.first);
    if (progress.isNotEmpty) result.addAll(progress.first);
    return result;
  }

  Future<void> saveSetting(String key, Object value) => _profile.insert(
        'app_settings',
        <String, Object?>{'key': key, 'value': value.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveProfile({
    required String name,
    required int? age,
    required String grade,
    required String section,
    required String gender,
    Uint8List? photo,
  }) =>
      _profile.insert(
        'learner_profile',
        <String, Object?>{
          'id': 1,
          'name': name,
          'age': age,
          'grade_level': grade,
          'section': section,
          'gender': gender,
          'photo': photo,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<void> saveProgress({
    required int bestGameScore,
    required int bestQuizScore,
    required int multipleChoiceUnlockedLevel,
    required int enumerationUnlockedLevel,
  }) =>
      _profile.update(
        'learner_progress',
        <String, Object?>{
          'best_game_score': bestGameScore,
          'best_quiz_score': bestQuizScore,
          'multiple_choice_unlocked_level': multipleChoiceUnlockedLevel,
          'enumeration_unlocked_level': enumerationUnlockedLevel,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = 1',
      );

  Future<void> addQuizAttempt({
    required String clientId,
    required int level,
    required int score,
    required int total,
    required bool enumeration,
    List<Map<String, Object?>> answers = const <Map<String, Object?>>[],
  }) async {
    final database = await _sessionDatabase(level.clamp(1, 8), 'quiz');
    await database.transaction((transaction) async {
      await transaction.insert(
          'quiz_attempts',
          <String, Object?>{
            'client_id': clientId,
            'quiz_type': enumeration ? 'enumeration' : 'multiple_choice',
            'score': score,
            'total': total,
            'sync_status': 'pending',
            'completed_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
      for (final answer in answers) {
        await transaction.insert(
          'quiz_attempt_answers',
          <String, Object?>{
            'attempt_client_id': clientId,
            'question_index': answer['question_index'],
            'selected_choice_index': answer['selected_choice_index'],
            'correct_choice_index': answer['correct_choice_index'],
            'is_correct': answer['is_correct'] == true ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> addGameAttempt(String clientId, int score) async {
    final database = await _sessionDatabase(1, 'game');
    await database.insert(
        'game_attempts',
        <String, Object?>{
          'client_id': clientId,
          'score': score,
          'sync_status': 'pending',
          'completed_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> queueMutation({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, Object?> payload,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _profile.insert(
      'sync_outbox',
      <String, Object?>{
        'id': id,
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'payload_json': jsonEncode(payload),
        'status': 'pending',
        'attempt_count': 0,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> bindUnownedMutations(String userId) => _profile.rawUpdate(
        '''UPDATE sync_outbox SET owner_user_id = ?
           WHERE owner_user_id IS NULL AND status IN ('pending', 'error')''',
        <Object?>[userId],
      );

  Future<List<Map<String, Object?>>> pendingMutations(
    String userId, {
    int limit = 50,
  }) =>
      _profile.query(
        'sync_outbox',
        where: "owner_user_id = ? AND status IN ('pending', 'error')",
        whereArgs: <Object?>[userId],
        orderBy: 'created_at ASC',
        limit: limit,
      );

  Future<int> pendingMutationCount({String? userId}) async {
    final rows = await _profile.rawQuery(
      '''SELECT COUNT(*) AS count FROM sync_outbox
         WHERE status IN ('pending', 'syncing', 'error')
         ${userId == null ? '' : 'AND (owner_user_id = ? OR owner_user_id IS NULL)'}''',
      userId == null ? null : <Object?>[userId],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> markMutationSyncing(String id) => _profile.rawUpdate(
        '''UPDATE sync_outbox
           SET status = 'syncing', attempt_count = attempt_count + 1,
               last_error = NULL, updated_at = ?
           WHERE id = ?''',
        <Object?>[DateTime.now().toUtc().toIso8601String(), id],
      );

  Future<void> markMutationSynced(String id) => _profile.update(
        'sync_outbox',
        <String, Object?>{
          'status': 'synced',
          'last_error': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );

  Future<void> markMutationError(String id, String message) => _profile.update(
        'sync_outbox',
        <String, Object?>{
          'status': 'error',
          'last_error': message,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );

  Future<void> resetInterruptedMutations() => _profile.rawUpdate(
        "UPDATE sync_outbox SET status = 'pending' WHERE status = 'syncing'",
      );

  Future<void> cacheDownloadedContent(
    List<Map<String, Object?>> records,
  ) async {
    final batch = _profile.batch();
    final now = DateTime.now().toUtc().toIso8601String();
    for (final record in records) {
      final id = record['id']?.toString();
      if (id == null || id.isEmpty) continue;
      batch.insert(
        'downloaded_content',
        <String, Object?>{
          'remote_id': id,
          'content_type': record['content_type']?.toString() ?? 'lesson',
          'revision': record['revision'] as int? ?? 1,
          'payload_json': jsonEncode(record),
          'published_at': record['published_at']?.toString(),
          'downloaded_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> resetAllProgress() async {
    await resetQuizProgress();
    await resetGameProgress();
    await resetSimulationProgress();
    await _profile.update('session_progress', <String, Object?>{
      'progress_percent': 0,
      'completed': 0,
      'unlocked': 0,
    });
    await _profile.update(
      'session_progress',
      <String, Object?>{'unlocked': 1},
      where: 'session_number = 1',
    );
  }

  Future<void> resetQuizProgress() async {
    for (var session = 1; session <= 8; session++) {
      final database = await _sessionDatabase(session, 'quiz');
      await database.delete('quiz_attempt_answers');
      await database.delete('quiz_attempts');
    }
  }

  Future<void> resetGameProgress() async {
    for (var session = 1; session <= 8; session++) {
      final database = await _sessionDatabase(session, 'game');
      await database.delete('game_attempts');
    }
  }

  Future<void> resetSimulationProgress() async {
    for (var session = 1; session <= 8; session++) {
      final database = await _sessionDatabase(session, 'simulation');
      await database.delete('simulation_attempts');
    }
  }
}
