import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import 'fill_out_screen.dart';
import 'sessions.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoMotion;
  late final AnimationController _buttonMotion;

  @override
  void initState() {
    super.initState();
    _logoMotion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _buttonMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoMotion.dispose();
    _buttonMotion.dispose();
    super.dispose();
  }

  void _start(BuildContext context) {
    widget.audio.effect('tap');
    widget.audio.syncMusic();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.state.hasLearnerProfile
            ? SessionsScreen(state: widget.state, audio: widget.audio)
            : FillOutScreen(state: widget.state, audio: widget.audio),
      ),
    );
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
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: _ThemeModeButton(
                  light: light,
                  onTap: () {
                    widget.audio.effect('tap');
                    widget.state.setLightMode(!light);
                  },
                ),
              ),
            ),
          ),
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
                    AnimatedBuilder(
                      animation: _logoMotion,
                      builder: (context, child) {
                        final phase = _logoMotion.value * math.pi * 2;
                        return Transform.translate(
                          offset: Offset(
                            math.cos(phase) * 3,
                            math.sin(phase) * 3,
                          ),
                          child: Transform.rotate(
                            angle: math.sin(phase) * 0.008,
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/Logo_start.png',
                                  width: logoWidth,
                                  semanticLabel:
                                      'BEACON: Explore, Learn, Apply',
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _LogoWaterPainter(phase),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(flex: 3),
                    AnimatedBuilder(
                      animation: _buttonMotion,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, -4 * _buttonMotion.value),
                        child: Transform.scale(
                          scale: 1 + 0.025 * _buttonMotion.value,
                          child: child,
                        ),
                      ),
                      child: Semantics(
                        button: true,
                        label: 'Start',
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
                    const Spacer(flex: 2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({required this.light, required this.onTap});

  final bool light;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: light ? 'Switch to dark mode' : 'Switch to light mode',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 112,
            height: 54,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: light ? const Color(0xEFFFFFFF) : const Color(0xE60B2C68),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF12DDF5), width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x6612DDF5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment:
                      light ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: light
                          ? const Color(0xFFF7FCFF)
                          : const Color(0xFF3152D7),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x5512DDF5),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        color: light
                            ? const Color(0xFFFFC400)
                            : const Color(0xFF8FA8DC),
                        size: 27,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        Icons.dark_mode_rounded,
                        color: light ? Colors.white : const Color(0xFFF2F5FF),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoWaterPainter extends CustomPainter {
  const _LogoWaterPainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Rect.fromLTWH(
      size.width * 0.14,
      size.height * 0.01,
      size.width * 0.72,
      size.height * 0.69,
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(circle));

    for (var layer = 0; layer < 2; layer++) {
      final wave = Path();
      final surface = Path();
      final base = circle.top + circle.height * (0.58 + layer * 0.10);
      for (double x = circle.left; x <= circle.right + 3; x += 3) {
        final progress = (x - circle.left) / circle.width;
        final y = base +
            math.sin(progress * math.pi * 3 + phase * (layer == 0 ? 1 : -0.7)) *
                circle.height *
                0.035;
        if (x == circle.left) {
          wave.moveTo(x, y);
          surface.moveTo(x, y);
        } else {
          wave.lineTo(x, y);
          surface.lineTo(x, y);
        }
      }
      surface
        ..lineTo(circle.right, circle.bottom)
        ..lineTo(circle.left, circle.bottom)
        ..close();
      canvas.drawPath(
        surface,
        Paint()
          ..color =
              layer == 0 ? const Color(0x225ADFFF) : const Color(0x183BBAFF),
      );
      canvas.drawPath(
        wave,
        Paint()
          ..color = const Color(0x665EE7FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    canvas.drawArc(
      circle.deflate(2),
      phase,
      math.pi * 0.27,
      false,
      Paint()
        ..color = const Color(0x8877EEFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LogoWaterPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
