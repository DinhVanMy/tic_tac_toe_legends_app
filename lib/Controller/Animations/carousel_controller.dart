import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class CarouselController extends GetxController {
  final int realItemCount = images.length;
  late final int virtualItemCount;
  late PageController pageController;
  late var currentPage = (realItemCount * 500).toDouble().obs;

  @override
  void onInit() {
    super.onInit();
    virtualItemCount = realItemCount * 1000;
    _initializePageController();
  }

  void _initializePageController() {
    pageController =
        PageController(viewportFraction: 0.4, initialPage: realItemCount * 500);
    pageController.addListener(_pageListener);
  }

  void reinitializePageController() {
    pageController.removeListener(_pageListener);
    _initializePageController();
  }

  void _pageListener() {
    if (pageController.positions.length == 1) {
      currentPage.value = pageController.page!;
    }
  }

  int getRealIndex(int virtualIndex) {
    return virtualIndex % realItemCount;
  }

  Matrix4 build3DTransform(int index) {
    double offsetFromCenter = index - currentPage.value;
    double angle = offsetFromCenter * pi / 5;
    double scale = 1 - (offsetFromCenter.abs() * 0.3);
    double depth = -300 * cos(angle);

    return Matrix4.identity()
      ..rotateY(angle)
      ..translate(200 * sin(angle), 0.0, depth)
      ..scale(scale);
  }

  Color itemColor(int index) {
    double offsetFromCenter = (index - currentPage.value).abs();
    double opacity = 1 - offsetFromCenter * 0.5;
    opacity = opacity.clamp(0.0, 1.0);

    return Colors.red.withOpacity(opacity);
  }

  @override
  void onClose() {
    pageController.removeListener(_pageListener);
    pageController.dispose();
    super.onClose();
  }
}
