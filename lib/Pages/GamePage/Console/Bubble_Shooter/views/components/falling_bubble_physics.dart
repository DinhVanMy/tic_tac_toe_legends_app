// Hiệu ứng bóng rơi với vật lý
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/model/bubble_models.dart';

class FallingBubblePhysics extends StatefulWidget {
  final Bubble bubble;
  final double size;
  final VoidCallback onComplete;

  const FallingBubblePhysics({
    super.key,
    required this.bubble,
    required this.size,
    required this.onComplete,
  });

  @override
  State<FallingBubblePhysics> createState() => _FallingBubblePhysicsState();
}

class _FallingBubblePhysicsState extends State<FallingBubblePhysics>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _startPosition;
  late Offset _velocity;
  late double _angularVelocity;
  late double _rotation;
  Offset _currentPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    final random = Random();
    _startPosition = Offset(
      widget.bubble.col * widget.size,
      widget.bubble.row * widget.size,
    );
    _currentPosition = _startPosition;

    // Random initial velocity
    _velocity = Offset(
      (random.nextDouble() * 2 - 1) * 5,
      -random.nextDouble() * 3,
    );

    // Random rotation
    _angularVelocity = (random.nextDouble() * 2 - 1) * 0.2;
    _rotation = 0;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800 + random.nextInt(400)),
    );

    _controller.addListener(_updatePosition);
    _controller.forward().then((_) => widget.onComplete());
  }

  void _updatePosition() {
    if (!mounted) return;

    // Apply gravity
    _velocity = Offset(_velocity.dx, _velocity.dy + 0.5);

    // Update position
    _currentPosition = Offset(
      _currentPosition.dx + _velocity.dx,
      _currentPosition.dy + _velocity.dy,
    );

    // Update rotation
    _rotation += _angularVelocity;

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentPosition.dx,
      top: _currentPosition.dy,
      child: Transform.rotate(
        angle: _rotation,
        child: Opacity(
          opacity: 1.0 - _controller.value * 0.5,
          child: Container(
            width: widget.size,
            height: widget.size,
            padding: const EdgeInsets.all(1.5),
            child: CircleAvatar(
              backgroundImage: AssetImage(widget.bubble.heroAsset),
            ),
          ),
        ),
      ),
    );
  }
}