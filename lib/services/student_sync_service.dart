import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend_config.dart';
import 'offline_database.dart';

enum SyncPhase { local, pending, syncing, synced, error }

class StudentSyncService extends ChangeNotifier {
  StudentSyncService(this._database);

  final OfflineDatabase _database;
  SupabaseClient? _client;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<AuthState>? _authSubscription;
  bool _authRunning = false;
  bool _syncRunning = false;
  bool _syncRequested = false;
  bool _databaseReady = false;
  SyncPhase phase = SyncPhase.local;
  int pendingCount = 0;
  String? lastError;
  DateTime? lastSyncedAt;

  bool get configured => BackendConfig.isConfigured;
  bool get hasLearnerIdentity => _client?.auth.currentUser != null;

  Future<void> initialize({required bool databaseReady}) async {
    _databaseReady = databaseReady;
    if (databaseReady) {
      await _database.resetInterruptedMutations();
      pendingCount = await _database.pendingMutationCount();
      phase = pendingCount == 0 ? SyncPhase.local : SyncPhase.pending;
    }
    if (configured) {
      _client = Supabase.instance.client;
      _authSubscription = _client!.auth.onAuthStateChange.listen((event) {
        final user = event.session?.user;
        if (user != null) {
          unawaited(_bindAndSync(user.id));
        }
      });
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          unawaited(syncNow());
        }
      });
      if (_databaseReady) unawaited(syncNow());
    }
    notifyListeners();
  }

  Future<User?> _ensureAnonymousLearner() async {
    final client = _client;
    if (client == null) return null;
    final existing = client.auth.currentUser;
    if (existing != null) return existing;
    if (_authRunning) return null;
    _authRunning = true;
    try {
      final response = await client.auth.signInAnonymously(
        data: const <String, Object?>{'role': 'student'},
      );
      final user = response.user;
      if (user != null) await _database.bindUnownedMutations(user.id);
      return user;
    } finally {
      _authRunning = false;
    }
  }

  Future<void> _bindAndSync(String userId) async {
    if (!_databaseReady) return;
    await _database.bindUnownedMutations(userId);
    await syncNow();
  }

  Future<void> localChanged() async {
    pendingCount = await _database.pendingMutationCount(
      userId: _client?.auth.currentUser?.id,
    );
    phase = pendingCount == 0 ? SyncPhase.local : SyncPhase.pending;
    notifyListeners();
    unawaited(syncNow());
  }

  Future<void> syncNow() async {
    final client = _client;
    if (client == null || !_databaseReady) return;
    if (_syncRunning) {
      _syncRequested = true;
      return;
    }
    _syncRunning = true;
    _syncRequested = false;
    User? user;
    try {
      user = client.auth.currentUser ?? await _ensureAnonymousLearner();
    } on Object catch (error, stackTrace) {
      debugPrint('Learner authentication deferred: $error');
      debugPrintStack(stackTrace: stackTrace);
      pendingCount = await _database.pendingMutationCount();
      phase = pendingCount == 0 ? SyncPhase.local : SyncPhase.pending;
      lastError = 'Waiting for an internet connection to create learner sync.';
      notifyListeners();
      _syncRunning = false;
      return;
    }
    if (user == null) {
      _syncRunning = false;
      return;
    }
    await _database.bindUnownedMutations(user.id);
    phase = SyncPhase.syncing;
    lastError = null;
    notifyListeners();

    try {
      String? uploadError;
      final mutations = await _database.pendingMutations(user.id);
      for (final mutation in mutations) {
        final id = mutation['id']! as String;
        await _database.markMutationSyncing(id);
        try {
          final payload = jsonDecode(mutation['payload_json']! as String)
              as Map<String, dynamic>;
          await client.rpc<Object?>(
            'apply_student_sync_operation',
            params: <String, Object?>{
              'p_operation_id': id,
              'p_entity_type': mutation['entity_type'],
              'p_entity_id': mutation['entity_id'],
              'p_operation': mutation['operation'],
              'p_payload': payload,
              'p_client_updated_at': mutation['updated_at'],
            },
          );
          await _database.markMutationSynced(id);
        } on Object catch (error) {
          await _database.markMutationError(id, error.toString());
          uploadError ??= error.toString();
        }
      }

      final lessons = await client
          .from('lessons')
          .select('id,session_id,title,summary,content,revision,published_at')
          .eq('is_published', true);
      await _database.cacheDownloadedContent(
        lessons
            .map<Map<String, Object?>>(
              (row) => <String, Object?>{
                ...row,
                'content_type': 'lesson',
              },
            )
            .toList(),
      );
      final quizzes = await client
          .from('quizzes')
          .select('id,session_id,title,instructions,revision,published_at')
          .eq('is_published', true);
      await _database.cacheDownloadedContent(
        quizzes
            .map<Map<String, Object?>>(
              (row) => <String, Object?>{
                ...row,
                'content_type': 'quiz',
              },
            )
            .toList(),
      );
      final questions = await client
          .from('quiz_questions')
          .select('id,quiz_id,prompt,position,quiz_options(id,label,position)');
      await _database.cacheDownloadedContent(
        questions
            .map<Map<String, Object?>>(
              (row) => <String, Object?>{
                ...row,
                'content_type': 'quiz_question',
              },
            )
            .toList(),
      );
      pendingCount = await _database.pendingMutationCount(userId: user.id);
      if (uploadError == null) {
        phase = pendingCount == 0 ? SyncPhase.synced : SyncPhase.pending;
        lastSyncedAt = DateTime.now();
      } else {
        phase = SyncPhase.error;
        lastError = uploadError;
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Learner synchronization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      pendingCount = await _database.pendingMutationCount(userId: user.id);
      phase = SyncPhase.error;
      lastError = error.toString();
    } finally {
      _syncRunning = false;
    }
    notifyListeners();
    if (_syncRequested) unawaited(syncNow());
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
