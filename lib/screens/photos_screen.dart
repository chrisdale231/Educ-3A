import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../services/learner_setup.dart';
import '../widgets/setup_frame.dart';
import 'sessions.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen(
      {super.key,
      required this.state,
      required this.audio,
      required this.draft});

  final AppState state;
  final AudioService audio;
  final LearnerSetup draft;

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const _maleAvatars = [
    'assets/images/Cheerful Filipino Lab Student Avatar-1 (1).png',
    'assets/images/Confident Filipino Student Avatar-5 (1).png',
    'assets/images/Filipino Grade 11 Student Avatar-2 (1).png',
    'assets/images/Glossy Filipino Student Avatar-3 (1).png',
    'assets/images/Smiling Filipino Student in Blue Jersey-4 (1).png',
  ];
  static const _femaleAvatars = [
    'assets/images/Braided Scholar in Blue-9 (1).png',
    'assets/images/Cheerful Filipino student in teal lab jacket-8 (1).png',
    'assets/images/Confident Filipino Student Avatar-10 (1).png',
    'assets/images/Smiling Filipino Grade 11 Avatar-7 (1).png',
    'assets/images/Smiling Filipino student in blue jersey-6 (1).png',
  ];

  final picker = ImagePicker();
  bool picking = false;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
  }

  Future<void> _recoverLostImage() async {
    try {
      final response = await picker.retrieveLostData();
      final file = response.files?.firstOrNull;
      if (file != null) await _usePhoto(await file.readAsBytes());
    } catch (_) {
      // A missing camera or canceled picker leaves the default avatar visible.
    }
  }

  Future<void> _usePhoto(Uint8List bytes) async {
    if (!mounted) return;
    setState(() => widget.draft.photo = bytes);
  }

  Future<void> _openCharacterChooser() async {
    if (picking) return;
    widget.audio.effect('tap');
    final avatars =
        widget.draft.gender == 'female' ? _femaleAvatars : _maleAvatars;
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => _CharacterChooserScreen(
          gender: widget.draft.gender,
          avatars: avatars,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    final data = await rootBundle.load(selected);
    await _usePhoto(data.buffer.asUint8List());
  }

  Future<void> _pick(ImageSource source) async {
    if (picking) return;
    setState(() => picking = true);
    try {
      final file = await picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.front,
          maxWidth: 800,
          imageQuality: 75,
          requestFullMetadata: false);
      if (file != null) await _usePhoto(await file.readAsBytes());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(source == ImageSource.camera
                ? 'Camera is unavailable on this device.'
                : 'Could not open the gallery.')));
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> finishSetup() async {
    if (finishing || picking) return;
    widget.audio.effect('tap');
    setState(() => finishing = true);
    try {
      await widget.state.saveLearnerSetup(
        name: widget.draft.name,
        age: int.parse(widget.draft.age),
        grade: widget.draft.grade,
        section: widget.draft.section,
        gender: widget.draft.gender,
        language: widget.state.languageCode,
        photo: widget.draft.photo,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => SessionsScreen(
            state: widget.state,
            audio: widget.audio,
          ),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Please try again.'),
        ),
      );
    }
  }

  Future<void> backToDetails() async {
    if (picking) return;
    widget.audio.effect('tap');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dark = !widget.state.lightMode;
    final panelAsset = dark
        ? 'assets/images/photo_profile_panel_dark.png'
        : 'assets/images/photo_profile_panel_light.png';
    final backgroundAsset = dark
        ? 'assets/images/dark_mode_background.png'
        : 'assets/images/light_mode_background.png';
    final foreground = dark ? Colors.white : setupNavy;
    final secondary = dark ? const Color(0xFFBFE9FF) : setupNavy;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF03163D) : const Color(0xFFEAF6FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(backgroundAsset, fit: BoxFit.cover),
          SafeArea(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 978,
                  height: 1609,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          panelAsset,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        left: 56,
                        top: 55,
                        width: 118,
                        height: 118,
                        child: Semantics(
                          button: true,
                          enabled: !picking,
                          label: 'Back to learner details',
                          child: SetupTapAnimation(
                            onTap: picking ? null : backToDetails,
                            customBorder: const CircleBorder(),
                            child: Image.asset(
                              dark
                                  ? 'assets/images/button_back.png'
                                  : 'assets/images/light_button.png',
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 90,
                        right: 90,
                        top: 86,
                        child: IgnorePointer(
                          child: Text(
                            'Add Profile Picture',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 58,
                              fontWeight: FontWeight.w900,
                              shadows: dark
                                  ? const [
                                      Shadow(
                                        color: Color(0xAA008CFF),
                                        blurRadius: 14,
                                      ),
                                    ]
                                  : const [
                                      Shadow(
                                        color: Color(0x33001D43),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 90,
                        right: 90,
                        top: 163,
                        child: IgnorePointer(
                          child: Text(
                            '(Optional)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 31,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 408,
                        top: 675,
                        width: 162,
                        height: 70,
                        child: _PhotoSetupStepIndicator(dark: dark),
                      ),
                      Positioned(
                        left: 309,
                        top: 283,
                        width: 360,
                        height: 360,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Positioned.fill(
                              child: ClipOval(
                                child: ColoredBox(
                                  color: const Color(0xFFE1F7FF),
                                  child: widget.draft.photo == null
                                      ? Image.asset(
                                          widget.draft.gender == 'female'
                                              ? 'assets/images/avatar_girl.png'
                                              : 'assets/images/avatar_boy.png',
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        )
                                      : Image.memory(
                                          widget.draft.photo!,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Semantics(
                              button: true,
                              enabled: !picking,
                              label: 'Choose character',
                              child: SetupTapAnimation(
                                customBorder: const CircleBorder(),
                                onTap: picking ? null : _openCharacterChooser,
                                child: Image.asset(
                                  'assets/images/Glossy blue plus avatar badge.png',
                                  width: 105,
                                  height: 105,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 164,
                        top: 755,
                        width: 650,
                        height: 217,
                        child: SetupImageButton(
                          asset: 'assets/images/Gallery_button.png',
                          label: 'Choose from Gallery',
                          width: 650,
                          height: 217,
                          onTap:
                              picking ? null : () => _pick(ImageSource.gallery),
                        ),
                      ),
                      Positioned(
                        left: 164,
                        top: 939,
                        width: 650,
                        height: 217,
                        child: SetupImageButton(
                          asset: 'assets/images/Photo_button.png',
                          label: 'Take a Photo',
                          width: 650,
                          height: 217,
                          onTap:
                              picking ? null : () => _pick(ImageSource.camera),
                        ),
                      ),
                      Positioned(
                        left: 209,
                        top: 1283,
                        width: 560,
                        height: 187,
                        child: SetupImageButton(
                          asset: widget.draft.photo != null
                              ? 'assets/images/Next_button.png'
                              : 'assets/images/Skip_button.png',
                          label: widget.draft.photo != null
                              ? 'Finish setup'
                              : 'Skip photo for now',
                          width: 560,
                          height: 187,
                          onTap: finishing ? null : finishSetup,
                        ),
                      ),
                      if (picking || finishing)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Color(0x33000000),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1DE8FF),
                                strokeWidth: 7,
                              ),
                            ),
                          ),
                        ),
                    ],
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

class _PhotoSetupStepIndicator extends StatelessWidget {
  const _PhotoSetupStepIndicator({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Step 2 of 2',
        child: ExcludeSemantics(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Text(
                  'Step 2 of 2',
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF173D77),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Positioned(
                left: 50,
                top: 45,
                child: Container(
                  width: 62,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5D2E4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Positioned(
                left: 39,
                top: 36,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Color(0xFFB9C7DB),
                ),
              ),
              const Positioned(
                right: 39,
                top: 36,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: Color(0xFF1687F8),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CharacterChooserScreen extends StatefulWidget {
  const _CharacterChooserScreen({
    required this.gender,
    required this.avatars,
  });

  final String gender;
  final List<String> avatars;

  @override
  State<_CharacterChooserScreen> createState() =>
      _CharacterChooserScreenState();
}

class _CharacterChooserScreenState extends State<_CharacterChooserScreen> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.avatars.first;
  }

  @override
  Widget build(BuildContext context) {
    final genderLabel = widget.gender == 'female' ? 'Female' : 'Male';
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/dark_mode_background.png',
              fit: BoxFit.cover),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  margin: const EdgeInsets.all(22),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: const [
                      BoxShadow(color: Color(0x99001638), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SetupTapAnimation(
                            onTap: () => Navigator.pop(context),
                            customBorder: const CircleBorder(),
                            child: Image.asset(
                              'assets/images/button_back.png',
                              width: 58,
                              height: 58,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Choose Your Character',
                                maxLines: 1,
                                style: TextStyle(
                                  color: setupNavy,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Select your avatar',
                        style: TextStyle(color: setupNavy, fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 190,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF08D7F5), Color(0xFF0750F4)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                              color: const Color(0xFF51F2FF), width: 2),
                        ),
                        child: Text(
                          genderLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          itemCount: widget.avatars.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (_, index) {
                            final avatar = widget.avatars[index];
                            final isSelected = avatar == selected;
                            return Semantics(
                              button: true,
                              selected: isSelected,
                              label: '$genderLabel avatar ${index + 1}',
                              child: SetupTapAnimation(
                                onTap: () => setState(() => selected = avatar),
                                customBorder: const CircleBorder(),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFE1F7FF),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF08CFF2)
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                        boxShadow: isSelected
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x6600D7FF),
                                                  blurRadius: 12,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ClipOval(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Image.asset(
                                            avatar,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        right: 3,
                                        bottom: 3,
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Color(0xFF087CF4),
                                          child: Icon(Icons.check_rounded,
                                              color: Colors.white, size: 31),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ChooserButton(
                              label: 'Cancel',
                              primary: false,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _ChooserButton(
                              label: 'Select',
                              primary: true,
                              onTap: () => Navigator.pop(context, selected),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ChooserButton extends StatelessWidget {
  const _ChooserButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SetupTapAnimation(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34),
        child: Container(
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    colors: [Color(0xFF0BD9F5), Color(0xFF0751F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Colors.white, Color(0xFFDDF8FF)],
                  ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFF05CDEB), width: 3),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : const Color(0xFF1237D2),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}
