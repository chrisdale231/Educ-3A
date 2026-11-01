import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/start_screen.dart';
import 'services/app_state.dart';
import 'services/audio_service.dart';
import 'services/backend_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (BackendConfig.isConfigured) {
    await Supabase.initialize(
      url: BackendConfig.supabaseUrl,
      publishableKey: BackendConfig.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        persistSession: true,
      ),
    );

    debugPrint('Supabase initialized for ${BackendConfig.supabaseUrl}');
  } else {
    debugPrint(
      'Supabase is not configured. Check services/backend_config.dart.',
    );
  }

  final state = AppState();
  await state.load();

  final audio = AudioService(state);

  runApp(FluidScienceApp(state: state, audio: audio));
}

class FluidScienceApp extends StatefulWidget {
  const FluidScienceApp({
    super.key,
    required this.state,
    required this.audio,
  });

  final AppState state;
  final AudioService audio;

  @override
  State<FluidScienceApp> createState() => _FluidScienceAppState();
}

class _FluidScienceAppState extends State<FluidScienceApp> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.audio.start();
      }
    });
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    widget.audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final light = widget.state.lightMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fluid Science',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF117EAF),
          brightness: light ? Brightness.light : Brightness.dark,
        ),
        scaffoldBackgroundColor:
            light ? const Color(0xFFF5FBFF) : const Color(0xFF0B1D31),
      ),
      home: StartScreen(
        state: widget.state,
        audio: widget.audio,
      ),
    );
  }
}
