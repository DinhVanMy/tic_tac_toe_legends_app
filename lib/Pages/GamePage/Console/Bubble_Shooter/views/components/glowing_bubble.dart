
// Widget để tạo hiệu ứng tỏa sáng
import 'package:flutter/material.dart';

class GlowingBubble extends StatefulWidget {
  final Widget child;
  final Color glowColor;

  const GlowingBubble({
    super.key,
    required this.child,
    this.glowColor = Colors.white,
  });

  @override
  State<GlowingBubble> createState() => _GlowingBubbleState();
}

class _GlowingBubbleState extends State<GlowingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 2.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(0.5),
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 3,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}