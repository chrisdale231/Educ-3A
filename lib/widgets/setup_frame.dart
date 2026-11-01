import 'package:flutter/material.dart';

import '../services/app_state.dart';

const setupNavy = Color(0xFF075078);
const setupBlue = Color(0xFF075BB0);

class SetupFrame extends StatelessWidget {
  const SetupFrame({super.key, required this.state, required this.child});

  final AppState state;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/dark_mode_background.png',
                fit: BoxFit.cover),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(color: Color(0xAA001638), blurRadius: 18),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class SetupTitle extends StatelessWidget {
  const SetupTitle(this.title, this.subtitle, {super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 29,
                  color: setupNavy,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(color: Color(0x66001D43), blurRadius: 2)])),
          const SizedBox(height: 2),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: setupNavy, letterSpacing: .7)),
        ],
      );
}

class SetupImageButton extends StatelessWidget {
  const SetupImageButton(
      {super.key,
      required this.asset,
      required this.label,
      required this.onTap,
      this.width = 190,
      this.height = 55});

  final String asset;
  final String label;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        child: SetupTapAnimation(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(asset,
              width: width,
              height: height,
              fit: BoxFit.contain,
              excludeFromSemantics: true),
        ),
      );
}

class SetupTapAnimation extends StatefulWidget {
  const SetupTapAnimation({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius,
    this.customBorder,
  });

  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;

  @override
  State<SetupTapAnimation> createState() => _SetupTapAnimationState();
}

class _SetupTapAnimationState extends State<SetupTapAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateTap() async {
    if (_animating || widget.onTap == null) return;
    _animating = true;
    try {
      await _controller.forward();
      await _controller.reverse();
    } on TickerCanceled {
      return;
    } finally {
      _animating = false;
    }
    if (mounted) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: widget.onTap == null ? null : _animateTap,
        borderRadius: widget.borderRadius,
        customBorder: widget.customBorder,
        child: ScaleTransition(scale: _scale, child: widget.child),
      );
}
