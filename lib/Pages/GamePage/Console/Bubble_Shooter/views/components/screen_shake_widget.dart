
// Hiệu ứng rung màn hình
import 'dart:math';

import 'package:flutter/material.dart';

class ScreenShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final double intensity;

  const ScreenShakeWidget({
    super.key,
    required this.child,
    this.isShaking = false,
    this.intensity = 5.0,
  });

  @override
  State<ScreenShakeWidget> createState() => _ScreenShakeWidgetState();
}

class _ScreenShakeWidgetState extends State<ScreenShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(ScreenShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !oldWidget.isShaking) {
      _startShaking();
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _stopShaking();
    }
  }

  void _startShaking() {
    final random = Random();

    _animation = TweenSequence<Offset>([
      for (int i = 0; i < 5; i++)
        TweenSequenceItem(
          tween: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(
              (random.nextDouble() * 2 - 1) * widget.intensity / 100,
              (random.nextDouble() * 2 - 1) * widget.intensity / 100,
            ),
          ),
          weight: 1,
        ),
    ]).animate(_controller);

    _controller.forward(from: 0);
  }

  void _stopShaking() {
    _controller.stop();
    _animation = Tween<Offset>(
      begin: _animation.value,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );

    _controller.forward(from: 0);
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
        return Transform.translate(
          offset: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}