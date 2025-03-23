import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/controllers/bubble_shooter_gameplay_controller.dart';

class ShootingPathOverlay extends StatelessWidget {
  final BubbleShooterController controller;

  const ShootingPathOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final gridHeight =
        MediaQuery.of(context).size.height * controller.gridHeightFactor;

    // Direct access to the observable list using .value
    return GetBuilder<BubbleShooterController>(
        id: 'path', // Optional: Use an ID to only rebuild when needed
        builder: (ctrl) {
          // Make sure we're accessing the actual observable value
          final points = ctrl.pathPoints;

          return CustomPaint(
            size: Size.infinite,
            painter: ShootingPathPainter(
              pathPoints: points,
              screenSize: MediaQuery.of(context).size,
              gridHeight: gridHeight,
            ),
          );
        });
  }
}

class ShootingPathPainter extends CustomPainter {
  final List<Offset> pathPoints;
  final Size screenSize;
  final double gridHeight;

  ShootingPathPainter({
    required this.pathPoints,
    required this.screenSize,
    required this.gridHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pathPoints.isEmpty) return;

    final path = Path();
    final dotPath = Path();
    const dotRadius = 2.5;

    // Tạo các điểm tuyệt đối trên đường đạn
    final absolutePoints = pathPoints
        .map((point) => Offset(
              point.dx * screenSize.width,
              point.dy * gridHeight,
            ))
        .toList();

    // Vẽ đường mũi tên
    path.moveTo(absolutePoints.first.dx, absolutePoints.first.dy);

    // Chỉ lấy một phần của đường đạn để làm đường nhắm
    final displayPoints = absolutePoints.length > 10
        ? absolutePoints.sublist(0, min(absolutePoints.length, 20))
        : absolutePoints;

    // Vẽ các chấm trên đường nhắm
    for (int i = 1; i < displayPoints.length; i += 4) {
      final point = displayPoints[i];
      dotPath.addOval(Rect.fromCircle(center: point, radius: dotRadius));
    }

    // Vẽ mũi tên ở đầu đường nhắm
    if (displayPoints.length > 5) {
      final lastPoint = displayPoints[displayPoints.length - 1];
      final secondLastPoint = displayPoints[displayPoints.length - 5];
      final angle = atan2(
        lastPoint.dy - secondLastPoint.dy,
        lastPoint.dx - secondLastPoint.dx,
      );

      // Vẽ mũi tên
      final arrowPath = Path();
      arrowPath.moveTo(lastPoint.dx, lastPoint.dy);
      arrowPath.lineTo(
        lastPoint.dx - 15 * cos(angle - 0.3),
        lastPoint.dy - 15 * sin(angle - 0.3),
      );
      arrowPath.moveTo(lastPoint.dx, lastPoint.dy);
      arrowPath.lineTo(
        lastPoint.dx - 15 * cos(angle + 0.3),
        lastPoint.dy - 15 * sin(angle + 0.3),
      );

      final arrowPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(arrowPath, arrowPaint);
    }

    // Vẽ các chấm
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(dotPath, dotPaint);
  }

  @override
  bool shouldRepaint(covariant ShootingPathPainter oldDelegate) {
    return oldDelegate.pathPoints != pathPoints ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.gridHeight != gridHeight;
  }
}
