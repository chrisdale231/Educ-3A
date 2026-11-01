import 'dart:typed_data';

import 'app_state.dart';

class LearnerSetup {
  LearnerSetup(AppState state)
      : name = state.learnerName,
        age = state.learnerAge?.toString() ?? '',
        grade = state.learnerGradeLevel,
        section = state.learnerSection,
        gender = state.learnerGender,
        language = '',
        photo = state.learnerPhotoBytes;

  String name;
  String age;
  String grade;
  String section;
  String gender;
  String language;
  Uint8List? photo;
}
