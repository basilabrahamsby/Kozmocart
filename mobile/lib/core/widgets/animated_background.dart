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
        final double dx1 = math.sin(progress * math.pi * 2) * 55;
        final double dy1 = math.cos(progress * math.pi * 2) * 45;
        final double dx2 = math.cos(progress * math.pi * 2) * 50;
        final double dy2 = math.sin(progress * math.pi * 2) * 60;
        final double pulseScale = 1.0 + (math.sin(progress * math.pi * 2) * 0.15);

        return Stack(
          children: [
            // Soft Luxury Canvas Base
            Container(color: const Color(0xFFFAFAFC)),

            // 1. Top-Right Floating Brand Rose Orb
            Positioned(
              top: -80 + dy1,
              right: -90 + dx1,
              child: Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryRose.withValues(alpha: 0.22),
                        AppTheme.primaryRose.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Top-Left Floating Luxury Gold Orb
            Positioned(
              top: 120 - dy2,
              left: -100 + dx2,
              child: Transform.scale(
                scale: 1.1 - (pulseScale - 1.0),
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentGold.withValues(alpha: 0.25),
                        AppTheme.accentGold.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Bottom-Right Drifting Violet Accent Orb
            Positioned(
              bottom: 80 + dy1,
              right: -70 - dx2,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC084FC).withValues(alpha: 0.18),
                      const Color(0xFFC084FC).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // 4. Center-Bottom Soft Coral Shimmer
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25 + (dy2 * 0.5),
              left: MediaQuery.of(context).size.width * 0.15 + (dx1 * 0.5),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.discountOrange.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Screen Content
            widget.child,
          ],
        );
      },
    );
  }
}
