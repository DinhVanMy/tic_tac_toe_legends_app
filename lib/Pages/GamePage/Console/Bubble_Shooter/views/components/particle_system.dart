import 'dart:math';
import 'package:flutter/material.dart';

// Hiệu ứng particle cho animation
class ParticleSystem extends StatelessWidget {
  final Offset center;
  final Color color;
  final int particleCount;
  final double size;

  const ParticleSystem({
    super.key,
    required this.center,
    required this.color,
    this.particleCount = 10,
    this.size = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(particleCount, (i) {
        final random = Random();
        final angle = random.nextDouble() * 2 * pi;
        final velocity = 50 + random.nextDouble() * 100;
        final size = this.size * (0.5 + random.nextDouble() * 0.5);

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 500 + random.nextInt(500)),
          builder: (context, value, child) {
            return Positioned(
              left: center.dx + cos(angle) * velocity * value - size / 2,
              top: center.dy + sin(angle) * velocity * value - size / 2,
              child: Opacity(
                opacity: 1 - value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

