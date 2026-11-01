import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/fluid_ui.dart';

class ConceptScreen extends StatelessWidget {
  const ConceptScreen({super.key, required this.state});

  final AppState state;

  String t(String english, String tagalog) => state.text(english, tagalog);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            AppBar(title: Text(t('Fluid Concepts', 'Mga Konsepto ng Likido'))),
        body: FluidBackdrop(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  PageTitle(
                    t('Physics of Fluids', 'Pisika ng mga Likido'),
                    subtitle: t('Explore the ideas used throughout BEACON.',
                        'Tuklasin ang mga ideyang ginagamit sa BEACON.'),
                  ),
                  _ConceptCard(
                    icon: Icons.water_drop_rounded,
                    title: t('What is a fluid?', 'Ano ang likido?'),
                    text: t(
                      'A fluid is a substance that flows and takes the shape of its container. Liquids and gases are fluids.',
                      'Ang fluid ay sangkap na dumadaloy at sumusunod sa hugis ng lalagyan nito. Ang mga likido at gas ay mga fluid.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConceptCard(
                    icon: Icons.compress_rounded,
                    title: t('Pressure', 'Presyon'),
                    text: t(
                      'Pressure is force divided by area: P = F/A. In a liquid, pressure increases with depth: P = rho gh.',
                      'Ang presyon ay puwersa na hinati sa lawak: P = F/A. Sa likido, tumataas ang presyon habang lumalalim: P = rho gh.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConceptCard(
                    icon: Icons.sailing_rounded,
                    title: t('Buoyancy', 'Paglutang'),
                    text: t(
                      'A fluid pushes upward on an immersed object. The buoyant force equals the weight of displaced fluid.',
                      'Itinutulak pataas ng fluid ang nakalubog na bagay. Ang puwersa ng paglutang ay katumbas ng bigat ng fluid na naitulak.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ConceptCard(
                    icon: Icons.air_rounded,
                    title: t('Fluid flow', 'Daloy ng fluid'),
                    text: t(
                      'For steady incompressible flow, A1v1 = A2v2. Fluid moves faster through a narrower passage.',
                      'Sa tuloy-tuloy na daloy, A1v1 = A2v2. Mas mabilis dumaloy ang fluid sa mas makitid na daanan.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => FluidCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: sea, size: 38),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: sea,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      );
}
