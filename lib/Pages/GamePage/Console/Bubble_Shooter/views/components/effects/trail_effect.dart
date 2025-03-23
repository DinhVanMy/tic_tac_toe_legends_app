import 'package:flutter/material.dart';

class TrailEffect extends StatelessWidget {
  final List<Offset> trailPoints;
  final Color color;
  final double width;

  const TrailEffect({
    super.key,
    required this.trailPoints,
    required this.color,
    this.width = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrailPainter(
        trailPoints: trailPoints,
        color: color,
        width: width,
      ),
    );
  }
}

class TrailPainter extends CustomPainter {
  final List<Offset> trailPoints;
  final Color color;
  final double width;

  TrailPainter({
    required this.trailPoints,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trailPoints.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(trailPoints.first.dx, trailPoints.first.dy);

    for (int i = 1; i < trailPoints.length; i++) {
      path.lineTo(trailPoints[i].dx, trailPoints[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) {
    return oldDelegate.trailPoints != trailPoints ||
        oldDelegate.color != color ||
        oldDelegate.width != width;
  }
}