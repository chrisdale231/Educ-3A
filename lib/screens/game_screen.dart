import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../widgets/fluid_ui.dart';

class _Challenge {
  const _Challenge(
      this.objectName, this.objectDensity, this.liquidName, this.liquidDensity);
  final String objectName;
  final int objectDensity;
  final String liquidName;
  final int liquidDensity;
  bool get floats => objectDensity < liquidDensity;
}

const _challenges = [
  _Challenge('Wood', 600, 'Water', 1000),
  _Challenge('Steel', 7800, 'Water', 1000),
  _Challenge('Ice', 917, 'Water', 1000),
  _Challenge('Stone', 2600, 'Water', 1000),
  _Challenge('Cork', 240, 'Oil', 850),
  _Challenge('Aluminum', 2700, 'Oil', 850),
  _Challenge('Plastic block', 950, 'Water', 1000),
  _Challenge('Glass', 2500, 'Saltwater', 1025),
  _Challenge('Pine wood', 500, 'Oil', 850),
  _Challenge('Dense plastic', 1100, 'Saltwater', 1025),
  _Challenge('Wax', 900, 'Water', 1000),
  _Challenge('Copper', 8960, 'Saltwater', 1025),
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.state, required this.audio});
  final AppState state;
  final AudioService audio;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _random = Random();
  Timer? _timer;
  List<_Challenge> rounds = [];
  int round = 0;
  int score = 0;
  int seconds = 15;
  bool started = false;
  bool finished = false;
  bool? picked;

  void _start() {
    _timer?.cancel();
    rounds = [..._challenges]..shuffle(_random);
    setState(() {
      round = 0;
      score = 0;
      seconds = 15;
      started = true;
      finished = false;
      picked = null;
    });
    _startTimer();
    widget.audio.effect('tap');
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (seconds <= 1) {
        timer.cancel();
        _answer(null);
      } else {
        setState(() => seconds--);
      }
    });
  }

  void _answer(bool? guess) {
    if (picked != null || finished) return;
    _timer?.cancel();
    final correct = guess == rounds[round].floats;
    setState(() {
      picked = guess ?? !rounds[round].floats; // Reveals the answer on timeout.
      if (correct && guess != null) score += 10 + seconds;
    });
    widget.audio.effect(correct && guess != null ? 'correct' : 'wrong');
  }

  Future<void> _next() async {
    if (round < 9) {
      setState(() {
        round++;
        seconds = 15;
        picked = null;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      await widget.state.recordGame(score);
      if (mounted) setState(() => finished = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Float or Sink')),
        body: FluidBackdrop(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(padding: const EdgeInsets.all(20), children: [
            if (!started)
              _intro(context)
            else if (finished)
              _results(context)
            else
              _play(context),
          ]),
        ))),
      );

  Widget _intro(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PageTitle('Float or Sink?',
            subtitle: 'A quick game about density.'),
        FluidCard(
            child: Column(children: [
          Image.asset('assets/images/game_button.png', height: 105),
          const SizedBox(height: 12),
          const Text(
              'Compare the object’s density with the liquid. Pick Float or Sink in 15 seconds. There are 10 rounds.',
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Best score: ${widget.state.bestGameScore}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 20),
        FilledButton(onPressed: _start, child: const Text('Start game')),
      ]);

  Widget _play(BuildContext context) {
    final challenge = rounds[round];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PageTitle('Round ${round + 1} / 10',
          subtitle: 'Score: $score • Time: $seconds seconds'),
      LinearProgressIndicator(value: seconds / 15, minHeight: 9),
      const SizedBox(height: 20),
      FluidCard(
          child: Column(children: [
        const Icon(Icons.water_drop, size: 78, color: sea),
        Text(challenge.objectName,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text('Object density: ${challenge.objectDensity} kg/m³'),
        const SizedBox(height: 7),
        Text(
            '${challenge.liquidName} density: ${challenge.liquidDensity} kg/m³'),
        const SizedBox(height: 16),
        Text('Will it float or sink in ${challenge.liquidName.toLowerCase()}?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
      ])),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(
            child: FilledButton.icon(
                onPressed: picked == null ? () => _answer(true) : null,
                icon: const Icon(Icons.arrow_upward),
                label: const Text('FLOAT'))),
        const SizedBox(width: 12),
        Expanded(
            child: FilledButton.icon(
                onPressed: picked == null ? () => _answer(false) : null,
                icon: const Icon(Icons.arrow_downward),
                label: const Text('SINK'))),
      ]),
      if (picked != null) ...[
        const SizedBox(height: 16),
        FluidCard(
            child: Text('${challenge.floats ? 'Float' : 'Sink'}! '
                '${challenge.objectName} is ${challenge.floats ? 'less' : 'more'} dense than ${challenge.liquidName.toLowerCase()}.')),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: _next,
            child: Text(round == 9 ? 'Finish' : 'Next round')),
      ],
    ]);
  }

  Widget _results(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PageTitle('Game complete!'),
        FluidCard(
            child: Column(children: [
          const Icon(Icons.emoji_events, size: 80, color: Color(0xFFFFB443)),
          Text('$score points',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: sea, fontWeight: FontWeight.w900)),
          Text('Best score: ${widget.state.bestGameScore}'),
          const SizedBox(height: 18),
          FilledButton(onPressed: _start, child: const Text('Play again')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Home')),
        ])),
      ]);
}
