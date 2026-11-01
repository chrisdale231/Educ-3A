import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../widgets/fluid_ui.dart';

enum FluidTopic { pressure, buoyancy, flow }

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key, required this.audio});
  final AudioService audio;

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  FluidTopic topic = FluidTopic.pressure;
  double density = 1000;
  double depth = 3;
  double volume = 2;
  double area1 = 8;
  double area2 = 4;
  double speed1 = 2;

  @override
  Widget build(BuildContext context) {
    final answer = switch (topic) {
      FluidTopic.pressure => '${(density * 9.81 * depth / 1000).toStringAsFixed(1)} kPa',
      FluidTopic.buoyancy => '${(density * 9.81 * volume / 1000).toStringAsFixed(1)} N',
      FluidTopic.flow => '${(area1 * speed1 / area2).toStringAsFixed(2)} m/s',
    };
    final formula = switch (topic) {
      FluidTopic.pressure => 'P = ρgh • pressure increases with depth',
      FluidTopic.buoyancy => 'Fᵦ = ρgV • more displaced liquid gives more lift',
      FluidTopic.flow => 'A₁v₁ = A₂v₂ • narrower pipe means faster flow',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Fluid simulations')),
      body: FluidBackdrop(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          const PageTitle('Experiment with fluids', subtitle: 'Drag the sliders and watch the result change.'),
          FluidCard(child: DropdownButtonFormField<FluidTopic>(
            initialValue: topic,
            decoration: const InputDecoration(labelText: 'Choose a simulation', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: FluidTopic.pressure, child: Text('Water pressure')),
              DropdownMenuItem(value: FluidTopic.buoyancy, child: Text('Buoyant force')),
              DropdownMenuItem(value: FluidTopic.flow, child: Text('Fluid flow')),
            ],
            onChanged: (value) { if (value != null) { widget.audio.effect('tap'); setState(() => topic = value); } },
          )),
          const SizedBox(height: 16),
          FluidCard(child: Column(children: [
            SizedBox(height: 155, width: double.infinity,
              child: CustomPaint(painter: _FluidDiagram(topic: topic, fraction: topic == FluidTopic.pressure
                  ? depth / 10 : topic == FluidTopic.buoyancy ? volume / 5 : area2 / 20))),
            const SizedBox(height: 14),
            if (topic != FluidTopic.flow)
              _control('Liquid density', density, 700, 1300, 'kg/m³', (v) => setState(() => density = v)),
            if (topic == FluidTopic.pressure)
              _control('Depth', depth, 0, 10, 'm', (v) => setState(() => depth = v)),
            if (topic == FluidTopic.buoyancy)
              _control('Displaced volume', volume, .1, 5, 'L', (v) => setState(() => volume = v)),
            if (topic == FluidTopic.flow) ...[
              _control('First pipe area', area1, 1, 20, 'cm²', (v) => setState(() => area1 = v)),
              _control('First pipe speed', speed1, .2, 5, 'm/s', (v) => setState(() => speed1 = v)),
              _control('Second pipe area', area2, 1, 20, 'cm²', (v) => setState(() => area2 = v)),
            ],
          ])),
          const SizedBox(height: 16),
          FluidCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RESULT', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: sea)),
            Text(answer, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, color: sea)),
            const SizedBox(height: 5),
            Text(formula),
            if (topic == FluidTopic.pressure) const Text('Gauge pressure only; atmospheric pressure is excluded.'),
          ])),
        ]),
      ))),
    );
  }

  Widget _control(String name, double value, double min, double max, String unit, ValueChanged<double> change) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$name: ${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontWeight: FontWeight.w700)),
      Slider(value: value, min: min, max: max, onChanged: change),
    ]);
  }
}

class _FluidDiagram extends CustomPainter {
  const _FluidDiagram({required this.topic, required this.fraction});
  final FluidTopic topic;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final water = Paint()..color = const Color(0xFF65CEEA);
    final line = Paint()..color = sea..style = PaintingStyle.stroke..strokeWidth = 4;
    if (topic == FluidTopic.flow) {
      final center = size.height / 2;
      final narrow = 12 + fraction * 38;
      final path = Path()..moveTo(14, center - 45)..lineTo(size.width * .5, center - narrow)
        ..lineTo(size.width - 14, center - narrow)..lineTo(size.width - 14, center + narrow)
        ..lineTo(size.width * .5, center + narrow)..lineTo(14, center + 45)..close();
      canvas.drawPath(path, water);
      canvas.drawPath(path, line);
      for (var x = 45.0; x < size.width - 45; x += 48) {
        canvas.drawLine(Offset(x, center), Offset(x + 18, center), line);
        canvas.drawLine(Offset(x + 18, center), Offset(x + 11, center - 6), line);
        canvas.drawLine(Offset(x + 18, center), Offset(x + 11, center + 6), line);
      }
    } else {
      final tank = Rect.fromLTWH(size.width * .19, 10, size.width * .62, size.height - 20);
      canvas.drawRRect(RRect.fromRectAndRadius(tank, const Radius.circular(14)), water);
      canvas.drawRRect(RRect.fromRectAndRadius(tank, const Radius.circular(14)), line);
      final y = topic == FluidTopic.pressure ? tank.top + 16 + fraction * (tank.height - 34) : tank.center.dy;
      final object = Rect.fromCenter(center: Offset(tank.center.dx, y), width: 55, height: 36);
      canvas.drawRRect(RRect.fromRectAndRadius(object, const Radius.circular(8)), Paint()..color = const Color(0xFFFFC365));
      if (topic == FluidTopic.buoyancy) {
        canvas.drawLine(Offset(tank.center.dx, object.bottom + 30), Offset(tank.center.dx, object.bottom + 5), line);
        canvas.drawLine(Offset(tank.center.dx, object.bottom + 5), Offset(tank.center.dx - 7, object.bottom + 13), line);
        canvas.drawLine(Offset(tank.center.dx, object.bottom + 5), Offset(tank.center.dx + 7, object.bottom + 13), line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FluidDiagram oldDelegate) => topic != oldDelegate.topic || fraction != oldDelegate.fraction;
}
