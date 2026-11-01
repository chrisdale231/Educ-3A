import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../widgets/fluid_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool get tagalog => widget.state.languageCode == 'tl';
  String label(String english, String filipino) => tagalog ? filipino : english;

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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label('Settings', 'Mga Setting'))),
        body: FluidBackdrop(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  PageTitle(label('Your preferences', 'Iyong mga kagustuhan')),
                  FluidCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                            Icons.language, label('Language', 'Wika')),
                        const SizedBox(height: 6),
                        Text(label('Choose the language for the entire app.',
                            'Piliin ang wika para sa buong app.')),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: _languageButton('English', 'en')),
                          const SizedBox(width: 10),
                          Expanded(child: _languageButton('Tagalog', 'tl')),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FluidCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.palette_outlined,
                            label('Appearance', 'Hitsura')),
                        const SizedBox(height: 6),
                        Text(label('Choose how the app looks.',
                            'Piliin ang hitsura ng app.')),
                        const SizedBox(height: 14),
                        _themeSwitch(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FluidCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(
                            Icons.volume_up_outlined, label('Audio', 'Tunog')),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(label(
                              'Background music', 'Musika sa background')),
                          secondary: const Icon(Icons.music_note),
                          value: widget.state.musicOn,
                          onChanged: widget.state.setMusic,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title:
                              Text(label('Sound effects', 'Mga sound effect')),
                          secondary: const Icon(Icons.volume_up),
                          value: widget.state.soundOn,
                          onChanged: widget.state.setSound,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _sectionTitle(IconData icon, String title) => Row(children: [
        Icon(icon, color: sea),
        const SizedBox(width: 9),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
      ]);

  Widget _languageButton(String title, String code) {
    final selected = widget.state.languageCode == code;
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: () => widget.state.setLanguage(code),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? colors.primaryContainer : colors.surface,
        side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      ),
      icon: Icon(selected ? Icons.check_circle : Icons.language, size: 20),
      label: Text(title),
    );
  }

  Widget _themeSwitch() {
    final light = widget.state.lightMode;
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(light ? Icons.light_mode : Icons.dark_mode,
          color: colors.primary, size: 28),
      const SizedBox(width: 12),
      Expanded(
          child: Text(
        light
            ? label('Light mode', 'Light mode')
            : label('Dark mode', 'Dark mode'),
        style: const TextStyle(fontWeight: FontWeight.w600),
      )),
      Semantics(
        label: label('Light mode', 'Light mode'),
        value: light ? label('On', 'Naka-on') : label('Off', 'Naka-off'),
        toggled: light,
        button: true,
        child: InkWell(
          onTap: () => widget.state.setLightMode(!light),
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 76,
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: light ? colors.primary : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: light ? Alignment.centerRight : Alignment.centerLeft,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: colors.surface,
                child: Icon(
                    light ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: light ? colors.primary : colors.onSurface,
                    size: 20),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
