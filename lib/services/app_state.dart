import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'offline_database.dart';
import 'student_sync_service.dart';

class AppState extends ChangeNotifier {
  AppState() : _database = OfflineDatabase() {
    sync = StudentSyncService(_database);
  }

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final OfflineDatabase _database;
  static const Uuid _uuid = Uuid();
  late final StudentSyncService sync;
  bool _databaseReady = false;
  String? storageError;

  bool musicOn = true;
  bool soundOn = true;
  bool lightMode = true;
  String languageCode = 'en';
  String learnerName = '';
  int? learnerAge;
  String learnerGradeLevel = '';
  String learnerSection = '';
  String learnerGender = 'male';
  Uint8List? learnerPhotoBytes;
  int bestGameScore = 0;
  int bestQuizScore = 0;
  int multipleChoiceUnlockedLevel = 1;
  int enumerationUnlockedLevel = 1;
  final List<int> _conceptSteps = List<int>.filled(8, 0);

  bool get isTagalog => languageCode == 'tl';

  String text(String english, String tagalog) => isTagalog ? tagalog : english;

  Future<void> load() async {
    try {
      _databaseReady = await _database.open();
      if (_databaseReady) {
        if (await _database.isInitialized()) {
          final databaseState = await _database.readState();
          final databaseName = databaseState['name']?.toString().trim() ?? '';
          if (databaseName.isEmpty) {
            // Repair an older/empty database by importing the profile that the
            // app previously stored in SharedPreferences (notably on web).
            await _loadPreferences();
            if (learnerName.isNotEmpty) {
              await _saveAllToDatabase();
            } else {
              _applyDatabaseState(databaseState);
            }
          } else {
            _applyDatabaseState(databaseState);
          }
        } else {
          await _loadPreferences();
          await _saveAllToDatabase();
          await _database.markInitialized();
        }
        await sync.initialize(databaseReady: true);
        sync.addListener(notifyListeners);
        if (await _prefs.getBool('pendingProfileUpload') == true &&
            hasLearnerProfile) {
          await _queueProfileMutation();
          await _prefs.remove('pendingProfileUpload');
        }
        notifyListeners();
        return;
      }
    } on Object catch (error, stackTrace) {
      storageError = 'Local database unavailable. Using browser preferences.';
      debugPrint('Opening learner SQLite storage failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _databaseReady = false;
    }
    await _loadPreferences();
    await sync.initialize(databaseReady: false);
    sync.addListener(notifyListeners);
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    musicOn = await _prefs.getBool('musicOn') ?? true;
    soundOn = await _prefs.getBool('soundOn') ?? true;
    lightMode = await _prefs.getBool('lightMode') ?? true;
    final savedLanguage = await _prefs.getString('languageCode');
    languageCode = savedLanguage == 'tl' ? 'tl' : 'en';
    learnerName = await _prefs.getString('learnerName') ?? '';
    learnerAge = await _prefs.getInt('learnerAge');
    learnerGradeLevel = await _prefs.getString('learnerGradeLevel') ?? '';
    learnerSection = await _prefs.getString('learnerSection') ?? '';
    learnerGender =
        await _prefs.getString('learnerGender') == 'female' ? 'female' : 'male';
    final photo = await _prefs.getString('learnerPhoto');
    try {
      learnerPhotoBytes = photo == null ? null : base64Decode(photo);
    } on FormatException {
      learnerPhotoBytes = null;
    }
    bestGameScore = await _prefs.getInt('bestGameScore') ?? 0;
    bestQuizScore = await _prefs.getInt('bestQuizScore') ?? 0;
    multipleChoiceUnlockedLevel = await _prefs.getInt('quiz_mc_unlocked') ?? 1;
    enumerationUnlockedLevel = await _prefs.getInt('quiz_enum_unlocked') ?? 1;
    for (var session = 1; session <= 8; session++) {
      _conceptSteps[session - 1] =
          await _prefs.getInt('concept_step_$session') ?? 0;
    }
  }

  void _applyDatabaseState(Map<String, Object?> values) {
    bool databaseBool(String key, bool fallback) {
      final value = values[key]?.toString();
      if (value == null) return fallback;
      return value == '1' || value.toLowerCase() == 'true';
    }

    int databaseInt(String key, int fallback) {
      final value = values[key];
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    musicOn = databaseBool('musicOn', true);
    soundOn = databaseBool('soundOn', true);
    lightMode = databaseBool('lightMode', true);
    languageCode = values['languageCode'] == 'tl' ? 'tl' : 'en';
    learnerName = values['name']?.toString() ?? '';
    learnerAge = values['age'] as int?;
    learnerGradeLevel = values['grade_level']?.toString() ?? '';
    learnerSection = values['section']?.toString() ?? '';
    learnerGender = values['gender'] == 'female' ? 'female' : 'male';
    learnerPhotoBytes = values['photo'] as Uint8List?;
    bestGameScore = databaseInt('best_game_score', 0);
    bestQuizScore = databaseInt('best_quiz_score', 0);
    multipleChoiceUnlockedLevel =
        databaseInt('multiple_choice_unlocked_level', 1);
    enumerationUnlockedLevel = databaseInt('enumeration_unlocked_level', 1);
    for (var session = 1; session <= 8; session++) {
      _conceptSteps[session - 1] =
          databaseInt('concept_step_$session', _conceptSteps[session - 1]);
    }
  }

  Future<void> _saveAllToDatabase() async {
    await Future.wait(<Future<void>>[
      _database.saveSetting('musicOn', musicOn ? 1 : 0),
      _database.saveSetting('soundOn', soundOn ? 1 : 0),
      _database.saveSetting('lightMode', lightMode ? 1 : 0),
      _database.saveSetting('languageCode', languageCode),
      for (var session = 1; session <= 8; session++)
        _database.saveSetting(
          'concept_step_$session',
          _conceptSteps[session - 1],
        ),
      _database.saveProfile(
        name: learnerName,
        age: learnerAge,
        grade: learnerGradeLevel,
        section: learnerSection,
        gender: learnerGender,
        photo: learnerPhotoBytes,
      ),
      _saveDatabaseProgress(),
    ]);
  }

  Future<void> _saveDatabaseProgress() => _database.saveProgress(
        bestGameScore: bestGameScore,
        bestQuizScore: bestQuizScore,
        multipleChoiceUnlockedLevel: multipleChoiceUnlockedLevel,
        enumerationUnlockedLevel: enumerationUnlockedLevel,
      );

  Future<void> _saveProfileToCurrentStore() async {
    if (_databaseReady) {
      await _database.saveProfile(
        name: learnerName,
        age: learnerAge,
        grade: learnerGradeLevel,
        section: learnerSection,
        gender: learnerGender,
        photo: learnerPhotoBytes,
      );
      await _queueMutation(
        entityType: 'learner_profile',
        entityId: 'current-user',
        payload: _profileSyncPayload(),
      );
      return;
    }
    await Future.wait(<Future<void>>[
      _prefs.setString('learnerName', learnerName),
      if (learnerAge != null) _prefs.setInt('learnerAge', learnerAge!),
      _prefs.setString('learnerGradeLevel', learnerGradeLevel),
      _prefs.setString('learnerSection', learnerSection),
      _prefs.setString('learnerGender', learnerGender),
      if (learnerPhotoBytes == null)
        _prefs.remove('learnerPhoto')
      else
        _prefs.setString('learnerPhoto', base64Encode(learnerPhotoBytes!)),
      _prefs.setBool('pendingProfileUpload', true),
    ]);
  }

  Map<String, Object?> _profileSyncPayload() => <String, Object?>{
        'name': learnerName,
        'age': learnerAge,
        'grade_level': learnerGradeLevel,
        'section': learnerSection,
        'gender': learnerGender,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

  Future<void> _queueProfileMutation() => _queueMutation(
        entityType: 'learner_profile',
        entityId: 'current-user',
        payload: _profileSyncPayload(),
      );

  Future<void> _queueMutation({
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
  }) async {
    if (!_databaseReady) return;
    await _database.queueMutation(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: 'upsert',
      payload: payload,
    );
    await sync.localChanged();
  }

  bool get hasLearnerProfile =>
      learnerName.trim().isNotEmpty &&
      learnerAge != null &&
      learnerGradeLevel.isNotEmpty;

  Future<bool> loginLearner(String name) async {
    final enteredName = name.trim();
    if (enteredName.isEmpty) return false;
    if (hasLearnerProfile &&
        learnerName.trim().toLowerCase() == enteredName.toLowerCase()) {
      return true;
    }

    final remote = await sync.findLearnerProfile(enteredName);
    if (remote == null) return false;
    final remoteName = remote['display_name']?.toString().trim() ?? '';
    final remoteAge = remote['age'] is int
        ? remote['age'] as int
        : int.tryParse(remote['age']?.toString() ?? '');
    final remoteGrade = remote['grade_level']?.toString().trim() ?? '';
    if (remoteName.isEmpty || remoteAge == null || remoteGrade.isEmpty) {
      return false;
    }

    learnerName = remoteName;
    learnerAge = remoteAge;
    learnerGradeLevel = remoteGrade;
    learnerSection = remote['section']?.toString().trim() ?? '';
    learnerGender = remote['gender'] == 'female' ? 'female' : 'male';
    notifyListeners();

    if (_databaseReady) {
      await _database.saveProfile(
        name: learnerName,
        age: learnerAge,
        grade: learnerGradeLevel,
        section: learnerSection,
        gender: learnerGender,
        photo: learnerPhotoBytes,
      );
    }
    await Future.wait(<Future<void>>[
      _prefs.setString('learnerName', learnerName),
      _prefs.setInt('learnerAge', learnerAge!),
      _prefs.setString('learnerGradeLevel', learnerGradeLevel),
      _prefs.setString('learnerSection', learnerSection),
      _prefs.setString('learnerGender', learnerGender),
    ]);
    return true;
  }

  Future<void> setLearnerProfile(
    String name,
    int age,
    String gradeLevel, {
    String? section,
    String? gender,
  }) async {
    learnerName = name.trim();
    learnerAge = age;
    learnerGradeLevel = gradeLevel.trim();
    if (section != null) learnerSection = section.trim();
    if (gender != null) {
      learnerGender = gender == 'female' ? 'female' : 'male';
    }
    notifyListeners();
    await _saveProfileToCurrentStore();
  }

  Future<void> saveLearnerSetup({
    required String name,
    required int age,
    required String grade,
    required String section,
    required String gender,
    required String language,
    Uint8List? photo,
  }) async {
    learnerName = name.trim();
    learnerAge = age;
    learnerGradeLevel = grade.trim();
    learnerSection = section.trim();
    learnerGender = gender == 'female' ? 'female' : 'male';
    learnerPhotoBytes = photo;
    languageCode = language == 'tl' ? 'tl' : 'en';
    notifyListeners();
    await _saveProfileToCurrentStore();
    if (_databaseReady) {
      await _database.saveSetting('languageCode', languageCode);
    } else {
      await _prefs.setString('languageCode', languageCode);
    }
  }

  Future<void> setMusic(bool value) async {
    musicOn = value;
    notifyListeners();
    if (_databaseReady) {
      await _database.saveSetting('musicOn', value ? 1 : 0);
    } else {
      await _prefs.setBool('musicOn', value);
    }
  }

  Future<void> setSound(bool value) async {
    soundOn = value;
    notifyListeners();
    if (_databaseReady) {
      await _database.saveSetting('soundOn', value ? 1 : 0);
    } else {
      await _prefs.setBool('soundOn', value);
    }
  }

  Future<void> setLightMode(bool value) async {
    lightMode = value;
    notifyListeners();
    if (_databaseReady) {
      await _database.saveSetting('lightMode', value ? 1 : 0);
    } else {
      await _prefs.setBool('lightMode', value);
    }
  }

  Future<void> setLanguage(String value) async {
    if (value != 'en' && value != 'tl') return;
    languageCode = value;
    notifyListeners();
    if (_databaseReady) {
      await _database.saveSetting('languageCode', value);
    } else {
      await _prefs.setString('languageCode', value);
    }
  }

  int conceptStepForSession(int session) {
    RangeError.checkValueInInterval(session, 1, 8, 'session');
    return _conceptSteps[session - 1];
  }

  Future<void> saveConceptStep(int session, int step) async {
    RangeError.checkValueInInterval(session, 1, 8, 'session');
    final savedStep = step.clamp(0, 10);
    if (savedStep <= _conceptSteps[session - 1]) return;
    _conceptSteps[session - 1] = savedStep;
    notifyListeners();
    final key = 'concept_step_$session';
    if (_databaseReady) {
      await _database.saveSetting(key, savedStep);
    } else {
      await _prefs.setInt(key, savedStep);
    }
  }

  Future<void> recordQuiz(
    int level,
    int score,
    int total, {
    required bool enumeration,
    List<Map<String, Object?>> answers = const <Map<String, Object?>>[],
  }) async {
    if (score > bestQuizScore) bestQuizScore = score;
    final unlocked =
        enumeration ? enumerationUnlockedLevel : multipleChoiceUnlockedLevel;
    if (score >= (total * .6).ceil() && level >= unlocked && level < 5) {
      if (enumeration) {
        enumerationUnlockedLevel = level + 1;
      } else {
        multipleChoiceUnlockedLevel = level + 1;
      }
    }
    notifyListeners();
    if (_databaseReady) {
      final attemptId = _uuid.v4();
      await _database.addQuizAttempt(
        clientId: attemptId,
        level: level,
        score: score,
        total: total,
        enumeration: enumeration,
        answers: answers,
      );
      await _saveDatabaseProgress();
      await _queueMutation(
        entityType: 'quiz_attempt',
        entityId: attemptId,
        payload: <String, Object?>{
          'session_number': level.clamp(1, 8),
          'quiz_type': enumeration ? 'enumeration' : 'multiple_choice',
          'score': score,
          'total': total,
          'completion_percent': total == 0 ? 0 : (score * 100 ~/ total),
          'answers': answers,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } else {
      await Future.wait(<Future<void>>[
        _prefs.setInt('bestQuizScore', bestQuizScore),
        _prefs.setInt('quiz_mc_unlocked', multipleChoiceUnlockedLevel),
        _prefs.setInt('quiz_enum_unlocked', enumerationUnlockedLevel),
      ]);
    }
  }

  Future<void> recordGame(int score) async {
    if (_databaseReady) {
      final attemptId = _uuid.v4();
      await _database.addGameAttempt(attemptId, score);
      await _queueMutation(
        entityType: 'game_attempt',
        entityId: attemptId,
        payload: <String, Object?>{
          'session_number': 1,
          'score': score,
          'completion_percent': score.clamp(0, 100),
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }
    if (score <= bestGameScore) return;
    bestGameScore = score;
    notifyListeners();
    if (_databaseReady) {
      await _saveDatabaseProgress();
    } else {
      await _prefs.setInt('bestGameScore', score);
    }
  }

  Future<void> resetProgress() async {
    bestGameScore = 0;
    bestQuizScore = 0;
    multipleChoiceUnlockedLevel = 1;
    enumerationUnlockedLevel = 1;
    notifyListeners();
    if (_databaseReady) {
      await _database.resetAllProgress();
      await _saveDatabaseProgress();
      return;
    }
    await _prefs.remove('bestGameScore');
    await _prefs.remove('bestQuizScore');
    await _prefs.remove('unlockedQuizLevel');
    await _prefs.remove('quiz_mc_unlocked');
    await _prefs.remove('quiz_enum_unlocked');
  }

  Future<void> resetQuizProgress() async {
    bestQuizScore = 0;
    multipleChoiceUnlockedLevel = 1;
    enumerationUnlockedLevel = 1;
    notifyListeners();
    if (_databaseReady) {
      await _database.resetQuizProgress();
      await _saveDatabaseProgress();
      return;
    }
    await Future.wait([
      _prefs.remove('bestQuizScore'),
      _prefs.remove('unlockedQuizLevel'),
      _prefs.remove('quiz_mc_unlocked'),
      _prefs.remove('quiz_enum_unlocked'),
    ]);
  }

  Future<void> resetGameProgress() async {
    bestGameScore = 0;
    notifyListeners();
    if (_databaseReady) {
      await _database.resetGameProgress();
      await _saveDatabaseProgress();
    } else {
      await _prefs.remove('bestGameScore');
    }
  }

  Future<void> resetSimulationProgress() async {
    if (_databaseReady) await _database.resetSimulationProgress();
    notifyListeners();
  }

  @override
  void dispose() {
    sync.removeListener(notifyListeners);
    sync.dispose();
    super.dispose();
  }
}
