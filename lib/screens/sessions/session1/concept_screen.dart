import 'package:flutter/material.dart';

import '../../../services/app_state.dart';

const root = 'assets/images/concept';
const navy = Color(0xFF071052);
const blue = Color(0xFF0878F9);
const cyan = Color(0xFF20D6F2);

class ConceptScreen extends StatefulWidget {
  const ConceptScreen({super.key, required this.state, this.sessionNumber = 1});
  final AppState state;
  final int sessionNumber;

  @override
  State<ConceptScreen> createState() => _ConceptScreenState();
}

class _ConceptScreenState extends State<ConceptScreen> {
  static const pages = <PageData>[
    PageData(
      'Fluid Properties',
      'What makes liquids and gases flow?',
      ['pouring_water.png', 'water_flask.png', 'pressure_sphere.png'],
      heroLabels: ['LIQUID', '', 'GAS'],
      heroNotes: [
        'Takes the shape of its container and flows.',
        '',
        'Expands to fill its container and flows.'
      ],
      firstLabel: 'KEY CONCEPT',
      firstText:
          'Characteristics of liquids and gases allow them to continuously deform under applied shear stress.',
      firstIcon: 'idea_icon.png',
      secondLabel: 'OBSERVE IN REAL LIFE',
      secondText: 'Water takes the shape of a glass. Air fills a balloon.',
      secondAssets: ['water_glass.png', 'purple_balloon.png'],
    ),
    PageData(
      'Mass (m)',
      'How much matter is in an object?',
      ['balance_scale.png'],
      formulaLabel: 'MEASURING MASS',
      formula: '1 kg = 1,000 g',
      formulaAssets: ['earth_moon_comparison.png'],
      firstLabel: 'DEFINITION',
      firstText:
          'Mass is the total amount of matter in an object, measured in kilograms (kg) or grams (g). It stays constant regardless of location.',
      firstIcon: 'cube_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText:
          'A 2 kg schoolbag has the same mass on Earth and on the Moon.',
      secondAssets: ['backpack.png'],
    ),
    PageData(
      'Volume (V)',
      'How much space does an object occupy?',
      ['volume_dimension_cube.png'],
      formulaLabel: 'FORMULA AND EXAMPLE',
      formula: 'V = length × width × height\n3 m × 3 m × 3 m = 27 m³',
      firstLabel: 'DEFINITION',
      firstText:
          'Volume is the total three-dimensional space occupied by a solid, liquid, or gas. It is measured in cubic metres, millilitres, or litres.',
      firstIcon: 'cube_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText: 'A box and a water bottle both have volume.',
      secondAssets: ['volume_box.png', 'volume_bottle.png'],
    ),
    PageData(
      'Density (ρ)',
      'How much mass fits in a given volume?',
      ['gas_particles.png', 'liquid_particles.png', 'solid_particles.png'],
      heroLabels: ['Gas', 'Liquid', 'Solid'],
      formulaLabel: 'FORMULA AND EXAMPLE',
      formula: 'ρ = mass ÷ volume\n6 g ÷ 3 cm³ = 2 g/cm³',
      firstLabel: 'DEFINITION',
      firstText:
          'Density is the concentration of mass per unit volume. It describes how compact a substance is.',
      firstIcon: 'cube_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText:
          'Wood often floats in water; a stone often sinks because their densities differ.',
      secondAssets: ['floating_and_sinking_tank.png'],
    ),
    PageData(
      'Buoyant Force (Fᵦ)',
      'Why does water push objects upward?',
      ['suspended_cube_beaker.png'],
      formulaLabel: 'ARCHIMEDES’ PRINCIPLE',
      formula: 'Buoyant force = weight of displaced fluid',
      firstLabel: 'DEFINITION',
      firstText:
          'Buoyant force is the net upward force on an object submerged or floating in a fluid.',
      firstIcon: 'cube_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText:
          'A boat floats when the upward buoyant force balances its weight.',
      secondAssets: ['floating_boat.png'],
    ),
    PageData(
      'Floating',
      'Why do some objects stay on the surface?',
      ['floating_objects_beaker.png'],
      firstLabel: 'KEY IDEA',
      firstText:
          'Floating is a state of equilibrium where an object stays at or above a fluid’s surface.',
      firstIcon: 'idea_icon.png',
      extraLabel: 'DENSITY CONNECTION',
      extraText:
          'An object with a lower average density than the fluid can float at the surface.',
      extraIcon: 'bubbles_icon.png',
      secondLabel: 'REAL LIFE EXAMPLE',
      secondText:
          'A sealed plastic bottle floats because its average density is lower than water.',
      secondAssets: ['floating_bottle.png'],
    ),
    PageData(
      'Sinking',
      'Why does an object move to the bottom?',
      ['sinking_rock_beaker.png'],
      firstLabel: 'KEY IDEA',
      firstText:
          'Sinking occurs when an object’s weight exceeds the maximum buoyant force acting upward.',
      firstIcon: 'idea_icon.png',
      extraLabel: 'DENSITY CONNECTION',
      extraText:
          'A solid object with a greater average density than the fluid tends to sink.',
      extraIcon: 'bubbles_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText:
          'A stone sinks in water because its density is greater than water’s.',
      secondAssets: ['rock_on_seabed.png'],
    ),
    PageData(
      'Suspension',
      'How can an object hover underwater?',
      [
        'floating_block_beaker.png',
        'suspended_block_beaker.png',
        'sinking_block_beaker.png'
      ],
      subtitle: '(Neutral Buoyancy)',
      heroLabels: [
        'Positive buoyancy',
        'Neutral buoyancy',
        'Negative buoyancy'
      ],
      firstLabel: 'KEY IDEA',
      firstText:
          'Neutral buoyancy is a balanced state where an object hovers at any depth without rising or sinking.',
      firstIcon: 'idea_icon.png',
      extraLabel: 'DENSITY CONNECTION',
      extraText: 'Its average density matches the fluid’s density.',
      extraIcon: 'cube_icon.png',
      secondLabel: 'REAL LIFE EXAMPLE',
      secondText:
          'A submarine can adjust its buoyancy to hover at a chosen depth.',
      secondAssets: ['submarine_scene.png'],
    ),
    PageData(
      'Fluid Displacement',
      'What happens when an object enters water?',
      ['displacement_before.png', 'displacement_after.png'],
      heroLabels: ['Before: 100 mL', 'After: 150 mL'],
      formulaLabel: 'DISPLACED WATER',
      formula: '150 mL − 100 mL = 50 mL',
      firstLabel: 'KEY IDEA',
      firstText:
          'Fluid displacement is the volume of fluid pushed aside when an object is placed into it.',
      firstIcon: 'cube_icon.png',
      extraLabel: 'BUOYANCY CONNECTION',
      extraText: 'The weight of displaced fluid determines buoyant force.',
      extraIcon: 'buoyancy_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText: 'A stone raises the water level in a measuring cylinder.',
      secondAssets: ['splashing_rock.png'],
    ),
    PageData(
      'Apparent Weight',
      'Why does an object seem lighter in water?',
      ['weight_in_air.png', 'weight_in_water.png'],
      heroLabels: ['In air: 10 N', 'In water: 7 N'],
      formulaLabel: 'FORMULA AND EXAMPLE',
      formula:
          'Apparent weight = actual weight − buoyant force\n10 N − 3 N = 7 N',
      firstLabel: 'KEY IDEA',
      firstText:
          'Apparent weight is the net downward force measured when an object is submerged in a fluid.',
      firstIcon: 'idea_icon.png',
      secondLabel: 'EVERYDAY EXAMPLE',
      secondText: 'A rock feels easier to hold underwater.',
      secondAssets: ['rock_bubbles.png'],
    ),
  ];

  late int index;
  late bool results;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final saved = widget.state.conceptStepForSession(widget.sessionNumber);
    results = saved >= pages.length;
    index = saved.clamp(0, pages.length - 1);
  }

  Future<void> next() async {
    if (saving) return;
    setState(() => saving = true);
    final nextIndex = index + 1;
    await widget.state.saveConceptStep(widget.sessionNumber, nextIndex);
    if (!mounted) return;
    setState(() {
      saving = false;
      if (nextIndex == pages.length) {
        results = true;
      } else {
        index = nextIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [Color(0xFF010A26), Color(0xFF00366B)]
                    : const [Color(0xFFFBFEFF), Color(0xFFDDF7FF)],
              ),
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: asset('top_wave.png', fit: BoxFit.fitWidth)),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: asset('bottom_wave.png', fit: BoxFit.fitWidth)),
          SafeArea(
            child: results
                ? ResultsView(
                    dark: dark,
                    session: widget.sessionNumber,
                    onBack: () => Navigator.maybePop(context),
                    onReview: () => setState(() {
                      index = 0;
                      results = false;
                    }),
                  )
                : LessonView(
                    dark: dark,
                    session: widget.sessionNumber,
                    index: index,
                    page: pages[index],
                    saving: saving,
                    onBack: () => Navigator.maybePop(context),
                    onNext: next,
                  ),
          ),
        ],
      ),
    );
  }
}

class LessonView extends StatelessWidget {
  const LessonView({
    super.key,
    required this.dark,
    required this.session,
    required this.index,
    required this.page,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });
  final bool dark;
  final int session;
  final int index;
  final PageData page;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConceptHeader(
                  dark: dark,
                  session: session,
                  current: index + 1,
                  onBack: onBack),
              const SizedBox(height: 10),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ink,
                  fontSize: page.title.length > 18 ? 34 : 42,
                  height: 1.04,
                  fontWeight: FontWeight.w900,
                  shadows: dark
                      ? const [Shadow(color: Color(0xAA30DFFF), blurRadius: 12)]
                      : null,
                ),
              ),
              if (page.subtitle != null)
                Text(page.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: ink, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text(page.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ink, fontSize: 21, height: 1.15)),
              const SizedBox(height: 15),
              HeroPanel(dark: dark, page: page, tall: index == 0 || index >= 7),
              if (page.formula != null) ...[
                const SizedBox(height: 11),
                FormulaPanel(dark: dark, page: page),
              ],
              const SizedBox(height: 11),
              InfoPanel(
                  dark: dark,
                  label: page.firstLabel,
                  text: page.firstText,
                  icon: page.firstIcon),
              if (page.extraText != null) ...[
                const SizedBox(height: 11),
                InfoPanel(
                    dark: dark,
                    label: page.extraLabel!,
                    text: page.extraText!,
                    icon: page.extraIcon),
              ],
              const SizedBox(height: 11),
              InfoPanel(
                  dark: dark,
                  label: page.secondLabel,
                  text: page.secondText,
                  assets: page.secondAssets),
              const SizedBox(height: 13),
              NextButton(
                dark: dark,
                saving: saving,
                subtitle: index == 9
                    ? 'View session results'
                    : 'Up next: ${_ConceptScreenState.pages[index + 1].title}',
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConceptHeader extends StatelessWidget {
  const ConceptHeader(
      {super.key,
      required this.dark,
      required this.session,
      required this.current,
      required this.onBack});
  final bool dark;
  final int session;
  final int current;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return SizedBox(
      height: 92,
      child: Stack(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                  onPressed: onBack,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_rounded, size: 38),
                  color: ink)),
          Align(
              alignment: Alignment.topCenter,
              child: Text('BEGIN',
                  style: TextStyle(
                      color: ink, fontSize: 27, fontWeight: FontWeight.w900))),
          Align(
              alignment: Alignment.topRight,
              child: Semantics(
                  label: 'Concept $current of 10',
                  child: Text('$current / 10',
                      style: TextStyle(
                          color: ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: dark ? const Color(0xD0032C5E) : const Color(0xD7D8F5FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cyan),
              ),
              child: Text('SESSION $session',
                  style: TextStyle(
                      color: ink, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  const HeroPanel(
      {super.key, required this.dark, required this.page, required this.tall});
  final bool dark;
  final PageData page;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    if (page.title == 'Fluid Properties') {
      return FluidPropertiesHero(dark: dark);
    }
    final ink = dark ? Colors.white : navy;
    return Panel(
      dark: dark,
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: tall ? 315 : 275,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < page.heroAssets.length; i++) ...[
              if (i > 0)
                Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    color: cyan.withValues(alpha: .55)),
              Expanded(
                child: Column(
                  children: [
                    if (i < page.heroLabels.length &&
                        page.heroLabels[i].isNotEmpty)
                      Text(page.heroLabels[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ink,
                              fontSize:
                                  page.heroLabels[i].length > 16 ? 12 : 17,
                              fontWeight: FontWeight.w900)),
                    Expanded(
                        child: asset(page.heroAssets[i],
                            fit: BoxFit.contain,
                            semanticLabel: '${page.title} illustration')),
                    if (i < page.heroNotes.length &&
                        page.heroNotes[i].isNotEmpty)
                      Text(page.heroNotes[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ink, fontSize: 12, height: 1.15)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FluidPropertiesHero extends StatelessWidget {
  const FluidPropertiesHero({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Panel(
      dark: dark,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SizedBox(
        height: 304,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _FluidTypeColumn(
                dark: dark,
                title: 'LIQUID',
                icon: 'drop_icon.png',
                note: 'Takes the shape of its container\nand flows.',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: asset(
                        'pouring_water.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'Water pouring into a glass',
                      ),
                    ),
                    Expanded(
                      child: asset(
                        'water_flask.png',
                        fit: BoxFit.contain,
                        semanticLabel: 'Water taking the shape of a flask',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1.4,
              margin: const EdgeInsets.symmetric(vertical: 7),
              color: cyan.withValues(alpha: dark ? .82 : .58),
            ),
            Expanded(
              child: _FluidTypeColumn(
                dark: dark,
                title: 'GAS',
                icon: 'flow_icon.png',
                note: 'Expands to fill its container\nand flows.',
                child: asset(
                  'pressure_sphere.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'Gas expanding inside a balloon',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FluidTypeColumn extends StatelessWidget {
  const _FluidTypeColumn({
    required this.dark,
    required this.title,
    required this.icon,
    required this.note,
    required this.child,
  });

  final bool dark;
  final String title;
  final String icon;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: dark ? const Color(0xB504477B) : const Color(0xFFD1F2FF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cyan, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 43,
                  child: Center(
                    child: title == 'LIQUID'
                        ? asset(
                            icon,
                            width: 43,
                            height: 43,
                            fit: BoxFit.contain,
                          )
                        : Container(
                            width: 43,
                            height: 43,
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF06DDF1),
                                  Color(0xFF075EF6),
                                ],
                              ),
                            ),
                            child: asset(icon, fit: BoxFit.contain),
                          ),
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      color: ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            note,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ink,
              fontSize: 13,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class FormulaPanel extends StatelessWidget {
  const FormulaPanel({super.key, required this.dark, required this.page});
  final bool dark;
  final PageData page;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return Panel(
      dark: dark,
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabelPill(text: page.formulaLabel!, dark: dark),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              Text(page.formula!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ink,
                      fontSize: page.formula!.length > 55 ? 19 : 24,
                      height: 1.35,
                      fontWeight: FontWeight.w800)),
              for (final name in page.formulaAssets)
                SizedBox(
                    width: 190,
                    height: 92,
                    child: asset(name, fit: BoxFit.contain)),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel(
      {super.key,
      required this.dark,
      required this.label,
      required this.text,
      this.icon,
      this.assets = const []});
  final bool dark;
  final String label;
  final String text;
  final String? icon;
  final List<String> assets;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    if (label == 'OBSERVE IN REAL LIFE' && assets.length == 2) {
      return _FluidExamplesPanel(dark: dark);
    }
    return Panel(
      dark: dark,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelPill(text: label, dark: dark),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, box) => Row(
              children: [
                if (icon != null) ...[
                  SizedBox(
                      width: 64,
                      height: 64,
                      child: asset(icon!, fit: BoxFit.contain)),
                  const SizedBox(width: 11),
                ],
                Expanded(
                    child: Text(text,
                        style:
                            TextStyle(color: ink, fontSize: 17, height: 1.28))),
                if (assets.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: (box.maxWidth * .34).clamp(92.0, 190.0),
                    height: 92,
                    child: Row(children: [
                      for (final name in assets)
                        Expanded(child: asset(name, fit: BoxFit.contain))
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FluidExamplesPanel extends StatelessWidget {
  const _FluidExamplesPanel({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Panel(
      dark: dark,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelPill(text: 'OBSERVE IN REAL LIFE', dark: dark),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _FluidExample(
                  dark: dark,
                  assetName: 'water_glass.png',
                  text: 'Water takes\nthe shape of\na glass.',
                ),
              ),
              Container(
                width: 1.2,
                height: 102,
                color: cyan.withValues(alpha: .48),
              ),
              Expanded(
                child: _FluidExample(
                  dark: dark,
                  assetName: 'purple_balloon.png',
                  text: 'Air fills\na balloon.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FluidExample extends StatelessWidget {
  const _FluidExample({
    required this.dark,
    required this.assetName,
    required this.text,
  });

  final bool dark;
  final String assetName;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return SizedBox(
      height: 102,
      child: Row(
        children: [
          Expanded(
            child: asset(
              assetName,
              fit: BoxFit.contain,
              semanticLabel: text.replaceAll('\n', ' '),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ink,
                fontSize: 15,
                height: 1.18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel(
      {super.key,
      required this.dark,
      required this.child,
      required this.padding});
  final bool dark;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  dark ? '$root/wide_panel.png' : '$root/wide_info_card.png'),
              fit: BoxFit.fill),
          color: dark ? const Color(0xE0042148) : const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: dark ? cyan : Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: dark ? const Color(0x6620D6F2) : const Color(0x243382B5),
                blurRadius: 10)
          ],
        ),
        child: child,
      );
}

class LabelPill extends StatelessWidget {
  const LabelPill({super.key, required this.text, required this.dark});
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: dark ? const Color(0xD004477B) : const Color(0xFFD3F3FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cyan),
          ),
          child: Text(text,
              style: TextStyle(
                  color: dark ? Colors.white : navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ),
      );
}

class NextButton extends StatelessWidget {
  const NextButton(
      {super.key,
      required this.dark,
      required this.saving,
      required this.subtitle,
      required this.onPressed});
  final bool dark;
  final bool saving;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 60,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(dark
                          ? '$root/dark_button.png'
                          : '$root/blue_button.png'),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: InkWell(
                  onTap: saving ? null : onPressed,
                  borderRadius: BorderRadius.circular(32),
                  child: Center(
                    child: saving
                        ? const SizedBox.square(
                            dimension: 25,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : const Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('Next',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 32),
                          ]),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      dark ? const Color(0xFFC4EDFF) : const Color(0xFF376BA5),
                  fontWeight: FontWeight.w600)),
        ],
      );
}

class ResultsView extends StatelessWidget {
  const ResultsView(
      {super.key,
      required this.dark,
      required this.session,
      required this.onBack,
      required this.onReview});
  final bool dark;
  final int session;
  final VoidCallback onBack;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : navy;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              ConceptHeader(
                  dark: dark, session: session, current: 10, onBack: onBack),
              const SizedBox(height: 28),
              Panel(
                dark: dark,
                padding: const EdgeInsets.all(28),
                child: Column(children: [
                  asset('buoyancy_icon.png', width: 112, height: 112),
                  const SizedBox(height: 14),
                  Text('Session $session complete!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ink,
                          fontSize: 31,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  const Text('10 / 10 concepts viewed',
                      style: TextStyle(
                          color: blue,
                          fontSize: 21,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Done'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: blue)),
              TextButton.icon(
                  onPressed: onReview,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Review concepts'),
                  style: TextButton.styleFrom(foregroundColor: ink)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget asset(String name,
        {BoxFit? fit, double? width, double? height, String? semanticLabel}) =>
    Image.asset('$root/$name',
        fit: fit, width: width, height: height, semanticLabel: semanticLabel);

class PageData {
  const PageData(
    this.title,
    this.question,
    this.heroAssets, {
    this.subtitle,
    this.heroLabels = const [],
    this.heroNotes = const [],
    this.formulaLabel,
    this.formula,
    this.formulaAssets = const [],
    required this.firstLabel,
    required this.firstText,
    this.firstIcon,
    this.extraLabel,
    this.extraText,
    this.extraIcon,
    required this.secondLabel,
    required this.secondText,
    this.secondAssets = const [],
  });
  final String title;
  final String question;
  final List<String> heroAssets;
  final String? subtitle;
  final List<String> heroLabels;
  final List<String> heroNotes;
  final String? formulaLabel;
  final String? formula;
  final List<String> formulaAssets;
  final String firstLabel;
  final String firstText;
  final String? firstIcon;
  final String? extraLabel;
  final String? extraText;
  final String? extraIcon;
  final String secondLabel;
  final String secondText;
  final List<String> secondAssets;
}
