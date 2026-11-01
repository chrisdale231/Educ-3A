import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/audio_service.dart';
import '../widgets/fluid_ui.dart';

Future<void> requestAppExit(BuildContext context, AudioService audio) async {
  audio.effect('tap');
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Exit app?'),
      content: const Text('Are you sure you want to exit?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  if (kIsWeb) {
    await audio.dispose();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const _ClosedAppScreen()),
      (_) => false,
    );
  } else {
    await SystemNavigator.pop();
  }
}

/// The fifth main menu button. Uses the same dimensions as MenuImageButton.
class ExitButton extends StatelessWidget {
  const ExitButton({super.key, required this.audio});

  final AudioService audio;

  @override
  Widget build(BuildContext context) => MenuImageButton(
        title: 'Exit',
        icon: Icons.power_settings_new_rounded,
        onTap: () => requestAppExit(context, audio),
      );
}

class _ClosedAppScreen extends StatelessWidget {
  const _ClosedAppScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('App closed. You may close this tab.')),
      );
}
