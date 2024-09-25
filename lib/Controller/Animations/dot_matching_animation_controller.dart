import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchingAnimationController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController dotsAnimationController;

  var dotsOffset1 = 0.0.obs;
  var dotsOffset2 = 0.0.obs;
  var dotsOffset3 = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    initDotsWaveAnimation();
  }

  // Tạo animation sóng cho các dấu chấm
  void initDotsWaveAnimation() {
    dotsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    dotsAnimationController.addListener(() {
      // Sử dụng sin() để tạo hiệu ứng sóng, với pha khác nhau cho mỗi dấu chấm
      double animationValue = dotsAnimationController.value * 2 * pi;
      dotsOffset1.value = sin(animationValue) * 10;
      dotsOffset2.value = sin(animationValue + pi / 3) * 10; // Chênh lệch pha
      dotsOffset3.value =
          sin(animationValue + 2 * pi / 3) * 10; // Chênh lệch pha
    });
  }

  // Dừng animation
  void stopDotsAnimation() {
    dotsAnimationController.stop();
  }

  @override
  void onClose() {
    stopDotsAnimation();
    dotsAnimationController.dispose();
    super.onClose();
  }
}
