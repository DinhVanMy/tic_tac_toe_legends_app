import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DottedBorderAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo AnimationController để điều khiển animation
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // Thời gian để hoàn thành một vòng
    )..repeat(); // Lặp lại animation liên tục
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
