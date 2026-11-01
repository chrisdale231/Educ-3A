class FluidQuestion {
  const FluidQuestion(this.text, this.answers, this.correct, this.explanation);
  final String text;
  final List<String> answers;
  final int correct;
  final String explanation;
}

const quizLevels = <List<FluidQuestion>>[
  [
    FluidQuestion('What is a fluid?', ['Only water', 'A substance that flows', 'Only air', 'A solid'], 1,
        'Liquids and gases both flow, so both are fluids.'),
    FluidQuestion('Which quantity tells how much mass is in each unit of volume?',
        ['Pressure', 'Density', 'Speed', 'Force'], 1, 'Density is mass divided by volume.'),
    FluidQuestion('What happens to water pressure as depth increases?',
        ['It increases', 'It decreases', 'It stays zero', 'It changes randomly'], 0,
        'More water above a point produces greater pressure.'),
    FluidQuestion('What is the SI unit of pressure?', ['Newton', 'Pascal', 'Liter', 'Kilogram'], 1,
        'One pascal equals one newton per square meter.'),
    FluidQuestion('An object less dense than water will usually…',
        ['Sink', 'Float', 'Disappear', 'Get heavier'], 1, 'An object with lower average density than water floats.'),
  ],
  [
    FluidQuestion('Which formula gives gauge pressure at depth h?',
        ['P = ρgh', 'P = mg', 'P = V/t', 'P = ρ/V'], 0, 'Fluid gauge pressure is density × gravity × depth.'),
    FluidQuestion('A 1 m deep point in water (ρ = 1000 kg/m³) has about how much gauge pressure?',
        ['0.98 kPa', '9.81 kPa', '98.1 kPa', '981 kPa'], 1,
        'P = 1000 × 9.81 × 1 = 9810 Pa = 9.81 kPa.'),
    FluidQuestion('Buoyant force equals the weight of the…',
        ['Object only', 'Displaced fluid', 'Container', 'Air above the fluid'], 1,
        'Archimedes’ principle uses the weight of the fluid displaced.'),
    FluidQuestion('For the same submerged volume, which liquid gives a larger buoyant force?',
        ['Less dense liquid', 'More dense liquid', 'Both equal', 'Neither'], 1,
        'Fᵦ = ρgV, so greater fluid density gives greater buoyant force.'),
    FluidQuestion('Pressure applied to a confined fluid is transmitted…',
        ['Only downward', 'Equally throughout the fluid', 'Only upward', 'Only at the surface'], 1,
        'Pascal’s principle describes transmission of applied pressure.'),
  ],
  [
    FluidQuestion('In steady incompressible flow, what stays equal at two pipe sections?',
        ['A + v', 'A × v', 'A ÷ v', 'A − v'], 1, 'Continuity gives A₁v₁ = A₂v₂.'),
    FluidQuestion('If a pipe narrows to half its area, the fluid speed becomes…',
        ['Half', 'Double', 'Zero', 'The same'], 1,
        'For steady incompressible flow, halving area doubles speed.'),
    FluidQuestion('A fully submerged 2 L object displaces water (ρ = 1000 kg/m³). Its buoyant force is about…',
        ['1.96 N', '19.62 N', '196.2 N', '1962 N'], 1,
        '2 L = 0.002 m³, so Fᵦ = 1000 × 9.81 × 0.002 = 19.62 N.'),
    FluidQuestion('At the same depth, which liquid has greater gauge pressure?',
        ['ρ = 800 kg/m³', 'ρ = 1000 kg/m³', 'Both equal', 'Pressure is independent of density'], 1,
        'P = ρgh, so the denser liquid has more pressure.'),
    FluidQuestion('For ideal horizontal flow, a region with higher speed generally has…',
        ['Higher static pressure', 'Lower static pressure', 'No pressure', 'Infinite pressure'], 1,
        'Bernoulli’s principle relates higher speed to lower static pressure under ideal conditions.'),
  ],
];
