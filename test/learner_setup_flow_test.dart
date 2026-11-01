import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_of_fluids/screens/fill_out_screen.dart';
import 'package:physics_of_fluids/screens/sessions.dart';
import 'package:physics_of_fluids/services/app_state.dart';
import 'package:physics_of_fluids/services/audio_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class SilentAudioService extends AudioService {
  SilentAudioService(super.state);

  @override
  Future<void> effect(String name) async {}
}

void main() {
  testWidgets(
      'setup accepts learner details and opens sessions after photo setup',
      (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    tester.view.physicalSize = const Size(630, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    final audio = SilentAudioService(state);
    await tester.pumpWidget(
        MaterialApp(home: FillOutScreen(state: state, audio: audio)));

    await tester.enterText(find.byKey(const ValueKey('learner-name')), 'Ari');
    final female = find.text('Female');
    await tester.tap(female);
    for (final entry in [
      ('age', '16'),
      ('grade', 'Grade 11'),
      ('section', 'A'),
    ]) {
      final field = find.byKey(ValueKey('learner-${entry.$1}'));
      await tester.enterText(field, entry.$2);
    }
    final next = find.bySemanticsLabel('Next: profile picture');
    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(find.text('Add Profile Picture'), findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/avatar_girl.png'),
        findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back to learner details'));
    await tester.pump(const Duration(milliseconds: 180));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.text('Add Profile Picture'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Skip photo for now'));
    await tester.pumpAndSettle();
    expect(find.byType(SessionsScreen), findsOneWidget);
    expect(state.learnerName, 'Ari');
    expect(state.learnerGender, 'female');
    expect(state.languageCode, 'en');
  });
}
