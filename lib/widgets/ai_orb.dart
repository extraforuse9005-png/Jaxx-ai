import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/jaxx_theme.dart';

enum OrbState { idle, listening, thinking, speaking, executing }

class AiOrb extends StatefulWidget {
  const AiOrb({
    super.key,
    this.state = OrbState.idle,
    this.size = 220,
    this.animate = true,
  });

  final OrbState state;
  final double size;

  /// Set to false for reduced motion. The orb then stays still.
  final bool animate;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AiOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accent {
    switch (widget.state) {
      case OrbState.idle:
        return JaxxColors.cyan;
      case OrbState.listening:
        return JaxxColors.electricBlue;
      case OrbState.thinking:
        return JaxxColors.purple;
      case OrbState.speaking:
        return JaxxColors.cyan;
      case OrbState.executing:
        return JaxxColors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = widget.animate
            ? 1.0 + 0.04 * math.sin(_controller.value * 2 * math.pi)
            : 1.0;
        final glow = _accent;

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glow.withValues(alpha: 0.9),
                  JaxxColors.electricBlue.withValues(alpha: 0.35),
                  JaxxColors.background,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.45),
                  blurRadius: 60,
                  spreadRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'J',
              style: TextStyle(
                fontSize: widget.size * 0.35,
                fontWeight: FontWeight.w300,
                color: JaxxColors.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
        );
      },
    );
  }
}
