import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import 'progress.dart';

const _profileLightAsset = 'assets/images/profile_light.png';
const _profileDarkAsset = 'assets/images/profile_dark.png';
const _backButtonLightAsset = 'assets/images/light_button.png';
const _backButtonDarkAsset = 'assets/images/button_back.png';
const _cancelLightAsset = 'assets/images/profile_cancel_light.png';
const _cancelDarkAsset = 'assets/images/profile_cancel_dark.png';
const _saveLightAsset = 'assets/images/profile_save_light.png';
const _saveDarkAsset = 'assets/images/profile_save_dark.png';
const _progressIconLightAsset = 'assets/images/profile_progress_icon_light.png';
const _progressIconDarkAsset = 'assets/images/profile_progress_icon_dark.png';
const _progressButtonLightAsset =
    'assets/images/profile_progress_button_light.png';
const _progressButtonDarkAsset =
    'assets/images/profile_progress_button_dark.png';
const _completedSessionsLightAsset =
    'assets/images/profile_completed_sessions_light.png';
const _completedSessionsDarkAsset =
    'assets/images/profile_completed_sessions_dark.png';
const _earnedStarsLightAsset = 'assets/images/profile_earned_stars_light.png';
const _earnedStarsDarkAsset = 'assets/images/profile_earned_stars_dark.png';
const _cyan = Color(0xFF23D4F2);
const _purple = Color(0xFF8B43FF);
const _navy = Color(0xFF071747);

Future<bool?> showLearnerProfileDialog({
  required BuildContext context,
  required AppState state,
  required AudioService audio,
}) {
  audio.effect('tap');

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      final media = MediaQuery.of(dialogContext);
      final double safeScreenHeight =
          (media.size.height - media.padding.vertical - 12)
              .clamp(0.0, media.size.height)
              .toDouble();
      final double widthFromHeight = safeScreenHeight * 941 / 1672;
      final double dialogWidth = math.min(
        (media.size.width - 12).clamp(0.0, media.size.width).toDouble(),
        math.min(widthFromHeight, 600),
      );
      final double availableHeight =
          (safeScreenHeight - media.viewInsets.bottom)
              .clamp(0.0, media.size.height)
              .toDouble();
      final double naturalHeight = dialogWidth * 1672 / 941;
      final double dialogHeight = math.min(naturalHeight, availableHeight);

      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: dialogWidth,
                    height: naturalHeight,
                    child: LearnerProfileScreen(state: state, audio: audio),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The profile icon shown on HomeScreen.
class LearnerProfileButton extends StatefulWidget {
  const LearnerProfileButton({
    super.key,
    required this.state,
    required this.audio,
  });

  final AppState state;
  final AudioService audio;

  @override
  State<LearnerProfileButton> createState() => _LearnerProfileButtonState();
}

class _LearnerProfileButtonState extends State<LearnerProfileButton> {
  Future<void> _openProfile() async {
    final changed = await showLearnerProfileDialog(
      context: context,
      state: widget.state,
      audio: widget.audio,
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: dark
          ? const Color(0xCC102A55)
          : Theme.of(context).colorScheme.surface.withValues(alpha: .92),
      shape: const CircleBorder(),
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _cyan, width: 2),
        ),
        child: IconButton(
          tooltip: widget.state.hasLearnerProfile
              ? 'Profile: ${widget.state.learnerName}'
              : 'Create learner profile',
          onPressed: _openProfile,
          icon: ClipOval(
              child: widget.state.learnerPhotoBytes != null
                  ? Image.memory(widget.state.learnerPhotoBytes!,
                      width: 46, height: 46, fit: BoxFit.cover)
                  : Image.asset(
                      widget.state.learnerGender == 'female'
                          ? 'assets/images/avatar_girl.png'
                          : 'assets/images/avatar_boy.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover)),
          color: dark ? _cyan : const Color(0xFF067FA8),
          iconSize: 46,
        ),
      ),
    );
  }
}

/// Functional controls are placed over the blank areas in the two PNG assets.
class LearnerProfileScreen extends StatefulWidget {
  const LearnerProfileScreen({
    super.key,
    required this.state,
    required this.audio,
  });

  final AppState state;
  final AudioService audio;

  @override
  State<LearnerProfileScreen> createState() => _LearnerProfileScreenState();
}

class _LearnerProfileScreenState extends State<LearnerProfileScreen> {
  // The generated profile PNG assets are 941 x 1672 pixels.
  static const double _designWidth = 941;
  static const double _designHeight = 1672;

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _gradeController;
  late final TextEditingController _sectionController;
  late String _gender;
  late bool _editing;
  bool _saving = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _editing = !widget.state.hasLearnerProfile;
    _loadSavedValues();
  }

  void _loadSavedValues() {
    _nameController = TextEditingController(text: widget.state.learnerName);
    _ageController = TextEditingController(
      text: widget.state.learnerAge?.toString() ?? '',
    );
    _gradeController =
        TextEditingController(text: widget.state.learnerGradeLevel);
    _sectionController =
        TextEditingController(text: widget.state.learnerSection);
    _gender = widget.state.learnerGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _gradeController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  void _close() {
    widget.audio.effect('tap');
    Navigator.pop(context, _changed);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _editProfile() {
    widget.audio.effect('tap');
    _nameController.text = widget.state.learnerName;
    _ageController.text = widget.state.learnerAge?.toString() ?? '';
    _gradeController.text = widget.state.learnerGradeLevel;
    _sectionController.text = widget.state.learnerSection;
    _gender = widget.state.learnerGender;
    setState(() => _editing = true);
  }

  void _cancel() {
    widget.audio.effect('tap');

    if (!widget.state.hasLearnerProfile) {
      Navigator.pop(context, _changed);
      return;
    }

    _nameController.text = widget.state.learnerName;
    _ageController.text = widget.state.learnerAge?.toString() ?? '';
    _gradeController.text = widget.state.learnerGradeLevel;
    _sectionController.text = widget.state.learnerSection;
    _gender = widget.state.learnerGender;
    setState(() => _editing = false);
  }

  Future<void> _saveProfile() async {
    if (_saving) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final gradeLevel = _gradeController.text.trim();
    final section = _sectionController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }
    if (age == null) {
      _showMessage('Please enter your age.');
      return;
    }
    if (age < 5 || age > 100) {
      _showMessage('Enter an age from 5 to 100.');
      return;
    }
    if (gradeLevel.isEmpty) {
      _showMessage('Please enter your grade level.');
      return;
    }
    if (section.isEmpty) {
      _showMessage('Please enter your section.');
      return;
    }

    widget.audio.effect('tap');
    setState(() => _saving = true);

    try {
      await widget.state.setLearnerProfile(
        name,
        age,
        gradeLevel,
        section: section,
        gender: _gender,
      );
      if (!mounted) return;
      setState(() {
        _editing = false;
        _changed = true;
      });
      _showMessage('Profile saved on this device.');
    } on Object catch (error, stackTrace) {
      debugPrint('Saving learner profile failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _showMessage('Could not save the profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = !widget.state.lightMode;
    final backgroundAsset = dark ? _profileDarkAsset : _profileLightAsset;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF061A3B) : const Color(0xFFF3F8FF),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _designWidth,
            height: _designHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    backgroundAsset,
                    key: ValueKey('profile-background-$backgroundAsset'),
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => _MissingAsset(
                      dark: dark,
                      asset: backgroundAsset,
                    ),
                  ),
                ),

                // Use the supplied back button art for the active theme.
                Positioned(
                  left: 35,
                  top: 35,
                  width: 125,
                  height: 125,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Image.asset(
                            dark ? _backButtonDarkAsset : _backButtonLightAsset,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Image.asset(
                              _backButtonDarkAsset,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: _TransparentTap(onTap: _close),
                      ),
                    ],
                  ),
                ),

                // Avatar centered over the circle supplied by the new
                // profile background PNG.
                Positioned(
                  left: 306,
                  top: 250,
                  width: 328,
                  height: 328,
                  child: IgnorePointer(
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.state.learnerPhotoBytes != null)
                            Image.memory(
                              widget.state.learnerPhotoBytes!,
                              key: const ValueKey('learner-profile-photo'),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            )
                          else
                            Image.asset(
                              widget.state.learnerGender == 'female'
                                  ? 'assets/images/avatar_girl.png'
                                  : 'assets/images/avatar_boy.png',
                              key: const ValueKey('learner-profile-avatar'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              filterQuality: FilterQuality.high,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Cover the camera artwork baked into the background and put
                // a clear plus button in front of the profile photo.
                Positioned(
                  left: 525,
                  top: 492,
                  width: 132,
                  height: 132,
                  child: Semantics(
                    button: true,
                    label: 'Add profile photo',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.audio.effect('tap');
                        _showMessage(
                          'Profile photo selection can be added later.',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: dark
                                ? const [
                                    Color(0xFF7B2DFF),
                                    Color(0xFF00D9FF),
                                  ]
                                : const [
                                    Color(0xFF4D7CFF),
                                    Color(0xFF18CFFF),
                                  ],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 7,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x660084FF),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 82,
                          weight: 700,
                        ),
                      ),
                    ),
                  ),
                ),

                // Learning progress section supplied for both profile themes.
                Positioned(
                  left: 30,
                  top: 625,
                  width: 881,
                  height: 305,
                  child: _LearningProgressPanel(
                    dark: dark,
                    tagalog: widget.state.isTagalog,
                    onProgress: () {
                      widget.audio.effect('tap');
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProgressScreen(
                            state: widget.state,
                            audio: widget.audio,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Covers the three baked-in placeholder rows so the five
                // current profile fields have one clean background layer.
                Positioned(
                  left: 35,
                  top: 940,
                  width: 871,
                  height: 505,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(58),
                    child: ColoredBox(
                      color: dark
                          ? const Color(0xFF0A2148)
                          : const Color(0xFFF7FBFF),
                    ),
                  ),
                ),

                _ProfileFieldOverlay(
                  top: 952,
                  dark: dark,
                  label: widget.state.text('Name', 'Pangalan'),
                  iconAsset: 'assets/images/Name_male.png',
                  child: _editing
                      ? _ProfileTextField(
                          controller: _nameController,
                          dark: dark,
                          hint: widget.state
                              .text('Enter your name', 'Ilagay ang pangalan'),
                          fieldKey: const ValueKey('profile-name'),
                          capitalization: TextCapitalization.words,
                        )
                      : _ProfileValue(
                          value: widget.state.learnerName,
                          dark: dark,
                        ),
                ),
                _ProfileFieldOverlay(
                  top: 1048,
                  dark: dark,
                  label: widget.state.text('Gender', 'Kasarian'),
                  iconAsset: 'assets/images/profile_gender.png',
                  child: _editing
                      ? _ProfileGenderField(
                          dark: dark,
                          value: _gender,
                          onChanged: (value) {
                            setState(() => _gender = value);
                          },
                        )
                      : _ProfileValue(
                          value: _gender == 'female'
                              ? widget.state.text('Female', 'Babae')
                              : widget.state.text('Male', 'Lalaki'),
                          dark: dark,
                        ),
                ),
                _ProfileFieldOverlay(
                  top: 1144,
                  dark: dark,
                  label: widget.state.text('Age', 'Edad'),
                  iconAsset: 'assets/images/Age.png',
                  child: _editing
                      ? _ProfileTextField(
                          controller: _ageController,
                          dark: dark,
                          hint:
                              widget.state.text('Enter age', 'Ilagay ang edad'),
                          fieldKey: const ValueKey('profile-age'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        )
                      : _ProfileValue(
                          value: widget.state.learnerAge?.toString() ?? '',
                          dark: dark,
                        ),
                ),
                _ProfileFieldOverlay(
                  top: 1240,
                  dark: dark,
                  label: widget.state.text('Grade Level', 'Baitang'),
                  iconAsset: 'assets/images/Grade.png',
                  child: _editing
                      ? _ProfileTextField(
                          dark: dark,
                          controller: _gradeController,
                          hint: widget.state
                              .text('Enter grade level', 'Ilagay ang baitang'),
                          fieldKey: const ValueKey('profile-grade'),
                        )
                      : _ProfileValue(
                          value: widget.state.learnerGradeLevel,
                          dark: dark,
                        ),
                ),
                _ProfileFieldOverlay(
                  top: 1336,
                  dark: dark,
                  label: widget.state.text('Section', 'Seksyon'),
                  iconAsset: 'assets/images/Section.png',
                  child: _editing
                      ? _ProfileTextField(
                          dark: dark,
                          controller: _sectionController,
                          hint: widget.state
                              .text('Enter section', 'Ilagay ang seksyon'),
                          fieldKey: const ValueKey('profile-section'),
                          capitalization: TextCapitalization.words,
                        )
                      : _ProfileValue(
                          value: widget.state.learnerSection,
                          dark: dark,
                        ),
                ),

                // Buttons are Flutter widgets covering the button artwork.
                Positioned(
                  left: 50,
                  top: 1472,
                  width: 400,
                  height: 125,
                  child: _ProfileButton(
                    dark: dark,
                    text: _editing
                        ? widget.state.text('Cancel', 'Kanselahin')
                        : widget.state.text('Close', 'Isara'),
                    onTap: _saving
                        ? null
                        : _editing
                            ? _cancel
                            : _close,
                  ),
                ),
                Positioned(
                  left: 491,
                  top: 1472,
                  width: 400,
                  height: 125,
                  child: _ProfileButton(
                    dark: dark,
                    primary: true,
                    text: _editing
                        ? _saving
                            ? widget.state.text('Saving...', 'Sine-save...')
                            : 'OK'
                        : widget.state
                            .text('Edit Profile', 'I-edit ang Profile'),
                    icon: _editing
                        ? _saving
                            ? null
                            : Icons.check_rounded
                        : Icons.edit_rounded,
                    busy: _saving,
                    onTap: _saving
                        ? null
                        : _editing
                            ? _saveProfile
                            : _editProfile,
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

class _LearningProgressPanel extends StatelessWidget {
  const _LearningProgressPanel(
      {required this.dark, required this.tagalog, required this.onProgress});

  final bool dark;
  final bool tagalog;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : _navy;
    final secondary = dark ? const Color(0xFFB8D9FF) : const Color(0xFF3F679B);

    return Semantics(
      container: true,
      label:
          'My Learning Progress. 0 percent complete. 0 completed sessions. 0 earned stars.',
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: dark ? const Color(0xF20A2452) : const Color(0xF2F8FCFF),
                borderRadius: BorderRadius.circular(45),
                border: Border.all(
                  color: const Color(0xFF43CCFF),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: dark
                        ? const Color(0x9900BFFF)
                        : const Color(0x440078D4),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 21,
            width: 137,
            height: 137,
            child: Image.asset(
              dark ? _progressIconDarkAsset : _progressIconLightAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: 170,
            top: 28,
            child: Text(
              tagalog ? 'Progreso sa Pag-aaral' : 'My Learning Progress',
              style: TextStyle(
                color: foreground,
                fontSize: 35,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 170,
            top: 75,
            child: Text(
              tagalog
                  ? 'Magpatuloy! Mahusay ka!'
                  : "Keep going! You're doing great!",
              style: TextStyle(
                color: secondary,
                fontSize: 23,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 2,
            width: 340,
            height: 112,
            child: _PulsingProgressButton(
              dark: dark,
              onTap: onProgress,
            ),
          ),
          Positioned(
            left: 170,
            top: 119,
            width: 515,
            height: 38,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF092857) : const Color(0xFFD9E9F8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(color: Color(0x5500C8FF), blurRadius: 10),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFF1458FF),
                            Color(0xFFD62DFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 34,
            top: 111,
            width: 145,
            child: Text(
              '0%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: foreground,
                fontSize: 43,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 135,
            bottom: 18,
            width: 350,
            height: 112,
            child: _ProgressStatCard(
              dark: dark,
              imageAsset: dark
                  ? _completedSessionsDarkAsset
                  : _completedSessionsLightAsset,
              value: '0',
              label: 'Completed Sessions',
            ),
          ),
          Positioned(
            right: 28,
            bottom: 18,
            width: 350,
            height: 112,
            child: _ProgressStatCard(
              dark: dark,
              imageAsset: dark ? _earnedStarsDarkAsset : _earnedStarsLightAsset,
              value: '0',
              label: 'Earned Stars',
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingProgressButton extends StatefulWidget {
  const _PulsingProgressButton({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  State<_PulsingProgressButton> createState() => _PulsingProgressButtonState();
}

class _PulsingProgressButtonState extends State<_PulsingProgressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _animateAndOpen() async {
    if (_opening) return;
    _opening = true;
    await _controller.forward();
    await _controller.reverse();
    if (!mounted) return;
    widget.onTap();
    _opening = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Open progress',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _animateAndOpen,
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              widget.dark
                  ? _progressButtonDarkAsset
                  : _progressButtonLightAsset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
}

class _ProgressStatCard extends StatelessWidget {
  const _ProgressStatCard({
    required this.dark,
    required this.imageAsset,
    required this.value,
    required this.label,
  });

  final bool dark;
  final String imageAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : _navy;
    return Semantics(
      label: '$value $label',
      image: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned(
            left: 200,
            top: 20,
            child: Text(
              value,
              style: TextStyle(
                color: foreground,
                fontSize: 36,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldOverlay extends StatelessWidget {
  const _ProfileFieldOverlay({
    required this.top,
    required this.dark,
    required this.label,
    required this.iconAsset,
    required this.child,
  });

  final double top;
  final bool dark;
  final String label;
  final String iconAsset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : _navy;
    return Positioned(
      left: 75,
      top: top,
      width: 790,
      height: 88,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? const Color(0x99132E5C) : const Color(0xAAFFFFFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: dark ? const Color(0xFF3B6CA6) : const Color(0xFFBCD1F4),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 9,
              width: 70,
              height: 70,
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              left: 100,
              top: 6,
              right: 14,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 34,
              right: 14,
              height: 48,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransparentTap extends StatelessWidget {
  const _TransparentTap({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.dark,
    required this.hint,
    this.fieldKey,
    this.keyboardType,
    this.inputFormatters,
    this.capitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final bool dark;
  final String hint;
  final Key? fieldKey;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: capitalization,
          maxLines: 1,
          style: TextStyle(
            color: dark ? Colors.white : _navy,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(
              color: dark ? Colors.white38 : const Color(0xFF91A0BD),
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileGenderField extends StatelessWidget {
  const _ProfileGenderField({
    required this.dark,
    required this.value,
    required this.onChanged,
  });

  final bool dark;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderChoice(
            label: 'Male',
            icon: Icons.male,
            selected: value == 'male',
            dark: dark,
            onTap: () => onChanged('male'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderChoice(
            label: 'Female',
            icon: Icons.female,
            selected: value == 'female',
            dark: dark,
            onTap: () => onChanged('female'),
          ),
        ),
      ],
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : _navy;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? (dark ? const Color(0x6639D9FF) : const Color(0xFFD8F5FF))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 29,
                color: label == 'Female' ? const Color(0xFFFF2C9C) : _cyan,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue({required this.value, required this.dark});

  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          value.isEmpty ? 'Not set' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dark ? Colors.white : _navy,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatefulWidget {
  const _ProfileButton({
    required this.dark,
    required this.text,
    required this.onTap,
    this.primary = false,
    this.icon,
    this.busy = false,
  });

  final bool dark;
  final String text;
  final VoidCallback? onTap;
  final bool primary;
  final IconData? icon;
  final bool busy;

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (widget.onTap == null || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (widget.onTap == null || _hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final imageAsset = widget.primary
        ? (widget.dark ? _saveDarkAsset : _saveLightAsset)
        : (widget.dark ? _cancelDarkAsset : _cancelLightAsset);
    final scale = _pressed ? .94 : (_hovered ? 1.025 : 1.0);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.text,
      child: MouseRegion(
        cursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: (_) => _setHovered(true),
        onExit: (_) {
          _setHovered(false);
          _setPressed(false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 120),
            curve: _pressed ? Curves.easeIn : Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: enabled ? 1 : .55,
              duration: const Duration(milliseconds: 160),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.primary
                            ? _purple
                            : widget.dark
                                ? const Color(0xFF111A45)
                                : const Color(0xFFF7F9FF),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(color: _cyan, width: 3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.busy)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 4,
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(
                            widget.icon,
                            size: 48,
                            color: widget.primary
                                ? Colors.white
                                : widget.dark
                                    ? Colors.white
                                    : _navy,
                          ),
                        if (widget.busy || widget.icon != null)
                          const SizedBox(width: 16),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.text,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: widget.primary
                                    ? Colors.white
                                    : widget.dark
                                        ? Colors.white
                                        : _navy,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingAsset extends StatelessWidget {
  const _MissingAsset({required this.dark, required this.asset});

  final bool dark;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark ? const Color(0xFF071C43) : const Color(0xFFF3F8FF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Text(
            'Missing image asset:\n$asset\n\n'
            'Add the profile background and button PNG files '
            'inside assets/images/.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? Colors.white : _navy,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
