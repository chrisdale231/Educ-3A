import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/audio_service.dart';

const _navy = Color(0xFF07165F);
const _blue = Color(0xFF075EFF);
const _cyan = Color(0xFF18D9F2);

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key, required this.audio});
  final AudioService audio;

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  static const objects = [
    _Object('Rock', 'assets/images/simulation_object_rock.png', .11),
    _Object('Cube', 'assets/images/simulation_object_cube.png', .30),
    _Object('Cylinder', 'assets/images/simulation_object_cylinder.png', .20),
    _Object('Sphere', 'assets/images/simulation_object_sphere.png', .28),
  ];
  static const fluids = [
    _Fluid('Water', 'assets/images/simulation_fluid_water_card.png', 1000,
        Color(0xFF079BFF)),
    _Fluid('Oil', 'assets/images/simulation_fluid_oil_card.png', 850,
        Color(0xFFFFB000)),
    _Fluid('Honey', 'assets/images/simulation_fluid_honey_card.png', 1420,
        Color(0xFFE66B00)),
    _Fluid('Mercury', 'assets/images/simulation_fluid_mercury_card.png', 13546,
        Color(0xFF9EADC2)),
  ];

  late final AnimationController animation;
  late final TextEditingController massController;
  int objectIndex = 0;
  int fluidIndex = 0;
  double massKg = .25;
  double fluidLitres = .7;
  _Result? result;

  _Object get object => objects[objectIndex];
  _Fluid get fluid => fluids[fluidIndex];

  @override
  void initState() {
    super.initState();
    massController = TextEditingController(text: '0.250');
    animation = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    massController.dispose();
    animation.dispose();
    super.dispose();
  }

  void selectObject(int index) {
    widget.audio.effect('tap');
    animation.reset();
    setState(() {
      objectIndex = index;
      result = null;
    });
  }

  void selectFluid(int index) {
    widget.audio.effect('tap');
    animation.reset();
    setState(() {
      fluidIndex = index;
      result = null;
    });
  }

  void readMass() {
    final value = (double.tryParse(massController.text) ?? massKg)
        .clamp(.05, 5.0)
        .toDouble();
    massController.text = value.toStringAsFixed(3);
    animation.reset();
    setState(() {
      massKg = value;
      result = null;
    });
  }

  _Result calculate() {
    final volumeM3 = object.volumeL / 1000;
    final objectDensity = massKg / volumeM3;
    final canFloat = objectDensity <= fluid.density;
    final desiredFraction = canFloat ? objectDensity / fluid.density : 1.0;
    final wantedDisplacement = object.volumeL * desiredFraction;
    final displacement = math.min(wantedDisplacement, fluidLitres);
    final displacedMass = fluid.density * displacement / 1000;
    final floating = canFloat && displacement >= wantedDisplacement - 1e-9;
    final initialScale = fluid.density * fluidLitres / 1000;
    final scaleChange = floating ? massKg : displacedMass;
    return _Result(
      objectDensity: objectDensity,
      submergedFraction: (displacement / object.volumeL).clamp(0, 1),
      displacedL: displacement,
      displacedMassKg: displacedMass,
      apparentMassKg: math.max(0, massKg - displacedMass),
      initialScaleKg: initialScale,
      finalScaleKg: initialScale + scaleChange,
      scaleChangeKg: scaleChange,
      floating: floating,
      fluidLimited: displacement < wantedDisplacement - 1e-9,
    );
  }

  Future<void> tryIt() async {
    FocusScope.of(context).unfocus();
    readMass();
    widget.audio.effect('tap');
    final next = calculate();
    setState(() => result = next);
    await animation.forward(from: 0);
  }

  void reset() {
    widget.audio.effect('tap');
    animation.reset();
    massController.text = '0.250';
    setState(() {
      objectIndex = 0;
      fluidIndex = 0;
      massKg = .25;
      fluidLitres = .7;
      result = null;
    });
  }

  void showInfo() {
    widget.audio.effect('tap');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use the simulation'),
        content: const Text(
          'Choose or drag an object to the beaker, edit its mass, select a '
          'fluid, and adjust the fluid volume. Tap Try it to compare its mass '
          'in air with its apparent mass in the fluid. Mercury is virtual only.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final foreground = dark ? Colors.white : _navy;
    final background = dark
        ? 'assets/images/simulation_background_dark.png'
        : 'assets/images/simulation_background_light.png';
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset(background, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: dark
                  ? const [Color(0x18000000), Color(0x52000B2B)]
                  : const [Color(0x22FFFFFF), Color(0x1118D9F2)],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      dark: dark,
                      onBack: () {
                        widget.audio.effect('tap');
                        Navigator.maybePop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _Panel(
                      dark: dark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Compare the mass in water',
                                          style: TextStyle(
                                              color: dark
                                                  ? const Color(0xFFB8FFFF)
                                                  : const Color(0xFF0828D7),
                                              fontSize: 26,
                                              height: 1.05,
                                              fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'See how the apparent mass of an object changes when it is immersed in a fluid.',
                                        style: TextStyle(
                                            color: foreground,
                                            fontSize: 16,
                                            height: 1.25),
                                      ),
                                    ],
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: 'Simulation information',
                                  child: IconButton.filled(
                                    onPressed: showInfo,
                                    icon: const Icon(Icons.info_outline),
                                    style: IconButton.styleFrom(
                                        minimumSize: const Size(48, 48),
                                        foregroundColor: Colors.white,
                                        backgroundColor: _blue),
                                  ),
                                ),
                              ]),
                          const SizedBox(height: 12),
                          _Scene(
                            dark: dark,
                            object: object,
                            fluid: fluid,
                            massKg: massKg,
                            fluidLitres: fluidLitres,
                            animation: animation,
                            result: result,
                            onDrop: (data) {
                              selectObject(objects.indexOf(data));
                              tryIt();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Panel(
                      dark: dark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Title('Choose an object', dark),
                          const SizedBox(height: 10),
                          LayoutBuilder(builder: (context, constraints) {
                            final width = (constraints.maxWidth - 24) / 4;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < objects.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 8),
                                  SizedBox(
                                    width: width,
                                    child: _ObjectChoice(
                                      data: objects[i],
                                      selected: i == objectIndex,
                                      dark: dark,
                                      onTap: () => selectObject(i),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                          const SizedBox(height: 14),
                          Text('Editable mass',
                              style: TextStyle(
                                  color: foreground,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: massController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{0,2}(\.\d{0,3})?')),
                            ],
                            onSubmitted: (_) => readMass(),
                            onTapOutside: (_) => readMass(),
                            decoration: InputDecoration(
                              labelText: '${object.name} mass',
                              suffixText: 'kg',
                              helperText: 'Allowed range: 0.050–5.000 kg',
                              filled: true,
                              fillColor: dark
                                  ? const Color(0xCC061B42)
                                  : Colors.white.withValues(alpha: .88),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Panel(
                      dark: dark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Title('Choose fluid', dark),
                          const SizedBox(height: 10),
                          LayoutBuilder(builder: (context, constraints) {
                            final width = (constraints.maxWidth - 24) / 4;
                            return Row(children: [
                              for (var i = 0; i < fluids.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                SizedBox(
                                  width: width,
                                  child: _FluidChoice(
                                    data: fluids[i],
                                    selected: i == fluidIndex,
                                    dark: dark,
                                    onTap: () => selectFluid(i),
                                  ),
                                ),
                              ],
                            ]);
                          }),
                          if (fluid.name == 'Mercury') ...[
                            const SizedBox(height: 8),
                            Text(
                                'Mercury is included as a virtual simulation only.',
                                style: TextStyle(
                                    color: dark
                                        ? const Color(0xFFFFD77A)
                                        : const Color(0xFF7A4200),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Panel(
                      dark: dark,
                      child: Column(children: [
                        Row(children: [
                          Image.asset(
                              'assets/images/simulation_fluid_water_drop.png',
                              width: 42,
                              height: 42),
                          const SizedBox(width: 8),
                          Expanded(child: _Title('Adjust fluid volume', dark)),
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: 82, minHeight: 48),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xD905173A)
                                  : Colors.white.withValues(alpha: .88),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _cyan),
                            ),
                            child: Text('${fluidLitres.toStringAsFixed(1)} L',
                                style: TextStyle(
                                    color: foreground,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ]),
                        Semantics(
                          label: 'Adjust fluid volume',
                          value: '${fluidLitres.toStringAsFixed(1)} litres',
                          child: Slider(
                            value: fluidLitres,
                            min: .1,
                            max: 1,
                            divisions: 9,
                            onChanged: (value) {
                              animation.reset();
                              setState(() {
                                fluidLitres = value;
                                result = null;
                              });
                            },
                          ),
                        ),
                      ]),
                    ),
                    if (result != null) ...[
                      const SizedBox(height: 12),
                      _Results(
                          dark: dark,
                          object: object,
                          fluid: fluid,
                          massKg: massKg,
                          result: result!),
                    ],
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: _ActionButton(
                            label: 'Reset',
                            icon: Icons.refresh_rounded,
                            dark: dark,
                            filled: false,
                            onPressed: reset),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                            label: 'Try it',
                            icon: Icons.play_arrow_rounded,
                            dark: dark,
                            filled: true,
                            onPressed: tryIt),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dark, required this.onBack});
  final bool dark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : _navy;
    return _Panel(
      dark: dark,
      padding: const EdgeInsets.fromLTRB(10, 9, 14, 12),
      child: Column(children: [
        Row(children: [
          Semantics(
            button: true,
            label: 'Back',
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 32),
              color: color,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
          Expanded(
            child: Text('Simulation',
                style: TextStyle(
                    color: color, fontSize: 31, fontWeight: FontWeight.w900)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
            decoration: BoxDecoration(
              color: dark ? const Color(0xB30A1C4D) : const Color(0xDDF1FCFF),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _cyan),
            ),
            child: Text('2 / 6',
                semanticsLabel: 'Simulation 2 of 6',
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            6,
            (i) => Expanded(
              child: Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i < 2
                      ? (i == 1 ? _cyan : const Color(0xFF08A7F1))
                      : (dark
                          ? const Color(0xFF193668)
                          : const Color(0xFFBBD7EA)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: i < 2 && dark
                      ? const [BoxShadow(color: _cyan, blurRadius: 8)]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({
    required this.dark,
    required this.object,
    required this.fluid,
    required this.massKg,
    required this.fluidLitres,
    required this.animation,
    required this.result,
    required this.onDrop,
  });
  final bool dark;
  final _Object object;
  final _Fluid fluid;
  final double massKg;
  final double fluidLitres;
  final Animation<double> animation;
  final _Result? result;
  final ValueChanged<_Object> onDrop;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : _navy;
    final scale = dark
        ? 'assets/images/simulation_scale_dark.png'
        : 'assets/images/simulation_scale_light.png';
    final beakerScale = dark
        ? 'assets/images/simulation_beaker_scale_dark.png'
        : 'assets/images/simulation_beaker_scale_light.png';
    return SizedBox(
      height: 305,
      child: LayoutBuilder(builder: (context, constraints) {
        final half = constraints.maxWidth / 2;
        return Stack(clipBehavior: Clip.none, children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Text('Drag an object to the beaker or tap Try it',
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: half,
            height: 220,
            child: Stack(alignment: Alignment.bottomCenter, children: [
              Image.asset(scale, fit: BoxFit.contain),
              AnimatedBuilder(
                animation: animation,
                builder: (_, child) => Positioned(
                  left: 0,
                  right: 0,
                  bottom: 107,
                  child: Opacity(
                    opacity: 1 - animation.value,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: 105,
                  height: 105,
                  child: Image.asset(
                    object.asset,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                  bottom: 21,
                  child: _Readout(
                      'Mass in air', '${massKg.toStringAsFixed(3)} kg')),
            ]),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            width: half,
            height: 265,
            child: DragTarget<_Object>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) => onDrop(details.data),
              builder: (context, candidates, rejected) => Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: candidates.isEmpty
                        ? null
                        : BoxDecoration(
                            color: _cyan.withValues(alpha: .16),
                            border: Border.all(color: _cyan, width: 3),
                            borderRadius: BorderRadius.circular(24)),
                  ),
                  Positioned(
                    bottom: 102,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: fluid.color),
                      duration: const Duration(milliseconds: 420),
                      builder: (context, animatedColor, _) => AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) => CustomPaint(
                          size: Size(142, 20 + fluidLitres * 104),
                          painter: _FluidPainter(
                            color: animatedColor ?? fluid.color,
                            phase: animation.value * math.pi * 4,
                            agitated:
                                animation.value > 0 && animation.value < 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Image.asset(beakerScale, fit: BoxFit.contain),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (_, child) {
                      final t =
                          Curves.easeInOutCubic.transform(animation.value);
                      final travel = result?.floating == true ? 30.0 : 62.0;
                      return Positioned(
                        top: 5 + t * travel,
                        child: Opacity(
                          opacity: animation.value == 0 ? 0 : 1,
                          child: Transform.scale(scale: .82, child: child),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: Image.asset(
                        object.asset,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 102,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) => Container(
                          width: 142,
                          height: 20 + fluidLitres * 104,
                          decoration: BoxDecoration(
                            color: fluid.color.withValues(alpha: .12),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 21,
                    child: _Readout(
                      '${fluid.name} in glass',
                      result == null
                          ? '${(fluid.density * fluidLitres / 1000).toStringAsFixed(2)} kg'
                          : '${result!.finalScaleKg.toStringAsFixed(3)} kg',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 3,
            top: 43,
            child: Text('${fluidLitres.toStringAsFixed(1)} L',
                style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ),
        ]);
      }),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout(this.title, this.value);
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        width: 122,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xE7021439),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _cyan),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF75F4FF),
                  fontSize: 15,
                  fontWeight: FontWeight.w900)),
        ]),
      );
}

class _FluidPainter extends CustomPainter {
  const _FluidPainter({
    required this.color,
    required this.phase,
    required this.agitated,
  });

  final Color color;
  final double phase;
  final bool agitated;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final clip = RRect.fromRectAndCorners(
      bounds,
      bottomLeft: const Radius.circular(25),
      bottomRight: const Radius.circular(25),
    );
    canvas.save();
    canvas.clipRRect(clip);

    final amplitude = agitated ? 5.0 : 2.0;
    final surface = Path();
    for (double x = 0; x <= size.width + 2; x += 2) {
      final y =
          8 + math.sin((x / size.width) * math.pi * 3 + phase) * amplitude;
      if (x == 0) {
        surface.moveTo(x, y);
      } else {
        surface.lineTo(x, y);
      }
    }
    surface
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      surface,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: .58),
            color.withValues(alpha: .88),
          ],
        ).createShader(bounds),
    );
    canvas.drawPath(
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, 8),
            width: size.width,
            height: 13,
          ),
        ),
      Paint()
        ..color = Color.lerp(color, Colors.white, .45)!.withValues(alpha: .72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FluidPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.phase != phase ||
      oldDelegate.agitated != agitated;
}

class _ObjectChoice extends StatelessWidget {
  const _ObjectChoice(
      {required this.data,
      required this.selected,
      required this.dark,
      required this.onTap});
  final _Object data;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      button: true,
      selected: selected,
      label: '${data.name}. Drag to the beaker or tap to select.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 116),
            padding: const EdgeInsets.fromLTRB(4, 7, 4, 8),
            decoration: _choiceDecoration(dark, selected),
            child: Stack(children: [
              Column(children: [
                SizedBox(
                  height: 74,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      data.asset,
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Text(data.name,
                    maxLines: 1,
                    style: TextStyle(
                        color: dark ? Colors.white : _navy,
                        fontWeight: FontWeight.w900)),
              ]),
              if (selected)
                const Positioned(
                    right: 0,
                    child: Icon(Icons.check_circle, color: _blue, size: 23)),
            ]),
          ),
        ),
      ),
    );
    return Draggable<_Object>(
      data: data,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
          color: Colors.transparent,
          child: Image.asset(data.asset, width: 96, height: 96)),
      childWhenDragging: Opacity(opacity: .35, child: card),
      child: card,
    );
  }
}

class _FluidChoice extends StatelessWidget {
  const _FluidChoice(
      {required this.data,
      required this.selected,
      required this.dark,
      required this.onTap});
  final _Fluid data;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label:
            '${data.name}, density ${data.density.round()} kilograms per cubic metre',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 100,
              padding: const EdgeInsets.all(5),
              decoration: _choiceDecoration(dark, selected),
              child: Column(children: [
                Expanded(child: Image.asset(data.asset, fit: BoxFit.contain)),
                Text(data.name,
                    maxLines: 1,
                    style: TextStyle(
                        color: dark ? Colors.white : _navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
        ),
      );
}

BoxDecoration _choiceDecoration(bool dark, bool selected) => BoxDecoration(
      color:
          dark ? const Color(0xC9081D47) : Colors.white.withValues(alpha: .82),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
          color: selected ? _cyan : const Color(0xFF34AEEB),
          width: selected ? 3 : 1.2),
      boxShadow:
          selected ? const [BoxShadow(color: _cyan, blurRadius: 10)] : null,
    );

class _Results extends StatelessWidget {
  const _Results(
      {required this.dark,
      required this.object,
      required this.fluid,
      required this.massKg,
      required this.result});
  final bool dark;
  final _Object object;
  final _Fluid fluid;
  final double massKg;
  final _Result result;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : _navy;
    return _Panel(
      dark: dark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Title('Simulation result', dark),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Metric('Mass in air', '${massKg.toStringAsFixed(3)} kg', dark),
          _Metric('Apparent mass',
              '${result.apparentMassKg.toStringAsFixed(3)} kg', dark),
          _Metric('Displaced fluid',
              '${result.displacedL.toStringAsFixed(3)} L', dark),
          _Metric('Beaker scale change',
              '+${result.scaleChangeKg.toStringAsFixed(3)} kg', dark),
        ]),
        const SizedBox(height: 12),
        Text(
          'Scale: ${result.initialScaleKg.toStringAsFixed(3)} kg → ${result.finalScaleKg.toStringAsFixed(3)} kg',
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(explanation(),
            style: TextStyle(color: color, height: 1.35, fontSize: 15)),
      ]),
    );
  }

  String explanation() {
    if (result.fluidLimited) {
      return 'The ${object.name.toLowerCase()} displaces ${result.displacedL.toStringAsFixed(3)} L of ${fluid.name.toLowerCase()}, but this fill level is too low for its natural immersion. Add more fluid to test the full buoyant effect.';
    }
    if (result.floating) {
      return 'The ${object.name.toLowerCase()} floats because its average density (${result.objectDensity.toStringAsFixed(0)} kg/m³) is lower than ${fluid.name.toLowerCase()}. It displaces fluid with the same mass as the object, so its apparent mass is zero while floating freely.';
    }
    return 'The ${object.name.toLowerCase()} sinks because its average density (${result.objectDensity.toStringAsFixed(0)} kg/m³) is greater than ${fluid.name.toLowerCase()}. Buoyancy reduces its apparent mass by ${result.displacedMassKg.toStringAsFixed(3)} kg while it is fully immersed.';
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.dark);
  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        width: 135,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xD905173A)
              : Colors.white.withValues(alpha: .88),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cyan),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  color:
                      dark ? const Color(0xFFB8FFFF) : const Color(0xFF0A398B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: dark ? Colors.white : _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
        ]),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.dark,
      required this.filled,
      required this.onPressed});
  final String label;
  final IconData icon;
  final bool dark;
  final bool filled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Container(
          decoration: BoxDecoration(
            gradient: filled
                ? const LinearGradient(colors: [_cyan, _blue])
                : LinearGradient(
                    colors: dark
                        ? const [Color(0xFF0B2D65), Color(0xFF061739)]
                        : const [Colors.white, Color(0xFFDDF7FF)]),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _cyan, width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x6618D9F2), blurRadius: 12)
            ],
          ),
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 31),
            label: Text(label,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              backgroundColor: Colors.transparent,
              foregroundColor:
                  filled ? Colors.white : (dark ? Colors.white : _navy),
              shadowColor: Colors.transparent,
            ),
          ),
        ),
      );
}

class _Title extends StatelessWidget {
  const _Title(this.text, this.dark);
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: dark ? Colors.white : const Color(0xFF0828D7),
          fontSize: 22,
          height: 1.05,
          fontWeight: FontWeight.w900));
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.dark,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final bool dark;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xEE061C42), Color(0xEB020D28)]
                : const [Color(0xF8FFFFFF), Color(0xEAF2FCFF)],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _cyan, width: dark ? 1.7 : 1.2),
          boxShadow: [
            BoxShadow(
                color: dark ? const Color(0x7718D9F2) : const Color(0x391E92C9),
                blurRadius: dark ? 16 : 12,
                offset: const Offset(0, 5)),
          ],
        ),
        child: child,
      );
}

class _Object {
  const _Object(this.name, this.asset, this.volumeL);
  final String name;
  final String asset;
  final double volumeL;
}

class _Fluid {
  const _Fluid(this.name, this.asset, this.density, this.color);
  final String name;
  final String asset;
  final double density;
  final Color color;
}

class _Result {
  const _Result({
    required this.objectDensity,
    required this.submergedFraction,
    required this.displacedL,
    required this.displacedMassKg,
    required this.apparentMassKg,
    required this.initialScaleKg,
    required this.finalScaleKg,
    required this.scaleChangeKg,
    required this.floating,
    required this.fluidLimited,
  });
  final double objectDensity;
  final double submergedFraction;
  final double displacedL;
  final double displacedMassKg;
  final double apparentMassKg;
  final double initialScaleKg;
  final double finalScaleKg;
  final double scaleChangeKg;
  final bool floating;
  final bool fluidLimited;
}
