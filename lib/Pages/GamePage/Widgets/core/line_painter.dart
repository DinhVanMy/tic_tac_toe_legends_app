import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<Offset> lineCoordinates;
  final int gridSize; // Số hàng/cột trong lưới
  final Color color;

  LinePainter(this.lineCoordinates, this.gridSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    if (lineCoordinates.isNotEmpty) {
      // Tính toán kích thước của mỗi ô trong lưới
      double cellWidth = size.width / gridSize;
      double cellHeight = size.height / gridSize;

      // Lấy tọa độ điểm đầu và điểm cuối
      Offset start = Offset(
        lineCoordinates.first.dy * cellWidth + cellWidth / 2,
        lineCoordinates.first.dx * cellHeight + cellHeight / 2,
      );
      Offset end = Offset(
        lineCoordinates.last.dy * cellWidth + cellWidth / 2,
        lineCoordinates.last.dx * cellHeight + cellHeight / 2,
      );

      // Vẽ đường gạch giữa hai điểm
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
