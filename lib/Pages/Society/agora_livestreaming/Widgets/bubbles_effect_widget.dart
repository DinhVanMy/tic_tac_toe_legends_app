import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class EmojiDisplay extends StatelessWidget {
  final RxList<String> emojies;
  const EmojiDisplay({super.key, required this.emojies});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: emojies.map((imagePath) {
          final random = Random();
          return Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedEmoji(
                imagePath: imagePath,
                startX: random.nextDouble(),
                startY: 0.5,
                controlX: random.nextDouble(),
                controlY: random.nextDouble(),
                endX: random.nextDouble(),
                endY: -1.0,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class AnimatedEmoji extends StatefulWidget {
  final String imagePath;
  final double startX;
  final double startY;
  final double controlX;
  final double controlY;
  final double endX;
  final double endY;

  const AnimatedEmoji({
    super.key,
    required this.imagePath,
    required this.startX,
    required this.startY,
    required this.controlX,
    required this.controlY,
    required this.endX,
    required this.endY,
  });

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Opacity giảm dần
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOut), //easeOut , easeInOut
    );

    // Kích thước emoji nhỏ dần
    _sizeAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Hiệu ứng thay đổi vị trí (Bezier Curve)
    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(widget.startX, widget.startY),
          end: Offset(widget.controlX, widget.controlY),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(widget.controlX, widget.controlY),
          end: Offset(widget.endX, widget.endY),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: GradientGeneratorFunctions.generateRandomColor(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _positionAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _sizeAnimation.value / 50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _colorAnimation.value ?? Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  widget.imagePath,
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
