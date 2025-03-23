// Widget hiển thị thông báo combo với hiệu ứng
import 'package:flutter/material.dart';

class AnimatedComboMessage extends StatelessWidget {
  final String message;

  const AnimatedComboMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.5 + (value * 0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getColorForMessage(message).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getColorForMessage(message).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getColorForMessage(message).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: "Orbitron",
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: _getColorForMessage(message),
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForMessage(String msg) {
    switch (msg) {
      case 'Nice!':
        return Colors.blue;
      case 'Great!':
        return Colors.green;
      case 'Awesome!':
        return Colors.orange;
      case 'Incredible!':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}
