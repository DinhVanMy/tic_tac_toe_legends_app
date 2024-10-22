import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/Progress/mission_progress_controller.dart';

class SegmentedProgressIndicator extends StatelessWidget {
  final ProgressController controller;
  final int numberOfSegments; // Số lượng đoạn cần chia

  const SegmentedProgressIndicator({
    super.key,
    required this.controller,
    this.numberOfSegments = 10, // Số lượng đoạn mặc định là 10
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Tính toán mỗi đoạn tương ứng với giá trị nào
      double segmentValue = controller.targetValue / numberOfSegments;
      double completedSegments = controller.currentValue.value / segmentValue;

      return Row(
        children: List.generate(numberOfSegments, (index) {
          // Tính toán phần trăm hoàn thành
          bool isCompleted = index < completedSegments;

          return Expanded(
            child: Container(
              height: 20,
              margin: EdgeInsets.only(
                  right: index == numberOfSegments - 1
                      ? 0
                      : 2), // Khoảng cách giữa các đoạn
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.blue
                    : Colors.grey[300], // Màu sắc cho đoạn đã hoàn thành
                borderRadius: index == 0
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )
                    : index == numberOfSegments - 1
                        ? const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )
                        : BorderRadius.zero, // Bo góc chỉ cho đoạn đầu và cuối
              ),
            ),
          );
        }),
      );
    });
  }
}

class SegmentedCircularProgress extends StatelessWidget {
  final ProgressController controller;
  final int numberOfSegments; // Số lượng đoạn cần chia
  final double size; // Kích thước của vòng tròn

  const SegmentedCircularProgress({
    super.key,
    required this.controller,
    this.numberOfSegments = 10, // Mặc định là 10 đoạn
    this.size = 100, // Mặc định kích thước là 100
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Tính toán giá trị mỗi đoạn
      double segmentValue = controller.targetValue / numberOfSegments;
      double completedSegments = controller.currentValue.value / segmentValue;

      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < numberOfSegments; i++)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SegmentedCircularPainter(
                    index: i,
                    completed: i < completedSegments,
                    totalSegments: numberOfSegments,
                  ),
                ),
              ),
            // Text hiển thị phần trăm hoàn thành
            Obx(
              () => controller.currentValue.value != controller.targetValue
                  ? Text(
                      '${((controller.currentValue.value / controller.targetValue) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : const Icon(
                      Icons.done_all,
                      size: 80,
                      color: Colors.greenAccent,
                    ),
            )
          ],
        ),
      );
    });
  }
}

class _SegmentedCircularPainter extends CustomPainter {
  final int index;
  final bool completed;
  final int totalSegments;

  _SegmentedCircularPainter({
    required this.index,
    required this.completed,
    required this.totalSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = completed ? Colors.blue : Colors.grey[300]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double startAngle = (index / totalSegments) * 360;
    double sweepAngle = (1 / totalSegments) * 360;

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2),
      _radians(startAngle),
      _radians(sweepAngle - 2), // Giảm 2 để tạo khoảng cách giữa các đoạn
      false,
      paint,
    );
  }

  double _radians(double degrees) {
    return degrees * (3.1415927 / 180);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HeartProgressIndicator extends StatelessWidget {
  final ProgressController controller;
  final int totalHearts;

  const HeartProgressIndicator({
    super.key,
    required this.controller,
    this.totalHearts = 5, // Mặc định là 5 trái tim
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Tính toán số lượng trái tim đã hoàn thành
      double heartValue = controller.targetValue / totalHearts;
      int completedHearts =
          (controller.currentValue.value / heartValue).floor();

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalHearts, (index) {
          return Icon(
            index < completedHearts ? Icons.favorite : Icons.favorite_border,
            color: index < completedHearts ? Colors.red : Colors.grey,
            size: 40,
          );
        }),
      );
    });
  }
}
