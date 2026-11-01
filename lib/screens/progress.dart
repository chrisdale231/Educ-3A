import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import 'sessions.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final dark = !state.lightMode;
        final unlocked = state.multipleChoiceUnlockedLevel.clamp(1, 5);
        final quizPercent =
            (state.bestQuizScore.clamp(0, 10) / 10 * 100).round();
        final gamePercent =
            (state.bestGameScore.clamp(0, 12) / 12 * 100).round();
        final setPercent = (((unlocked - 1) / 5) * 100).round();
        final overall = ((quizPercent + gamePercent + setPercent) / 3).round();
        final fg = dark ? Colors.white : const Color(0xFF071747);
        final secondary =
            dark ? const Color(0xFFB9D9FF) : const Color(0xFF45689E);

        return Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF00123E) : const Color(0xFFEAF7FF),
              image: DecorationImage(
                image: AssetImage(dark
                    ? 'assets/images/progress_background_dark.png'
                    : 'assets/images/progress_background_light.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 34),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 940),
                        child: Column(
                          children: [
                            _Header(
                              dark: dark,
                              onBack: () {
                                audio.effect('tap');
                                Navigator.pop(context);
                              },
                              onTheme: () {
                                audio.effect('tap');
                                state.setLightMode(!state.lightMode);
                              },
                            ),
                            const SizedBox(height: 8),
                            _Hero(dark: dark),
                            const SizedBox(height: 14),
                            _OverviewCard(
                              dark: dark,
                              overall: overall,
                              foreground: fg,
                              secondary: secondary,
                              quizScore: state.bestQuizScore,
                              gameScore: state.bestGameScore,
                              unlocked: unlocked,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(builder: (context, box) {
                              final expandedWidth = box.maxWidth + 24;
                              final cardWidth = (expandedWidth - 12) / 3;
                              final cardHeight = cardWidth / .71;
                              return SizedBox(
                                width: box.maxWidth,
                                height: cardHeight,
                                child: OverflowBox(
                                  minWidth: expandedWidth,
                                  maxWidth: expandedWidth,
                                  minHeight: cardHeight,
                                  maxHeight: cardHeight,
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: expandedWidth,
                                    height: cardHeight,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _CategoryCard(
                                            width: cardWidth,
                                            dark: dark,
                                            lightCard:
                                                'assets/images/simulation_light_inside_only.png',
                                            darkCard:
                                                'assets/images/simulation_dark_inside_only.png',
                                            buttonImage:
                                                'assets/images/Neon View Details Button-8.png',
                                            title: 'Simulation',
                                            value: 'Available'),
                                        const SizedBox(width: 6),
                                        _CategoryCard(
                                            width: cardWidth,
                                            dark: dark,
                                            lightCard:
                                                'assets/images/quiz_light_inside_only.png',
                                            darkCard:
                                                'assets/images/quiz_dark_inside_only.png',
                                            buttonImage:
                                                'assets/images/Neon purple View Details button-7.png',
                                            title: 'Quiz',
                                            value:
                                                '${state.bestQuizScore}/10 best score'),
                                        const SizedBox(width: 6),
                                        _CategoryCard(
                                            width: cardWidth,
                                            dark: dark,
                                            lightCard:
                                                'assets/images/game_light_inside_only.png',
                                            darkCard:
                                                'assets/images/game_dark_inside_only.png',
                                            buttonImage:
                                                'assets/images/Glossy Neon View Details Button-9.png',
                                            title: 'Game',
                                            value:
                                                '${state.bestGameScore}/12 best score'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            _LearningSets(
                              dark: dark,
                              unlocked: unlocked,
                              state: state,
                              audio: audio,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.dark, required this.onBack, required this.onTheme});
  final bool dark;
  final VoidCallback onBack;
  final VoidCallback onTheme;
  @override
  Widget build(BuildContext context) => Row(children: [
        _GlassIcon(
            dark: dark,
            onTap: onBack,
            icon: Icons.arrow_back_rounded,
            size: 58),
        const SizedBox(width: 14),
        Expanded(
            child: Text('My Progress',
                style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF060B3E),
                    fontSize: 34,
                    fontWeight: FontWeight.w900))),
        _ThemePill(dark: dark, onTap: onTheme),
      ]);
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({required this.dark, required this.onTap});
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 92,
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: dark ? const Color(0xCC071945) : const Color(0xEFFFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF62CFFF), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x5500AEEF), blurRadius: 10)
            ],
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                alignment: dark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? const Color(0xFF6E36F5) : Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Color(0x6600C8FF), blurRadius: 8)
                    ],
                  ),
                ),
              ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                      width: 36,
                      child: Icon(Icons.light_mode_rounded,
                          color: Color(0xFFFFC400), size: 23))),
              const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                      width: 36,
                      child: Icon(Icons.dark_mode_rounded,
                          color: Color(0xFF7EA5FF), size: 22))),
            ],
          ),
        ),
      );
}

class _GlassIcon extends StatelessWidget {
  const _GlassIcon(
      {required this.dark,
      required this.onTap,
      required this.icon,
      required this.size});
  final bool dark;
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size),
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      dark ? const Color(0xCC082B67) : const Color(0xDDF6FCFF),
                  border: Border.all(color: const Color(0xFF54CFFF), width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x5500AEEF), blurRadius: 12)
                  ]),
              child: Icon(icon,
                  color: dark ? Colors.white : const Color(0xFF071747),
                  size: size * .55))));
}

class _Hero extends StatelessWidget {
  const _Hero({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 150,
      child: Row(children: [
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text('KEEP LEARNING.\nGO FURTHER.',
                  style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF071747),
                      fontSize: 27,
                      height: .95,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 9),
              Text('Your journey in Senior High starts here.',
                  style: TextStyle(
                      color: dark
                          ? const Color(0xFFB9E4FF)
                          : const Color(0xFF45689E),
                      fontSize: 17,
                      fontWeight: FontWeight.w600))
            ])),
        Image.asset('assets/images/progress_header_cap.png',
            width: 190, height: 150, fit: BoxFit.contain),
      ]));
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard(
      {required this.dark,
      required this.overall,
      required this.foreground,
      required this.secondary,
      required this.quizScore,
      required this.gameScore,
      required this.unlocked});
  final bool dark;
  final int overall, quizScore, gameScore, unlocked;
  final Color foreground, secondary;
  @override
  Widget build(BuildContext context) => _Panel(
      dark: dark,
      child: Column(children: [
        Row(children: [
          SizedBox(
              width: 150,
              height: 150,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                    width: 132,
                    height: 132,
                    child: CircularProgressIndicator(
                        value: overall / 100,
                        strokeWidth: 15,
                        backgroundColor: dark
                            ? const Color(0xFF183363)
                            : const Color(0xFFD7E7F4),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF12CFF2)))),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$overall%',
                      style: TextStyle(
                          color: foreground,
                          fontSize: 35,
                          fontWeight: FontWeight.w900)),
                  Text('Overall\nCompletion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: secondary,
                          height: 1.05,
                          fontWeight: FontWeight.w700))
                ])
              ])),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text("You're Making Great Progress!",
                    style: TextStyle(
                        color: foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                Text(
                    'Stay consistent. Every effort brings you closer to your goals.',
                    style:
                        TextStyle(color: secondary, fontSize: 16, height: 1.2)),
                const SizedBox(height: 14),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                        value: overall / 100,
                        minHeight: 18,
                        backgroundColor: dark
                            ? const Color(0xFF102852)
                            : const Color(0xFFD5E6F5),
                        valueColor:
                            const AlwaysStoppedAnimation(Color(0xFF16CDEA))))
              ]))
        ]),
        const SizedBox(height: 16),
        _MetricsImagePanel(
          dark: dark,
          values: ['${unlocked - 1}', '$quizScore', '0', '$gameScore'],
        ),
      ]));
}

class _Panel extends StatelessWidget {
  const _Panel({required this.dark, required this.child});
  final bool dark;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: dark ? const Color(0xE60A214E) : const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF55CFFF), width: 2),
          boxShadow: const [
            BoxShadow(color: Color(0x440087D4), blurRadius: 18)
          ]),
      child: child);
}

class _MetricsImagePanel extends StatelessWidget {
  const _MetricsImagePanel({required this.dark, required this.values});

  final bool dark;
  final List<String> values;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxWidth / 3;
          return SizedBox(
            width: constraints.maxWidth,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  dark
                      ? 'assets/images/Glowing dark-blue rounded UI panel.png'
                      : 'assets/images/Crisp Four-Metric Progress Dashboard.png',
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * .47,
                  child: Row(
                    children: values
                        .map(
                          (value) => Expanded(
                            child: Text(
                              value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: dark
                                    ? Colors.white
                                    : const Color(0xFF071747),
                                fontSize: (constraints.maxWidth * .038)
                                    .clamp(16.0, 30.0),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.width,
      required this.dark,
      required this.lightCard,
      required this.darkCard,
      required this.buttonImage,
      required this.title,
      required this.value});
  final double width;
  final bool dark;
  final String lightCard, darkCard, buttonImage, title, value;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 0.71,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              dark ? darkCard : lightCard,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
              semanticLabel: title,
            ),
            Positioned(
              left: width * .08,
              right: width * .08,
              bottom: width * .28,
              height: width * .20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      dark ? const Color(0xB3081B48) : const Color(0xDDE8F8FF),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: title == 'Quiz'
                        ? const Color(0xFFB66BFF)
                        : const Color(0xFF29CCE9),
                  ),
                ),
                child: Center(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF071747),
                      fontSize: width < 180 ? 10 : 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: width * .015,
              right: width * .015,
              bottom: width * .025,
              height: width * .29,
              child: Semantics(
                button: true,
                label: 'View $title details',
                child: Transform.scale(
                  scaleX: 1.08,
                  scaleY: 1.12,
                  child: Image.asset(
                    buttonImage,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
}

class _LearningSets extends StatelessWidget {
  const _LearningSets({
    required this.dark,
    required this.unlocked,
    required this.state,
    required this.audio,
  });

  final bool dark;
  final int unlocked;
  final AppState state;
  final AudioService audio;

  static const _titles = [
    'Introduction to Concepts',
    'Key Theories and Models',
    'Applications and Examples',
    'Practice and Problem Solving',
    'Advanced Exploration',
    'Real-World Connections',
    'Integrated Activities',
    'Review and Assessment',
  ];

  @override
  Widget build(BuildContext context) => _Panel(
        dark: dark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Image.asset('assets/images/progress_sessions_icon.png',
                  width: 52, height: 52),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Learning Sessions',
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF071747),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                childAspectRatio: 1.82,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final sessionIndex = index;
                final available = sessionIndex < unlocked;
                final complete = sessionIndex < unlocked - 1;
                final progress = complete
                    ? 1.0
                    : available
                        ? .6
                        : 0.0;
                final percentage = (progress * 100).round();
                final accent = complete
                    ? const Color(0xFF11B968)
                    : available
                        ? const Color(0xFF148BFF)
                        : const Color(0xFF8399B4);

                return Semantics(
                  button: available,
                  enabled: available,
                  label: available
                      ? 'Play Session ${sessionIndex + 1}'
                      : 'Session ${sessionIndex + 1} locked',
                  child: GestureDetector(
                    onTap: available
                        ? () {
                            audio.effect('tap');
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    SessionsScreen(state: state, audio: audio),
                              ),
                            );
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF071A40)
                            : const Color(0xFFF4FAFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF8FCFFF)),
                      ),
                      child: Column(children: [
                        Expanded(
                          child: Row(children: [
                            Icon(
                              complete
                                  ? Icons.check_circle_rounded
                                  : available
                                      ? Icons.play_circle_fill_rounded
                                      : Icons.lock_rounded,
                              color: accent,
                              size: 29,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Session ${sessionIndex + 1}\n${_titles[sessionIndex]}',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: dark
                                      ? Colors.white
                                      : const Color(0xFF071747),
                                  fontSize: 12,
                                  height: 1.08,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                backgroundColor: dark
                                    ? const Color(0xFF263C63)
                                    : const Color(0xFFD7E5F1),
                                valueColor: AlwaysStoppedAnimation(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          SizedBox(
                            width: 34,
                            child: Text(
                              '$percentage%',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
}
