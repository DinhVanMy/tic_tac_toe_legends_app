import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/Animations/Overlays/draw_tria.dart';

class WheelResultIndicator extends StatelessWidget {
  const WheelResultIndicator({
    super.key,
    required this.wheelSize,
    required this.animationController,
    required this.childCount,
  });

  final double wheelSize;
  final AnimationController animationController;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    double indicatorSize = wheelSize / 9;
    Color indicatorColor = Colors.white;

    return Stack(
      children: [
        _getCenterIndicatorTriangle(wheelSize, indicatorSize, indicatorColor),
        _getCenterIndicatorCircle(indicatorColor, indicatorSize),
      ],
    );
  }

  Positioned _getCenterIndicatorTriangle(
      double wheelSize, double indicatorSize, Color indicatorColor) {
    return Positioned(
      top: wheelSize / 2 - indicatorSize,
      left: wheelSize / 2 - (indicatorSize / 2),
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            origin: Offset(0, indicatorSize / 2),
            angle: (animationController.value * pi * 2) - (pi / (childCount)),
            child: CustomPaint(
                painter: TrianglePainter(
                  color: Colors.white, alignment: Alignment.bottomCenter,
                  // fillColor: indicatorColor,
                ),
                size: Size(indicatorSize, indicatorSize)),
          );
        },
        animation: animationController,
      ),
    );
  }

  Center _getCenterIndicatorCircle(Color indicatorColor, double indicatorSize) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: indicatorColor,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        width: indicatorSize,
        height: indicatorSize,
        child: Image.asset(
          Jajas.spinner,
          width: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
