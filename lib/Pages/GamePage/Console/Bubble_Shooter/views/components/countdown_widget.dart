
// Hiệu ứng đếm ngược khi thêm hàng mới
import 'package:flutter/material.dart';

class CountdownWidget extends StatelessWidget {
  final int seconds;
  final VoidCallback onComplete;

  const CountdownWidget({
    super.key,
    required this.seconds,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: seconds.toDouble(), end: 0),
      duration: Duration(seconds: seconds),
      onEnd: onComplete,
      builder: (context, value, child) {
        final remainingSeconds = value.ceil();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '$remainingSeconds',
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}