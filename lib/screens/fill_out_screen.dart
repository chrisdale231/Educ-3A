import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_state.dart';
import '../services/audio_service.dart';
import '../services/learner_setup.dart';
import '../widgets/setup_frame.dart';
import 'photos_screen.dart';

class FillOutScreen extends StatefulWidget {
  const FillOutScreen({super.key, required this.state, required this.audio});

  final AppState state;
  final AudioService audio;

  @override
  State<FillOutScreen> createState() => _FillOutScreenState();
}

class _FillOutScreenState extends State<FillOutScreen> {
  late final LearnerSetup draft;
  late final TextEditingController name;
  late final TextEditingController age;
  late final TextEditingController grade;
  late final TextEditingController section;
  final formKey = GlobalKey<FormState>();
  bool nextAnimating = false;

  bool get isLight => widget.state.lightMode;
  Color get foreground => isLight ? const Color(0xFF082A68) : Colors.white;
  Color get hintColor =>
      isLight ? const Color(0xFF7483A5) : const Color(0xFF91A7D0);
  Color get fieldColor =>
      isLight ? Colors.white.withValues(alpha: 0.88) : const Color(0xB312315A);
  Color get borderColor =>
      isLight ? const Color(0xFF2587DD) : const Color(0xFF41DEFF);

  @override
  void initState() {
    super.initState();
    draft = LearnerSetup(widget.state);
    name = TextEditingController(text: draft.name);
    age = TextEditingController(text: draft.age);
    grade = TextEditingController(text: draft.grade);
    section = TextEditingController(text: draft.section);
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    grade.dispose();
    section.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (nextAnimating) return;
    widget.audio.effect('tap');
    setState(() => nextAnimating = true);
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    if (!formKey.currentState!.validate()) {
      setState(() => nextAnimating = false);
      return;
    }
    draft.name = name.text.trim();
    draft.age = age.text.trim();
    draft.grade = grade.text.trim();
    draft.section = section.text.trim();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PhotosScreen(
          state: widget.state,
          audio: widget.audio,
          draft: draft,
        ),
      ),
    );
    if (mounted) setState(() => nextAnimating = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              isLight
                  ? 'assets/images/sessions_light_background.png'
                  : 'assets/images/dark_mode_background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewport) {
                  const double panelAspectWidth = 977;
                  const double panelAspectHeight = 1610;
                  final double scale = math.min(
                    viewport.maxWidth * 0.94 / panelAspectWidth,
                    viewport.maxHeight * 0.96 / panelAspectHeight,
                  );
                  final double panelWidth = panelAspectWidth * scale;
                  final double panelHeight = panelAspectHeight * scale;

                  return Center(
                    child: SizedBox(
                      width: panelWidth,
                      height: panelHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(42),
                          image: DecorationImage(
                            image: AssetImage(
                              isLight
                                  ? 'assets/images/fill_out_panel_light.png'
                                  : 'assets/images/fill_out_panel_dark.png',
                            ),
                            fit: BoxFit.fill,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints bounds) =>
                                  Padding(
                            padding: EdgeInsets.fromLTRB(
                              panelWidth * 0.085,
                              panelHeight * 0.05,
                              panelWidth * 0.085,
                              panelHeight * 0.05,
                            ),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 500,
                                height: 940,
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/images/fill_out_profile_icon.png',
                                        width: 100,
                                        height: 86,
                                        fit: BoxFit.contain,
                                        excludeFromSemantics: true,
                                      ),
                                      Text(
                                        'Welcome',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 38,
                                          height: 1,
                                          fontWeight: FontWeight.w900,
                                          shadows: isLight
                                              ? null
                                              : const <Shadow>[
                                                  Shadow(
                                                      color: Color(0xAA006EFF),
                                                      blurRadius: 9),
                                                ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Let's get to know you.",
                                        style: TextStyle(
                                          color: isLight
                                              ? const Color(0xFF294777)
                                              : const Color(0xFFD7E6FF),
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      _StepIndicator(
                                          foreground: foreground,
                                          isLight: isLight),
                                      const SizedBox(height: 24),
                                      _field('Name',
                                          'assets/images/Name_male.png', name),
                                      const SizedBox(height: 14),
                                      _genderSection(),
                                      const SizedBox(height: 14),
                                      _field(
                                        'Age',
                                        'assets/images/Age.png',
                                        age,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (String? value) {
                                          final int? number =
                                              int.tryParse(value ?? '');
                                          return number == null ||
                                                  number < 1 ||
                                                  number > 120
                                              ? 'Enter a valid age'
                                              : null;
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      _field(
                                        'Grade',
                                        'assets/images/Grade.png',
                                        grade,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      _field('Section',
                                          'assets/images/Section.png', section),
                                      const SizedBox(height: 30),
                                      _NextButton(
                                        animating: nextAnimating,
                                        onTap: nextAnimating ? null : next,
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
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _field(
    String label,
    String icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                  color: foreground, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          TextFormField(
            key: ValueKey<String>('learner-${label.toLowerCase()}'),
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: keyboardType == null
                ? TextCapitalization.words
                : TextCapitalization.none,
            validator: validator ??
                (String? value) => value == null || value.trim().isEmpty
                    ? 'Enter $label'
                    : null,
            style: TextStyle(color: foreground, fontSize: 18),
            cursorColor: borderColor,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(9),
                child: Image.asset(icon, width: 30, height: 30),
              ),
              filled: true,
              fillColor: fieldColor,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: _fieldBorder(borderColor),
              enabledBorder: _fieldBorder(borderColor),
              focusedBorder: _fieldBorder(const Color(0xFF08DEFF), width: 2.5),
              errorBorder: _fieldBorder(const Color(0xFFFF5B6E)),
              focusedErrorBorder:
                  _fieldBorder(const Color(0xFFFF5B6E), width: 2.5),
              errorStyle: TextStyle(
                color:
                    isLight ? const Color(0xFFC62828) : const Color(0xFFFFA8B2),
              ),
            ),
          ),
        ],
      );

  OutlineInputBorder _fieldBorder(Color color, {double width = 1.8}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _genderSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text(
              'Gender',
              style: TextStyle(
                  color: foreground, fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: _gender('male', 'assets/images/Male.png', 'Male')),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _gender('female', 'assets/images/Female.png', 'Female')),
            ],
          ),
        ],
      );

  Widget _gender(String value, String icon, String label) {
    final bool selected = draft.gender == value;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: () => setState(() {
          if (draft.gender != value) draft.photo = null;
          draft.gender = value;
        }),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? (isLight ? const Color(0xFFDDF5FF) : const Color(0xCC063A83))
                : fieldColor,
            border: Border.all(
              color: selected ? const Color(0xFF19DEFF) : borderColor,
              width: selected ? 2.4 : 1.8,
            ),
            boxShadow: selected && !isLight
                ? const <BoxShadow>[
                    BoxShadow(color: Color(0x8800CFFF), blurRadius: 12),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(icon, width: 34, height: 34),
              const SizedBox(width: 10),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    style: TextStyle(color: foreground, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.foreground, required this.isLight});

  final Color foreground;
  final bool isLight;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Text('Step 1 of 2',
              style: TextStyle(color: foreground, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircleAvatar(radius: 7, backgroundColor: Color(0xFF087CF4)),
              Container(
                width: 34,
                height: 3,
                color:
                    isLight ? const Color(0xFFB7C6DC) : const Color(0xFF365B8D),
              ),
              CircleAvatar(
                radius: 7,
                backgroundColor:
                    isLight ? const Color(0xFFB7C6DC) : const Color(0xFF365B8D),
              ),
            ],
          ),
        ],
      );
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.animating, required this.onTap});

  final bool animating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onTap != null,
        label: 'Next: profile picture',
        excludeSemantics: true,
        child: SetupTapAnimation(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: AnimatedScale(
            scale: animating ? 1.04 : 1,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: 330,
              height: 110,
              child: Image.asset(
                'assets/images/Next_button.png',
                width: 330,
                height: 110,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      );
}
