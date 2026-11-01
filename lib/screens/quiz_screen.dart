import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';

class QuizItem {
  const QuizItem(this.prompt, this.choices, this.answer);
  final String prompt;
  final List<String> choices;
  final int answer;
}

const quizSets = <List<QuizItem>>[
  [
    QuizItem(
        'What is mass?',
        [
          'The amount of matter inside an object',
          'The space an object takes up',
          'The speed of an object in water',
          'The shape of a fluid container'
        ],
        0),
    QuizItem('What unit do we use to measure volume?',
        ['Gram (g)', 'Liter (L)', 'Newton (N)', 'Meter (m)'], 1),
    QuizItem(
        'What is density?',
        [
          'How fast an object sinks',
          'How much mass is packed into a certain volume',
          'The weight of water in a tank',
          'The temperature of a liquid'
        ],
        1),
    QuizItem(
        'What is buoyancy (buoyant force)?',
        [
          'The downward pull of gravity',
          'The net upward force exerted by a fluid on an object',
          'The mass of an object in air',
          'The pressure at the bottom of a container'
        ],
        1),
    QuizItem(
        'An object has a lower density than water. What will happen?',
        [
          'It will sink to the bottom',
          'It will float at the surface',
          'It will remain suspended in the middle',
          'It will disappear completely'
        ],
        1),
    QuizItem(
        'An object has a higher density than water. What will happen?',
        [
          'It will float at the surface',
          'It will sink to the bottom',
          'It will remain suspended in the middle',
          'It will fly upward into the air'
        ],
        1),
    QuizItem(
        'An object has the same density as the liquid. What will it do?',
        [
          'Sink rapidly',
          'Pop out of the water',
          'Remain suspended at its depth',
          'Change color'
        ],
        2),
    QuizItem(
        'Why does a heavy iron sphere sink while a wooden cube floats?',
        [
          'Iron has no volume',
          'Iron is denser than water',
          'Iron is softer than wood',
          'Water does not touch metal'
        ],
        1),
    QuizItem(
        'What is fluid displacement?',
        [
          'Water pushed aside by an object',
          'Heat released when an object dissolves',
          'Weight of an empty container',
          'Depth of the ocean floor'
        ],
        0),
    QuizItem(
        'Why can a heavy steel boat float?',
        [
          'Its shape traps air, increasing volume and lowering overall density',
          'Its weight becomes zero',
          'Water freezes under it',
          'Steel loses mass when curved'
        ],
        0),
  ],
  [
    QuizItem(
        'What is mass?',
        [
          'Space an object occupies',
          'Amount of matter in an object',
          'Upward force from a fluid',
          'Ability to float'
        ],
        1),
    QuizItem(
        'What does volume measure?',
        [
          'Amount of matter',
          'Heaviness',
          'Space an object occupies',
          'Upward fluid force'
        ],
        2),
    QuizItem(
        'Which formula calculates density?',
        ['Mass / Volume', 'Volume / Mass', 'Mass x Volume', 'Mass + Volume'],
        0),
    QuizItem(
        'What is buoyancy?',
        [
          'Amount of matter',
          'Space occupied',
          'Downward gravity alone',
          'Upward force exerted by a fluid'
        ],
        3),
    QuizItem(
        "What happens when an object's density is greater than the fluid?",
        [
          'It always floats',
          'It usually sinks',
          'It disappears',
          'It loses mass'
        ],
        1),
    QuizItem(
        'Why does wood float on water?',
        [
          'Wood has no mass',
          'Water has no density',
          "Wood's average density is less than water",
          'Wood has no volume'
        ],
        2),
    QuizItem(
        'Why can an object remain suspended in a fluid?',
        [
          'Its density is about equal to the fluid',
          'It is always denser',
          'It has no mass',
          'It has no buoyancy'
        ],
        0),
    QuizItem(
        'Which is an example of sinking?',
        [
          'A dry leaf on water',
          'A floating cork',
          'A floating plastic ball',
          'A stone moving toward the bottom'
        ],
        3),
    QuizItem(
        'How should floating behavior be determined?',
        [
          'Guess which is heavier',
          'Place objects in water and observe',
          'Measure only color',
          'Assume both float'
        ],
        1),
    QuizItem(
        'Why observe floating and sinking objects?',
        [
          'Prove all objects float',
          'Avoid questions',
          'Understand fluid properties',
          'Show mass and volume are the same'
        ],
        2),
  ],
  [
    QuizItem('Which property describes the amount of matter?',
        ['Volume', 'Buoyancy', 'Density', 'Mass'], 3),
    QuizItem('Which property tells how much space an object occupies?',
        ['Volume', 'Mass', 'Buoyancy', 'Floating'], 0),
    QuizItem('Mass is 20 g and volume is 10 cm3. What is density?',
        ['0.5 g/cm3', '2 g/cm3', '10 g/cm3', '200 g/cm3'], 1),
    QuizItem(
        'Which statement best describes buoyancy?',
        [
          'Amount of matter',
          'Space occupied',
          'Upward force from a fluid',
          'Material in a container'
        ],
        2),
    QuizItem('An object is less dense than water. What will it generally do?',
        ['Float', 'Sink', 'Lose mass', 'Become weightless'], 0),
    QuizItem(
        'Why does a coin sink in water?',
        [
          'It has no volume',
          'Water has no buoyancy',
          'It has no mass',
          'Its density is greater than water'
        ],
        3),
    QuizItem(
        'What does neutrally buoyant mean?',
        [
          'Always rises',
          'Remains suspended because buoyancy balances weight',
          'Has no density',
          'Always sinks'
        ],
        1),
    QuizItem('Which object is most likely to float?',
        ['Iron nail', 'Small stone', 'Cork', 'Metal bolt'], 2),
    QuizItem(
        'A plastic object stays suspended. What should the student do?',
        [
          'Record it and consider density and buoyancy',
          'Say it has no mass',
          'Ignore it',
          'Generalize to all plastic'
        ],
        0),
    QuizItem(
        'Which action demonstrates curiosity?',
        [
          'Refuse to observe',
          'Copy an answer',
          'Ignore results',
          'Ask why objects float or sink'
        ],
        3),
  ],
  [
    QuizItem(
        'Which statement correctly defines mass?',
        [
          'Space occupied',
          'Amount of matter',
          'Upward force from water',
          'Ability to float'
        ],
        1),
    QuizItem('Which unit commonly measures liquid volume?',
        ['Kilogram', 'Gram', 'Milliliter', 'Newton'], 2),
    QuizItem('Mass is 30 g and volume is 15 cm3. What is density?',
        ['2 g/cm3', '0.5 g/cm3', '15 g/cm3', '45 g/cm3'], 0),
    QuizItem(
        'Which best describes floating?',
        [
          'Moving to the bottom',
          'Losing mass in water',
          'Occupying no space',
          'Remaining at or near the surface'
        ],
        3),
    QuizItem(
        'Why does wood float while a metal bolt sinks?',
        [
          'Wood has no mass',
          'Wood is less dense and metal is denser than water',
          'Water has no buoyancy',
          'Metal has no volume'
        ],
        1),
    QuizItem('What force helps an object float?',
        ['Friction', 'Magnetism', 'Buoyant force', 'Electric force'], 2),
    QuizItem(
        'An object has the same density as its fluid. What may happen?',
        [
          'It may remain suspended',
          'It must sink',
          'It must rise',
          'It loses mass'
        ],
        0),
    QuizItem(
        'Which observation indicates sinking?',
        [
          'Stays at surface',
          'Stays suspended',
          'Floats',
          'Moves toward the bottom'
        ],
        3),
    QuizItem(
        'How should a leaf, stone, and cork be compared?',
        [
          'Judge colors',
          'Place each in water and record results',
          'Assume all sink',
          'Avoid observing'
        ],
        1),
    QuizItem(
        'Why ask questions during the experiment?',
        [
          'Finish without learning',
          'Make everything float',
          'Understand scientific principles',
          'Prove equal density'
        ],
        2),
  ],
  [
    QuizItem(
        'What does mass tell us?',
        [
          'How much matter an object contains',
          'How much space it occupies',
          'How strongly fluid pushes',
          'Whether it floats'
        ],
        0),
    QuizItem(
        'What is volume?',
        [
          'Amount of matter',
          'Upward force',
          'Space occupied by an object',
          'Tendency to sink'
        ],
        2),
    QuizItem(
        'Which equation represents density?',
        ['Mass x Volume', 'Mass / Volume', 'Volume - Mass', 'Mass + Volume'],
        1),
    QuizItem(
        'Why can an object float?',
        [
          'It has no mass',
          'It has no volume',
          'Water exerts no force',
          'Buoyant force balances its weight'
        ],
        3),
    QuizItem(
        'Which object will most likely sink?',
        [
          'Low-density cork',
          'Floating wood',
          'Metal denser than water',
          'Neutrally buoyant object'
        ],
        2),
    QuizItem(
        'What happens when average density is lower than the fluid?',
        [
          'It tends to float',
          'It always sinks',
          'It loses mass',
          'It has no volume'
        ],
        0),
    QuizItem(
        'Which describes an object suspended in fluid?',
        [
          'It must be less dense',
          'It may have the same average density as the fluid',
          'It has no buoyancy',
          'It has no weight'
        ],
        1),
    QuizItem('A stone moves downward in water. What does this show?',
        ['No density', 'Floating', 'No mass', 'Sinking'], 3),
    QuizItem(
        'Which procedure best investigates floating and sinking?',
        [
          'Guess',
          'Change observations',
          'Test different objects and record results',
          'Test one and generalize'
        ],
        2),
    QuizItem(
        'Which behavior shows interest in fluid properties?',
        [
          'Refuse to participate',
          'Ask questions and share observations',
          'Ignore results',
          'Copy without understanding'
        ],
        1),
  ],
];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.state, required this.audio});
  final AppState state;
  final AudioService audio;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? setNumber;
  int questionIndex = 0;
  int score = 0;
  int unlockedSet = 1;
  int? selectedChoice;
  bool submitted = false;
  bool finished = false;
  List<Map<String, Object?>> answers = <Map<String, Object?>>[];

  QuizItem get current => quizSets[setNumber! - 1][questionIndex];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (mounted) {
      setState(() => unlockedSet =
          widget.state.multipleChoiceUnlockedLevel.clamp(1, quizSets.length));
    }
  }

  void _startSet(int number) {
    widget.audio.effect('tap');
    setState(() {
      setNumber = number;
      questionIndex = 0;
      score = 0;
      selectedChoice = null;
      submitted = false;
      finished = false;
      answers = <Map<String, Object?>>[];
    });
  }

  void _submit() {
    if (selectedChoice == null || submitted) return;
    final correct = selectedChoice == current.answer;
    answers.add(<String, Object?>{
      'question_index': questionIndex,
      'selected_choice_index': selectedChoice,
      'correct_choice_index': current.answer,
      'is_correct': correct,
    });
    setState(() {
      submitted = true;
      if (correct) score++;
    });
    widget.audio.effect(correct ? 'correct' : 'wrong');
  }

  Future<void> _next() async {
    if (!submitted) return;
    if (questionIndex < 9) {
      setState(() {
        questionIndex++;
        selectedChoice = null;
        submitted = false;
      });
      return;
    }
    await widget.state.recordQuiz(
      setNumber!,
      score,
      10,
      enumeration: false,
      answers: answers,
    );
    if (mounted) {
      setState(() {
        unlockedSet =
            widget.state.multipleChoiceUnlockedLevel.clamp(1, quizSets.length);
        finished = true;
      });
    }
  }

  void _back() {
    if (setNumber != null && !finished) return;
    widget.audio.effect('tap');
    if (setNumber != null) {
      setState(() => setNumber = null);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = !widget.state.lightMode;
    return PopScope(
      canPop: setNumber == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && finished) _back();
      },
      child: Scaffold(
        backgroundColor:
            dark ? const Color(0xFF03163D) : const Color(0xFFEAF7FF),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              dark
                  ? 'assets/images/dark_mode_background.png'
                  : 'assets/images/light_mode_background.png',
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: setNumber == null
                      ? _setPicker(dark)
                      : finished
                          ? _results(dark)
                          : _question(dark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _setPicker(bool dark) {
    const titles = [
      'Mass, density & buoyancy',
      'Floating and sinking',
      'Density calculations',
      'Buoyant force in action',
      'Fluid properties review'
    ];
    return ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        children: [
          _QuizHeader(
            dark: dark,
            title: 'Quiz Sets',
            onBack: _back,
            trailing: _TrophyProgress(unlocked: unlockedSet, dark: dark),
          ),
          const SizedBox(height: 14),
          _ProgressPanel(unlocked: unlockedSet, dark: dark),
          const SizedBox(height: 20),
          for (var number = 1; number <= quizSets.length; number++) ...[
            _SetCard(
              number: number,
              title: titles[number - 1],
              unlocked: number <= unlockedSet,
              dark: dark,
              onTap: () => _startSet(number),
            ),
            const SizedBox(height: 16),
          ],
        ]);
  }

  Widget _question(bool dark) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        children: [
          _QuizHeader(
            dark: dark,
            title: 'Set $setNumber',
            subtitle: 'Question ${questionIndex + 1} of 10',
            onBack: _back,
            backLocked: true,
            trailing: _ScoreBadge(score: score, dark: dark),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (questionIndex + 1) / 10,
              minHeight: 13,
              backgroundColor:
                  dark ? const Color(0xFF183864) : const Color(0xFFC8DFEE),
              color: const Color(0xFF16D6F0),
            ),
          ),
          const SizedBox(height: 22),
          _GlassPanel(
            dark: dark,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUESTION ${questionIndex + 1}',
                  style: const TextStyle(
                    color: Color(0xFF0DBBD6),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  current.prompt,
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF061A5B),
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < current.choices.length; i++) ...[
            _AnswerChoice(
              letter: String.fromCharCode(65 + i),
              text: current.choices[i],
              selected: selectedChoice == i,
              submitted: submitted,
              correct: i == current.answer,
              onTap:
                  submitted ? null : () => setState(() => selectedChoice = i),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          if (!submitted)
            _QuizActionButton(
              label: 'SUBMIT ANSWER',
              icon: Icons.check_rounded,
              onTap: selectedChoice == null ? null : _submit,
            )
          else ...[
            _GlassPanel(
              dark: dark,
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Icon(
                    selectedChoice == current.answer
                        ? Icons.check_circle
                        : Icons.info,
                    color: selectedChoice == current.answer
                        ? Colors.green
                        : Colors.orange,
                    size: 34),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(
                        selectedChoice == current.answer
                            ? 'Correct!'
                            : 'Correct answer: ${String.fromCharCode(65 + current.answer)}',
                        style: const TextStyle(fontWeight: FontWeight.w700))),
              ]),
            ),
            const SizedBox(height: 14),
            _QuizActionButton(
              label: questionIndex == 9 ? 'SEE RESULTS' : 'NEXT QUESTION',
              icon: Icons.arrow_forward_rounded,
              onTap: _next,
            ),
          ],
        ],
      );

  Widget _results(bool dark) =>
      ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 30), children: [
        _QuizHeader(dark: dark, title: 'Quiz Results', onBack: _back),
        const SizedBox(height: 24),
        _GlassPanel(
          dark: dark,
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
          child: Column(children: [
            Image.asset(
              score >= 6
                  ? 'assets/images/session_star_icon.png'
                  : 'assets/images/quiz_progress_button.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            Text('SET $setNumber COMPLETE',
                style: TextStyle(
                    color: dark
                        ? const Color(0xFF70EAFF)
                        : const Color(0xFF0877B5),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4)),
            Text('$score / 10',
                style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF061A5B),
                    fontSize: 64,
                    fontWeight: FontWeight.w900)),
            Text(
                score >= 6
                    ? (setNumber == quizSets.length
                        ? 'Excellent! You completed every quiz set.'
                        : 'Great work! The next set is unlocked.')
                    : 'Try again. You need 6 correct answers to continue.',
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            const SizedBox(height: 22),
            _QuizActionButton(
                label: 'TRY AGAIN',
                icon: Icons.refresh_rounded,
                onTap: () => _startSet(setNumber!)),
            TextButton(
                onPressed: () => setState(() => setNumber = null),
                child: Text('BACK TO ALL SETS',
                    style: TextStyle(
                        color: dark
                            ? const Color(0xFF70EAFF)
                            : const Color(0xFF075BB0),
                        fontWeight: FontWeight.w900))),
          ]),
        ),
      ]);
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.dark,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.trailing,
    this.backLocked = false,
  });

  final bool dark;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;
  final bool backLocked;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 84,
        child: Row(
          children: [
            Semantics(
              button: true,
              enabled: !backLocked,
              label: backLocked
                  ? 'Back locked until all questions are answered'
                  : 'Back',
              child: InkWell(
                onTap: backLocked ? null : onBack,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: backLocked ? .48 : 1,
                        child: Image.asset(
                          dark
                              ? 'assets/images/button_back.png'
                              : 'assets/images/light_button.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (backLocked)
                        Center(
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark
                                  ? const Color(0xE60B2858)
                                  : const Color(0xE6FFFFFF),
                              border: Border.all(
                                color: const Color(0xFF18CDEB),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.lock_rounded,
                              color:
                                  dark ? Colors.white : const Color(0xFF123B72),
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF061A5B),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: dark
                            ? const Color(0xFF9EDCF4)
                            : const Color(0xFF315677),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _TrophyProgress extends StatelessWidget {
  const _TrophyProgress({required this.unlocked, required this.dark});
  final int unlocked;
  final bool dark;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Image.asset(
              'assets/images/quiz_trophy_button.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          for (var i = 1; i <= 5; i++) ...[
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= unlocked
                    ? const Color(0xFF08BFE4)
                    : dark
                        ? const Color(0xFF2B5279)
                        : const Color(0xFFBFD7E8),
              ),
            ),
            if (i < 5) const SizedBox(width: 5),
          ],
        ],
      );
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.unlocked, required this.dark});
  final int unlocked;
  final bool dark;

  @override
  Widget build(BuildContext context) => _GlassPanel(
        dark: dark,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Image.asset(
                    'assets/images/quiz_progress_button.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Quiz Progress',
                          style: TextStyle(
                              color:
                                  dark ? Colors.white : const Color(0xFF061A5B),
                              fontSize: 23,
                              fontWeight: FontWeight.w900)),
                      Text('$unlocked of 5 Sets Available',
                          style: TextStyle(
                              color: dark
                                  ? const Color(0xFFB8D9F5)
                                  : const Color(0xFF263F5E),
                              fontSize: 17)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 1; i <= 5; i++) ...[
                  Expanded(
                    child: Container(
                      height: 17,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: i <= unlocked
                            ? const LinearGradient(colors: [
                                Color(0xFF14E4F2),
                                Color(0xFF0799E8),
                              ])
                            : null,
                        color: i <= unlocked
                            ? null
                            : dark
                                ? const Color(0xFF264666)
                                : const Color(0xFFC7DCE8),
                      ),
                    ),
                  ),
                  if (i < 5) const SizedBox(width: 7),
                ],
              ],
            ),
          ],
        ),
      );
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.number,
    required this.title,
    required this.unlocked,
    required this.dark,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool unlocked;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: unlocked,
        enabled: unlocked,
        label: 'Set $number, $title',
        child: InkWell(
          onTap: unlocked ? onTap : null,
          borderRadius: BorderRadius.circular(34),
          child: Container(
            constraints: const BoxConstraints(minHeight: 124),
            padding: const EdgeInsets.fromLTRB(17, 16, 16, 16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xE80A2854) : const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: unlocked
                    ? const Color(0xFF18CDEB)
                    : dark
                        ? const Color(0xFF315A83)
                        : Colors.white,
                width: unlocked ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33006496),
                    blurRadius: 15,
                    offset: Offset(0, 7)),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: ColorFiltered(
                    colorFilter: unlocked
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.dst,
                          )
                        : const ColorFilter.matrix([
                            0.35,
                            0.35,
                            0.35,
                            0,
                            0,
                            0.35,
                            0.35,
                            0.35,
                            0,
                            0,
                            0.35,
                            0.35,
                            0.35,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                    child: Image.asset(
                      'assets/images/quiz_set_number_$number.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color:
                                  dark ? Colors.white : const Color(0xFF061A5B),
                              fontSize: 21,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        unlocked
                            ? '10 questions  -  Ready to play'
                            : 'Unlock: Score 6/10 in Set ${number - 1}',
                        style: TextStyle(
                          color: unlocked
                              ? const Color(0xFF0879D4)
                              : dark
                                  ? const Color(0xFF9CBBD7)
                                  : const Color(0xFF344B66),
                          fontSize: 15,
                          fontWeight:
                              unlocked ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (unlocked)
                  SizedBox(
                    width: 138,
                    height: 60,
                    child: Image.asset(
                      'assets/images/quiz_start_button.png',
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark
                          ? const Color(0xFF17395D)
                          : const Color(0xFFE1EFF8),
                    ),
                    child: Image.asset('assets/images/session_lock_icon.png'),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.dark});
  final int score;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF0B3568) : const Color(0xFFE0F7FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF31D4EA), width: 2),
        ),
        child: Text('Score $score',
            style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF075BB0),
                fontWeight: FontWeight.w900)),
      );
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.dark,
    required this.child,
    required this.padding,
  });
  final bool dark;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: dark ? const Color(0xE80A2854) : const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF70D8ED), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33005D88), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: child,
      );
}

class _QuizActionButton extends StatelessWidget {
  const _QuizActionButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: onTap == null ? .45 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFF19DFF0), Color(0xFF0752EA)],
              ),
              border: Border.all(color: const Color(0xFF79F4FF), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x6600AEEB), blurRadius: 13),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                Icon(icon, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      );
}

class _AnswerChoice extends StatelessWidget {
  const _AnswerChoice(
      {required this.letter,
      required this.text,
      required this.selected,
      required this.submitted,
      required this.correct,
      required this.onTap});
  final String letter;
  final String text;
  final bool selected;
  final bool submitted;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    var border = const Color(0xFF73D7E8);
    Color? color;
    if (submitted && correct) {
      border = const Color(0xFF35A85A);
      color = const Color(0xFFDDF7E6);
    } else if (submitted && selected) {
      border = const Color(0xFFE45151);
      color = const Color(0xFFFFE2E2);
    } else if (selected) {
      border = const Color(0xFF15BFD9);
      color = const Color(0xFFDDF7FC);
    }
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border:
                  Border.all(color: border, width: selected || correct ? 3 : 2),
              boxShadow: const [
                BoxShadow(color: Color(0x22005D88), blurRadius: 8)
              ]),
          child: Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: border,
                foregroundColor: Colors.white,
                child: Text(letter,
                    style: const TextStyle(fontWeight: FontWeight.w900))),
            const SizedBox(width: 13),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            if (submitted && correct)
              const Icon(Icons.check_circle, color: Color(0xFF269349))
            else if (submitted && selected)
              const Icon(Icons.cancel, color: Color(0xFFD63F3F)),
          ]),
        ),
      ),
    );
  }
}
