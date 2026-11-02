import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/audio_service.dart';
import 'exit.dart';
import 'profile.dart';
import 'settings_screen.dart';
import 'sessions/session1/concept_screen.dart';
import 'sessions/session1/game_screen.dart';
import 'sessions/session1/quiz_screen.dart';
import 'sessions/session1/simulation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  void _go(Widget page) {
    widget.audio.effect('tap');
    widget.audio.syncMusic();
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.state.lightMode
        ? 'assets/images/light_mode_background.png'
        : 'assets/images/dark_mode_background.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(background, fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LearnerProfileButton(
                        state: widget.state,
                        audio: widget.audio,
                      ),
                      _ImageIconButton(
                        tooltip: 'Settings',
                        asset: 'assets/images/settings_icon.png',
                        onTap: () => _go(SettingsScreen(
                          state: widget.state,
                          audio: widget.audio,
                        )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 430,
                          height: 900,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const _BeaconHomeLogo(),
                                const SizedBox(height: 32),
                                _HomeAssetButton(
                                  semanticsLabel: 'Concept',
                                  asset: 'assets/images/concept_button.png',
                                  onTap: () => _go(
                                    ConceptScreen(state: widget.state),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _HomeAssetButton(
                                  semanticsLabel: 'Simulation',
                                  asset: 'assets/images/simulation_button.png',
                                  onTap: () => _go(
                                    SimulationScreen(audio: widget.audio),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _HomeAssetButton(
                                  semanticsLabel: 'Quiz',
                                  asset: 'assets/images/quiz_button.png',
                                  onTap: () => _go(QuizScreen(
                                    state: widget.state,
                                    audio: widget.audio,
                                  )),
                                ),
                                const SizedBox(height: 8),
                                _HomeAssetButton(
                                  semanticsLabel: 'Game',
                                  asset: 'assets/images/game_button.png',
                                  onTap: () => _go(GameScreen(
                                    state: widget.state,
                                    audio: widget.audio,
                                  )),
                                ),
                                const SizedBox(height: 8),
                                _HomeAssetButton(
                                  semanticsLabel: 'Exit',
                                  asset: 'assets/images/exit_button.png',
                                  onTap: () => requestAppExit(
                                    context,
                                    widget.audio,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeaconHomeLogo extends StatelessWidget {
  const _BeaconHomeLogo();

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/home_screen_logo.png',
        height: 280,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
}

class _ImageIconButton extends StatefulWidget {
  const _ImageIconButton({
    required this.tooltip,
    required this.asset,
    required this.onTap,
  });

  final String tooltip;
  final String asset;
  final VoidCallback onTap;

  @override
  State<_ImageIconButton> createState() => _ImageIconButtonState();
}

class _ImageIconButtonState extends State<_ImageIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.tooltip,
        child: Tooltip(
          message: widget.tooltip,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 1.1 : 1,
              duration: const Duration(milliseconds: 110),
              child: Image.asset(
                widget.asset,
                width: 66,
                height: 66,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
}

class _HomeAssetButton extends StatefulWidget {
  const _HomeAssetButton({
    required this.semanticsLabel,
    required this.asset,
    required this.onTap,
  });

  final String semanticsLabel;
  final String asset;
  final VoidCallback onTap;

  @override
  State<_HomeAssetButton> createState() => _HomeAssetButtonState();
}

class _HomeAssetButtonState extends State<_HomeAssetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: widget.semanticsLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 1.035 : 1,
            duration: const Duration(milliseconds: 110),
            curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: AspectRatio(
                  aspectRatio: 3,
                  child: Image.asset(
                    widget.asset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
