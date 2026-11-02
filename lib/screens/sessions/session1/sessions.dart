import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../services/app_state.dart';
import '../../../services/audio_service.dart';
import '../../home_screen.dart';
import '../../profile.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({
    super.key,
    required this.state,
    required this.audio,
  });

  final AppState state;
  final AudioService audio;

  static const String _lightBackground =
      'assets/images/sessions_light_background.png';
  static const String _darkBackground =
      'assets/images/sessions_dark_background.png';
  static const String _featuredBanner =
      'assets/images/session_1_ocean_fluids_banner.png';
  static const String _starAsset = 'assets/images/session_star_icon.png';
  static const List<_SessionDay> _days = <_SessionDay>[
    _SessionDay(
      buttonAsset: 'assets/images/Glossy cyan Session 1 button-3.png',
      semanticsLabel: 'Session 1, Introduction to Fluids, unlocked',
      unlocked: true,
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy cyan Session 2 button-1.png',
      semanticsLabel: 'Session 2, Density, locked',
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy Cyan Session 3 Game Button-2.png',
      semanticsLabel: 'Session 3, Pressure, locked',
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy cyan Session 4 button-4.png',
      semanticsLabel: 'Session 4, Buoyancy, locked',
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy cyan Session 5 button-6.png',
      semanticsLabel: 'Session 5, Viscosity, locked',
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy Session 6 game button-5.png',
      semanticsLabel: 'Session 6, Flow, locked',
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy blue Session 7 button-8.png',
      semanticsLabel: "Session 7, Pascal's Principle, locked",
    ),
    _SessionDay(
      buttonAsset: 'assets/images/Glossy cyan Session 8 game button-7.png',
      semanticsLabel:
          "Session 8, Archimedes' Principle and Review Quiz, locked",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isLight = state.lightMode;

    return Scaffold(
      backgroundColor:
          isLight ? const Color(0xFFEAF8FF) : const Color(0xFF001B52),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            isLight ? _lightBackground : _darkBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isLight
                    ? <Color>[
                        Colors.white.withValues(alpha: 0.06),
                        const Color(0xFFE8F8FF).withValues(alpha: 0.16),
                      ]
                    : <Color>[
                        const Color(0xFF001034).withValues(alpha: 0.08),
                        const Color(0xFF001034).withValues(alpha: 0.28),
                      ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double contentWidth = math.min(constraints.maxWidth, 720);
                final double horizontalPadding =
                    (contentWidth * 0.035).clamp(12.0, 24.0);
                final double columnSpacing =
                    (contentWidth * 0.02).clamp(6.0, 12.0);
                final double rowSpacing =
                    (contentWidth * 0.018).clamp(6.0, 11.0);
                return Center(
                  child: SizedBox(
                    width: contentWidth,
                    height: constraints.maxHeight,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        28,
                      ),
                      child: Column(
                        children: <Widget>[
                          _LearnerHeader(
                            state: state,
                            audio: audio,
                            isLight: isLight,
                          ),
                          const SizedBox(height: 12),
                          Semantics(
                            label:
                                'Featured lesson: Session 1, Introduction to Fluids',
                            image: true,
                            child: AspectRatio(
                              aspectRatio: 1816 / 866,
                              child: Image.asset(
                                _featuredBanner,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder:
                                (BuildContext context, BoxConstraints grid) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: columnSpacing,
                                  mainAxisSpacing: rowSpacing,
                                  childAspectRatio: 2098 / 749,
                                ),
                                itemCount: _days.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final _SessionDay day = _days[index];
                                  return _SessionCard(
                                    day: day,
                                    onTap: day.unlocked
                                        ? () {
                                            audio.effect('tap');
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => HomeScreen(
                                                  state: state,
                                                  audio: audio,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnerHeader extends StatelessWidget {
  const _LearnerHeader({
    required this.state,
    required this.audio,
    required this.isLight,
  });

  final AppState state;
  final AudioService audio;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final String learnerName =
        state.learnerName.trim().isEmpty ? 'Learner' : state.learnerName.trim();
    final Color textColor = isLight ? const Color(0xFF031845) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.76)
            : const Color(0xFF00154D).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF19D9FF).withValues(alpha: 0.88),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF00C8FF).withValues(alpha: 0.28),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _LearnerAvatar(state: state, audio: audio),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.text('Hello $learnerName', 'Kumusta $learnerName'),
                    maxLines: 1,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      shadows: isLight
                          ? null
                          : const <Shadow>[
                              Shadow(
                                color: Color(0xFF008DFF),
                                blurRadius: 7,
                              ),
                            ],
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'EXPLORE  •  LEARN  •  GROW DEEPER',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: isLight
                        ? const Color(0xFF075582)
                        : const Color(0xFFD5F7FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(SessionsScreen._starAsset, width: 49, height: 49),
          Text(
            '0',
            style: TextStyle(
              color: textColor,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              shadows: isLight
                  ? null
                  : const <Shadow>[
                      Shadow(color: Color(0xFF00C8FF), blurRadius: 7),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnerAvatar extends StatefulWidget {
  const _LearnerAvatar({required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<_LearnerAvatar> createState() => _LearnerAvatarState();
}

class _LearnerAvatarState extends State<_LearnerAvatar> {
  bool _pressed = false;
  bool _opening = false;

  Future<void> _openProfile() async {
    if (_opening) return;
    setState(() {
      _pressed = false;
      _opening = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    await showLearnerProfileDialog(
      context: context,
      state: widget.state,
      audio: widget.audio,
    );
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final Uint8List? photo = widget.state.learnerPhotoBytes;
    final String fallback = widget.state.learnerGender.toLowerCase() == 'female'
        ? 'assets/images/avatar_girl.png'
        : 'assets/images/avatar_boy.png';

    return Semantics(
      label: 'Open learner profile',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _openProfile,
        child: AnimatedScale(
          scale: _pressed ? 1.12 : 1,
          duration: const Duration(milliseconds: 140),
          curve: _pressed ? Curves.easeOutBack : Curves.easeOut,
          child: Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF00F5FF), Color(0xFF045CFF)],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF00C8FF).withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: photo != null
                  ? Image.memory(photo, fit: BoxFit.cover)
                  : Image.asset(fallback, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatefulWidget {
  const _SessionCard({
    required this.day,
    this.onTap,
  });

  final _SessionDay day;
  final VoidCallback? onTap;

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 430),
    );
    _scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 42,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.08, end: 0.96)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 32,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.96, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 26,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.onTap == null || _controller.isAnimating) return;
    await _controller.forward(from: 0);
    if (!mounted) return;
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        label: widget.day.semanticsLabel,
        button: true,
        enabled: widget.day.unlocked,
        child: InkWell(
          onTap: widget.onTap == null ? null : _handleTap,
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  widget.day.buttonAsset,
                  fit: BoxFit.fill,
                ),
                if (!widget.day.unlocked) ...<Widget>[
                  ColoredBox(color: Colors.white.withValues(alpha: 0.72)),
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF7892B2),
                      size: 34,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionDay {
  const _SessionDay({
    required this.buttonAsset,
    required this.semanticsLabel,
    this.unlocked = false,
  });

  final String buttonAsset;
  final String semanticsLabel;
  final bool unlocked;
}
