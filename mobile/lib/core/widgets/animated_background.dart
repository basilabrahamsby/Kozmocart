import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A subtle, luxury background animation widget featuring drifting ambient
/// glow orbs and dynamic mesh gradients.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final bool enableFloatingOrbs;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.enableFloatingOrbs = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableFloatingOrbs) {
      return Container(
        color: AppTheme.backgroundLight,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final double dx1 = math.sin(progress * math.pi * 2) * 35;
        final double dy1 = math.cos(progress * math.pi * 2) * 25;
        final double dx2 = math.cos(progress * math.pi * 2) * 30;
        final double dy2 = math.sin(progress * math.pi * 2) * 40;

        return Stack(
          children: [
            // Base background
            Container(color: Colors.white),

            // Top-Right Drifting Luxury Glow Orb (Brand Rose)
            Positioned(
              top: -60 + dy1,
              right: -80 + dx1,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryRose.withValues(alpha: 0.07),
                      AppTheme.primaryRose.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-Left Drifting Luxury Glow Orb (Brand Gold)
            Positioned(
              bottom: 100 + dy2,
              left: -90 + dx2,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentGold.withValues(alpha: 0.08),
                      AppTheme.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Center Subtle Shimmer Accent
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45 + (dx1 * 0.5),
              right: MediaQuery.of(context).size.width * 0.2 + (dy1 * 0.5),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC084FC).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Layer
            widget.child,
          ],
        );
      },
    );
  }
}
