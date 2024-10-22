import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/Progress/mission_progress_controller.dart';


class CustomLinearProgress extends StatelessWidget {
  final ProgressController controller;

  const CustomLinearProgress({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double progress = controller.currentValue.value / controller.targetValue;

      return Stack(
        alignment: Alignment.center, // Canh giữa text trong thanh progress
        children: [
          // Bo góc cho thanh LinearProgressIndicator
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // Bo tròn các góc
            child: LinearProgressIndicator(
              value: progress, // Giá trị progress
              minHeight: 20, // Độ cao của thanh progress
              backgroundColor: Colors.grey[300], // Màu nền
              color: Colors.blue, // Màu hiển thị tiến độ
            ),
          ),
          // Hiển thị text phần trăm tiến độ
          Text(
            '${controller.currentValue.value}/${controller.targetValue}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    });
  }
}
