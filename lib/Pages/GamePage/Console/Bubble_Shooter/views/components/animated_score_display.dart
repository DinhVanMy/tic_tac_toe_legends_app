
// Widget để hiển thị điểm số với hiệu ứng nhảy số
import 'package:flutter/material.dart';

class AnimatedScoreDisplay extends StatelessWidget {
  final int score;
  final int previousScore;
  final TextStyle style;

  const AnimatedScoreDisplay({
    super.key,
    required this.score,
    required this.previousScore,
    this.style = const TextStyle(
      fontFamily: 'Orbitron',
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: previousScore, end: score),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }
}
