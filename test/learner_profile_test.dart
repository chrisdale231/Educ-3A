import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_of_fluids/screens/profile.dart';
import 'package:physics_of_fluids/services/app_state.dart';
import 'package:physics_of_fluids/services/audio_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _SilentAudioService extends AudioService {
  _SilentAudioService(super.state);

  @override
  Future<void> effect(String name) async {}

  @override
  Future<void> dispose() async {
    state.removeListener(syncMusic);
  }
}

void main() {
  testWidgets('phone profile shows saved values and saves edits',
      (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    state
      ..learnerName = 'Chrisdale'
      ..learnerAge = 23
      ..learnerGradeLevel = '12'
      ..learnerSection = 'CDE'
      ..learnerGender = 'male';
    final audio = _SilentAudioService(state);
    addTearDown(audio.dispose);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: LearnerProfileButton(state: state, audio: audio),
        ),
      ),
    ));

    await tester.tap(find.byType(LearnerProfileButton));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(LearnerProfileScreen)).width,
        greaterThan(300));
    expect(find.text('Chrisdale'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('CDE'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.key == const ValueKey('learner-profile-avatar') &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/avatar_boy.png',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(4));

    await tester.enterText(find.byKey(const ValueKey('profile-name')), 'Ari');
    await tester.enterText(find.byKey(const ValueKey('profile-age')), '16');
    await tester.enterText(
        find.byKey(const ValueKey('profile-grade')), 'Grade 11');
    await tester.enterText(find.byKey(const ValueKey('profile-section')), 'A');
    await tester.tap(find.text('Female'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(state.learnerName, 'Ari');
    expect(state.learnerAge, 16);
    expect(state.learnerGradeLevel, 'Grade 11');
    expect(state.learnerSection, 'A');
    expect(state.learnerGender, 'female');
    expect(find.text('Ari'), findsOneWidget);
    expect(find.text('Grade 11'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
