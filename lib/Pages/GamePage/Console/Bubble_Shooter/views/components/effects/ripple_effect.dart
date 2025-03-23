import 'package:flutter/material.dart';

class RippleEffect extends StatelessWidget {
  final Offset center;
  final Color color;

  const RippleEffect({
    super.key,
    required this.center,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Positioned(
          left: center.dx - 50 * value,
          top: center.dy - 50 * value,
          child: Opacity(
            opacity: 1 - value,
            child: Container(
              width: 100 * value,
              height: 100 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.5),
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