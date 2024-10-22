import 'package:flutter/material.dart';

class TrianglePainter extends CustomPainter {
  final Color color;
  final Alignment alignment; // Thêm alignment để biết vị trí tam giác

  TrianglePainter({required this.color, required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    var path = Path();
    if (alignment == Alignment.topCenter) {
      // Tam giác hướng lên trên
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.bottomCenter) {
      // Tam giác hướng xuống dưới
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.centerRight) {
      // Tam giác hướng sang phải
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height);
    } else if (alignment == Alignment.centerLeft) {
      // Tam giác hướng sang trái
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height / 2);
      path.lineTo(size.width, size.height);
    }

    path.close();
    canvas.drawPath(path, paint); // Vẽ tam giác
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// Tam giác có thể tùy chỉnh cong
class CurvedTailPainter extends CustomPainter {
  final Color color;
  final Alignment alignment;

  CurvedTailPainter({required this.color, required this.alignment});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path();

    if (alignment == Alignment.bottomCenter) {
      // Đuôi cong ở dưới widget, hướng từ dưới lên
      path.moveTo(size.width / 2, 0); // Đỉnh tam giác
      path.quadraticBezierTo(
          size.width / 2 - 20, size.height / 2, 
          size.width / 2 - 30, size.height); // Cạnh trái uốn cong xuống dưới
      path.lineTo(size.width / 2 + 30, size.height); // Cạnh phải kéo xuống dưới
      path.quadraticBezierTo(
          size.width / 2 + 20, size.height / 2, 
          size.width / 2, 0); // Cạnh phải uốn cong lại lên đỉnh
    } else if (alignment == Alignment.topCenter) {
      // Đuôi cong ở trên widget, hướng từ trên xuống
      path.moveTo(size.width / 2, size.height); // Đỉnh tam giác ở dưới
      path.quadraticBezierTo(
          size.width / 2 - 20, size.height / 2, 
          size.width / 2 - 30, 0); // Cạnh trái uốn cong lên trên
      path.lineTo(size.width / 2 + 30, 0); // Cạnh phải kéo lên trên
      path.quadraticBezierTo(
          size.width / 2 + 20, size.height / 2, 
          size.width / 2, size.height); // Cạnh phải uốn cong lại xuống dưới
    } else if (alignment == Alignment.centerLeft) {
      // Đuôi cong bên trái widget, hướng từ trái sang
      path.moveTo(size.width, size.height / 2); // Đỉnh tam giác
      path.quadraticBezierTo(
          size.width / 2, size.height / 2 - 20, 
          0, size.height / 2 - 30); // Cạnh trên uốn cong
      path.lineTo(0, size.height / 2 + 30); // Kéo xuống cạnh dưới
      path.quadraticBezierTo(
          size.width / 2, size.height / 2 + 20, 
          size.width, size.height / 2); // Cạnh dưới uốn cong lên
    } else if (alignment == Alignment.centerRight) {
      // Đuôi cong bên phải widget, hướng từ phải sang
      path.moveTo(0, size.height / 2); // Đỉnh tam giác
      path.quadraticBezierTo(
          size.width / 2, size.height / 2 - 20, 
          size.width, size.height / 2 - 30); // Cạnh trên uốn cong
      path.lineTo(size.width, size.height / 2 + 30); // Kéo xuống cạnh dưới
      path.quadraticBezierTo(
          size.width / 2, size.height / 2 + 20, 
          0, size.height / 2); // Cạnh dưới uốn cong xuống
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
