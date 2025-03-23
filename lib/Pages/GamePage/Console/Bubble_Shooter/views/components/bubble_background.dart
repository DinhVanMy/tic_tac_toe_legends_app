// Hiệu ứng nền đẹp hơn
import 'dart:math';

import 'package:flutter/material.dart';

class BubbleBackground extends StatelessWidget {
  final Color startColor;
  final Color endColor;

  const BubbleBackground({
    super.key,
    this.startColor = const Color(0xFFE0F7FF),
    this.endColor = const Color(0xFF88C9FF),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [startColor, endColor],
            ),
          ),
        ),

        // Decorative bubbles
        ...List.generate(20, (index) {
          final random = Random();
          final size = 20.0 + random.nextDouble() * 30.0;

          return Positioned(
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            child: Opacity(
              opacity: 0.05 + random.nextDouble() * 0.1,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
