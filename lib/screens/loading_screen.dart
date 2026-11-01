import 'package:flutter/material.dart';

/// Loading logic for StartScreen. This file does not create a separate page.
class StartLoadingController {
  StartLoadingController({required TickerProvider vsync})
      : progress = AnimationController(vsync: vsync);

  static const _homeImages = [
    'assets/images/home_screen_logo.png',
    'assets/images/concept_button.png',
    'assets/images/simulation_button.png',
    'assets/images/quiz_button.png',
    'assets/images/game_button.png',
    'assets/images/exit_button.png',
    'assets/images/settings_icon.png',
    'assets/images/light_mode_background.png',
    'assets/images/dark_mode_background.png',
  ];

  final AnimationController progress;
  int _loadedImages = 0;

  Future<void> _cacheHomeImage(BuildContext context, String path) async {
    await precacheImage(AssetImage(path), context, onError: (_, __) {});
    if (!context.mounted) return;
    _loadedImages++;
    progress.animateTo(
      _loadedImages / _homeImages.length * 0.85,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> prepareHome(BuildContext context) async {
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1200)),
      Future.wait(
        _homeImages.map((path) => _cacheHomeImage(context, path)),
      ),
    ]);

    if (!context.mounted) return;
    try {
      await progress
          .animateTo(
            1,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
          )
          .orCancel;
    } on TickerCanceled {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  void dispose() => progress.dispose();
}
