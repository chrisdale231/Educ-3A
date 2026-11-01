import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:physics_of_fluids/main.dart';
import 'package:physics_of_fluids/services/app_state.dart';
import 'package:physics_of_fluids/services/audio_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _SilentAudioService extends AudioService {
  _SilentAudioService(super.state);

  @override
  Future<void> start() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  testWidgets('application starts with the current app shell', (tester) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final state = AppState();
    final audio = _SilentAudioService(state);

    await tester.pumpWidget(FluidScienceApp(state: state, audio: audio));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
