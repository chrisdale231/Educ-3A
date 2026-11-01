import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import 'fill_out_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final VideoPlayerController _video;
  late final AnimationController _buttonPulse;
  late final Animation<double> _buttonScale;
  bool _videoReady = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _buttonPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _buttonScale = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _buttonPulse, curve: Curves.easeInOut),
    );
    _video = VideoPlayerController.asset(
      'assets/video/beacon_animated_background_h264.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    unawaited(_initializeVideo());
  }

  Future<void> _initializeVideo() async {
    try {
      await _video.initialize();
      await _video.setLooping(true);
      await _video.setVolume(0);
      if (!mounted) return;
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed ||
          WidgetsBinding.instance.lifecycleState == null) {
        await _video.play();
      }
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      // The matching image remains visible if video playback is unavailable.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_videoReady) return;
    unawaited(_updatePlayback(state == AppLifecycleState.resumed));
  }

  Future<void> _updatePlayback(bool playing) async {
    try {
      if (playing) {
        await _video.play();
      } else {
        await _video.pause();
      }
    } catch (_) {
      if (mounted) setState(() => _videoReady = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _buttonPulse.dispose();
    unawaited(_video.dispose());
    super.dispose();
  }

  Future<void> _start(BuildContext context) async {
    if (_starting) return;
    _starting = true;
    await _buttonPulse.forward();
    await _buttonPulse.reverse();
    if (!mounted || !context.mounted) return;
    setState(() => _starting = true);
    widget.audio.effect('tap');
    widget.audio.syncMusic();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'fill-out'),
      builder: (_) => FillOutScreen(state: widget.state, audio: widget.audio),
    ))
        .then((_) {
      if (mounted) setState(() => _starting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final light = widget.state.lightMode;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            light
                ? 'assets/images/light_mode_background.png'
                : 'assets/images/dark_mode_background.png',
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
          if (_videoReady && !light) ...[
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _video.value.size.width,
                  height: _video.value.size.height,
                  child: VideoPlayer(_video),
                ),
              ),
            ),
            const Positioned.fill(
              child: ColoredBox(color: Color(0xA6000C24)),
            ),
          ],
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final logoWidth = math.min(
                  constraints.maxWidth * 0.78,
                  constraints.maxHeight * 0.44,
                );
                final buttonWidth = math.min(
                  constraints.maxWidth * 0.62,
                  280.0,
                );

                return Column(
                  children: [
                    const Spacer(flex: 2),
                    Image.asset(
                      'assets/images/Logo_start.png',
                      width: logoWidth,
                      semanticLabel: 'BEACON: Explore, Learn, Apply',
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: buttonWidth,
                      height: math.max(buttonWidth / 3, 78),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _starting
                            ? const SizedBox.shrink()
                            : Semantics(
                                key: const ValueKey('start-button'),
                                button: true,
                                label: 'Start',
                                child: ScaleTransition(
                                  scale: _buttonScale,
                                  child: InkWell(
                                    onTap: () => _start(context),
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.asset(
                                      light
                                          ? 'assets/images/Start_light.png'
                                          : 'assets/images/Start_dark.png',
                                      width: buttonWidth,
                                      excludeFromSemantics: true,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: _StartThemeToggle(
                  lightMode: light,
                  onTap: () {
                    widget.audio.effect('tap');
                    widget.state.setLightMode(!light);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartThemeToggle extends StatelessWidget {
  const _StartThemeToggle({
    required this.lightMode,
    required this.onTap,
  });

  final bool lightMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        toggled: !lightMode,
        label: lightMode ? 'Switch to dark mode' : 'Switch to light mode',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 92,
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: lightMode
                    ? const <Color>[Color(0xFFF8FDFF), Color(0xFFDDF5FF)]
                    : const <Color>[Color(0xFF043B80), Color(0xFF101A7B)],
              ),
              border: Border.all(
                color: const Color(0xFF2BE6FF),
                width: 2,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x9900CFFF),
                  blurRadius: 13,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: Color(0xFFFFC400),
                    size: 21,
                  ),
                ),
                const Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.nightlight_round,
                    color: Color(0xFFFFFFFF),
                    size: 21,
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  alignment:
                      lightMode ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: lightMode
                            ? const <Color>[
                                Color(0xFFFFFFFF),
                                Color(0xFFCFF7FF),
                              ]
                            : const <Color>[
                                Color(0xFFB51CFF),
                                Color(0xFF075BFF),
                              ],
                      ),
                      border: Border.all(
                        color: lightMode
                            ? const Color(0xFF70EDFF)
                            : const Color(0xFFFF65FB),
                        width: 2,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: (lightMode
                                  ? const Color(0xFF00D9FF)
                                  : const Color(0xFFCA27FF))
                              .withValues(alpha: 0.75),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      lightMode
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                      color: lightMode ? const Color(0xFFFFC400) : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
