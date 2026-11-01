import 'package:flutter/material.dart';

const sea = Color(0xFF067FA8);
const navy = Color(0xFF12385D);
const cyan = Color(0xFF5BD6E3);

class FluidBackdrop extends StatelessWidget {
  const FluidBackdrop({super.key, required this.child, this.white = false});
  final Widget child;
  final bool white;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final backgroundImage = dark
        ? 'assets/images/dark_mode_background.png'
        : 'assets/images/light_mode_background.png';

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [Color(0x08000000), Color(0x24030E18)]
                    : [
                        Colors.white.withValues(alpha: white ? .15 : .06),
                        Colors.transparent,
                        sea.withValues(alpha: .04),
                      ],
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class FluidCard extends StatelessWidget {
  const FluidCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xF21D3B55), Color(0xF2122A40)]
              : const [Color(0xFAFFFFFF), Color(0xF2EAF8FC)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x351477AA), blurRadius: 18, offset: Offset(0, 8))
        ],
        border: Border.all(color: cyan.withValues(alpha: .65)),
      ),
      child: child,
    );
  }
}

class MenuImageButton extends StatelessWidget {
  const MenuImageButton(
      {super.key,
      required this.title,
      this.image,
      this.icon,
      required this.onTap})
      : assert(image != null || icon != null);
  final String title;
  final String? image;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [Color(0xF21D3B55), Color(0xF2122A40)]
                  : const [Color(0xFCFFFFFF), Color(0xF4EAF8FC)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cyan.withValues(alpha: .8)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x401477AA),
                  blurRadius: 14,
                  offset: Offset(0, 7)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  cyan.withValues(alpha: .38),
                  sea.withValues(alpha: .14),
                ]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sea.withValues(alpha: .3)),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x26067FA8),
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: image != null
                  ? Image.asset(image!, fit: BoxFit.contain)
                  : Icon(icon, color: sea, size: 42),
            ),
            Expanded(
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w800))),
            const SizedBox(width: 66),
          ]),
        ),
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900, color: sea)),
          if (subtitle != null)
            Padding(
                padding: const EdgeInsets.only(top: 3), child: Text(subtitle!)),
        ]),
      );
}
