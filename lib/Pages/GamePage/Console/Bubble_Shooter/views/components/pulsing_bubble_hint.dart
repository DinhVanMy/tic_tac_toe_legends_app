// Hiệu ứng bóng nhấp nháy để gợi ý
import 'package:flutter/material.dart';

class PulsingBubbleHint extends StatefulWidget {
  final Widget child;
  final bool isHinting;

  const PulsingBubbleHint({
    super.key,
    required this.child,
    required this.isHinting,
  });

  @override
  State<PulsingBubbleHint> createState() => _PulsingBubbleHintState();
}

class _PulsingBubbleHintState extends State<PulsingBubbleHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isHinting) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingBubbleHint oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHinting && !oldWidget.isHinting) {
      _controller.repeat(reverse: true);
    } else if (!widget.isHinting && oldWidget.isHinting) {
      _controller.stop();
      _controller.reset();
    }
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
        return Transform.scale(
          scale: widget.isHinting ? _animation.value : 1.0,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
