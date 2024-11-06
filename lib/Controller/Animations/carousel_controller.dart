import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class CarouselController extends GetxController {
  final int realItemCount = images.length;
  late final int virtualItemCount;
  late final PageController pageController;
  late var currentPage = (realItemCount * 500).toDouble().obs;

  @override
  void onInit() {
    super.onInit();
    virtualItemCount = realItemCount * 1000;
    pageController =
        PageController(viewportFraction: 0.4, initialPage: realItemCount * 500);
    pageController.addListener(() {
      currentPage.value = pageController.page!;
    });
  }

  // Điều chỉnh lại chỉ số thực tế
  int getRealIndex(int virtualIndex) {
    return virtualIndex % realItemCount;
  }

  Matrix4 build3DTransform(int index) {
    double offsetFromCenter = index - currentPage.value;
    double angle = offsetFromCenter * pi / 5;
    double scale = 1 - (offsetFromCenter.abs() * 0.3);
    double depth = -300 * cos(angle); // Điều chỉnh chiều sâu

    return Matrix4.identity()
      ..rotateY(angle)
      ..translate(200 * sin(angle), 0.0, depth)
      ..scale(scale);
  }

  Color itemColor(int index) {
    double offsetFromCenter = (index - currentPage.value).abs();
    double opacity = 1 - offsetFromCenter * 0.5;

    // Đảm bảo rằng opacity luôn nằm trong khoảng từ 0 đến 1
    opacity = opacity.clamp(0.0, 1.0);

    return Colors.red.withOpacity(opacity); // Điều chỉnh opacity
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
