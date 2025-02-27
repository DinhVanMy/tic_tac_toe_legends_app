import 'package:flutter/material.dart';

class LikeAnimationWidget extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onAnimationComplete;

  const LikeAnimationWidget({
    super.key,
    required this.isLiked,
    required this.onAnimationComplete,
  });

  @override
  State<LikeAnimationWidget> createState() => _LikeAnimationWidgetState();
}

class _LikeAnimationWidgetState extends State<LikeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Thời gian animation
    );

    // Animation phóng to (scale)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    // Animation mờ dần (opacity)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    // Animation rung nhẹ
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.02), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.02, end: -0.02), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -0.02, end: 0.02), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.02, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeInOut)),
    );

    // Bắt đầu animation và gọi callback khi hoàn thành
    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform(
              transform: Matrix4.identity()
                ..scale(_scaleAnimation.value)
                ..rotateZ(_shakeAnimation.value), // Hiệu ứng rung
              alignment: Alignment.center,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked ? Colors.red : Colors.white,
                size: 120, // Kích thước lớn hơn để hoành tráng
              ),
            ),
          );
        },
      ),
    );
  }
}
