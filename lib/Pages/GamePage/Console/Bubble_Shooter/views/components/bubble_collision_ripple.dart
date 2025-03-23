
// Hiệu ứng gợn sóng khi bóng chạm vào grid
import 'package:flutter/material.dart';

class BubbleCollisionRipple extends StatelessWidget {
  final Offset position;

  const BubbleCollisionRipple({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Positioned(
          left: position.dx - 30 * value,
          top: position.dy - 30 * value,
          child: Opacity(
            opacity: 1.0 - value,
            child: Container(
              width: 60 * value,
              height: 60 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

