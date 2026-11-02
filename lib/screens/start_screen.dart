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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LoginRegisterScreen(
          state: widget.state,
          audio: widget.audio,
        ),
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

class _LoginRegisterScreen extends StatefulWidget {
  const _LoginRegisterScreen({required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<_LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<_LoginRegisterScreen> {
  late final TextEditingController nameController;
  final formKey = GlobalKey<FormState>();
  bool submitting = false;
  bool showLoginError = false;
  bool loginButtonPressed = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.state.hasLearnerProfile ? widget.state.learnerName : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (submitting) return;
    widget.audio.effect('tap');
    FocusManager.instance.primaryFocus?.unfocus();
    final enteredName = nameController.text.trim();
    if (enteredName.isEmpty) {
      if (!mounted) return;
      setState(() => showLoginError = true);
      return;
    }
    setState(() {
      submitting = true;
      showLoginError = false;
    });

    final found = await widget.state.loginLearner(enteredName);
    if (!mounted) return;
    if (!found) {
      setState(() {
        submitting = false;
        showLoginError = true;
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => SessionsScreen(
          state: widget.state,
          audio: widget.audio,
        ),
      ),
      (_) => false,
    );
  }

  void register() {
    widget.audio.effect('tap');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FillOutScreen(
          state: widget.state,
          audio: widget.audio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = widget.state.lightMode;
    final foreground = light ? const Color(0xFF06145A) : Colors.white;
    final secondary = light ? const Color(0xFF172A68) : const Color(0xFFC5EAFF);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            light
                ? 'assets/images/light_mode_background.png'
                : 'assets/images/dark_mode_background.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 54, 22, 42),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: math.max(700, viewport.maxHeight * .84),
                      ),
                      padding: const EdgeInsets.fromLTRB(38, 52, 38, 52),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            light
                                ? 'assets/images/fill_out_panel_light.png'
                                : 'assets/images/fill_out_panel_dark.png',
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(42),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/beacon_wordmark.png',
                              width: 430,
                              height: 145,
                              fit: BoxFit.contain,
                              semanticLabel: 'BEACON',
                            ),
                            const SizedBox(height: 58),
                            Text(
                              'Welcome back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 39,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Continue learning Physics of Fluids.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondary,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 62),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Full name',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: nameController,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              onChanged: (_) {
                                if (showLoginError) {
                                  setState(() => showLoginError = false);
                                }
                              },
                              onFieldSubmitted: (_) => login(),
                              style: TextStyle(
                                color: foreground,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                hintStyle: TextStyle(
                                  color: secondary.withValues(alpha: .68),
                                ),
                                prefixIcon: Image.asset(
                                  light
                                      ? 'assets/images/Royal-blue user silhouette icon-2.png'
                                      : 'assets/images/Cyan profile outline icon-2.png',
                                  width: 30,
                                  height: 30,
                                ),
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 22,
                                ),
                                fillColor: light
                                    ? const Color(0xEFFFFFFF)
                                    : const Color(0xCC031B49),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF0FD9F2),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: light
                                        ? const Color(0xFF0878F9)
                                        : const Color(0xFF0FD9F2),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) =>
                                  SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                              child: showLoginError
                                  ? Padding(
                                      key: const ValueKey('login-error'),
                                      padding: const EdgeInsets.only(top: 18),
                                      child: Image.asset(
                                        'assets/images/validation_message_card.png',
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        semanticLabel:
                                            'Name not found on this device. Check the spelling or use the name you registered with.',
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('no-login-error'),
                                    ),
                            ),
                            const SizedBox(height: 38),
                            Semantics(
                              button: true,
                              label: 'Log in',
                              child: AnimatedScale(
                                scale: loginButtonPressed ? 1.06 : 1,
                                duration: const Duration(milliseconds: 130),
                                curve: Curves.easeOut,
                                child: InkWell(
                                  onTap: submitting ? null : login,
                                  onHighlightChanged: (pressed) {
                                    if (loginButtonPressed != pressed) {
                                      setState(
                                        () => loginButtonPressed = pressed,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(46),
                                  child: submitting
                                      ? const SizedBox(
                                          height: 78,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/Glossy blue Log in button with arrow.png',
                                          width: 440,
                                          fit: BoxFit.contain,
                                          excludeFromSemantics: true,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'New to BEACON? ',
                                  style: TextStyle(
                                    color: foreground,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextButton(
                                  onPressed: register,
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Color(0xFF008EF3),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Works offline • Syncs automatically when online',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: secondary.withValues(alpha: .8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
            width: 140,
            height: 62,
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
                    width: 50,
                    height: 50,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: light
                          ? const Color(0xFFFFC400)
                          : const Color(0xFF8FA8DC),
                      size: 29,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.dark_mode_rounded,
                      color: light
                          ? const Color(0xFFD9E7F5)
                          : const Color(0xFFF8FAFF),
                      size: 29,
                    ),
                  ),
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
