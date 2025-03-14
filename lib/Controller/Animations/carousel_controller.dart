import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class CarouselController extends GetxController {
  final int realItemCount = images.length; // 6 item từ images
  late final int virtualItemCount;
  late PageController pageController;
  late var currentPage = (realItemCount * 500).toDouble().obs;

  @override
  void onInit() {
    super.onInit();
    virtualItemCount = realItemCount * 1000; // Vòng lặp vô hạn
    _initializePageController();
  }

  void _initializePageController() {
    pageController = PageController(
      viewportFraction: 0.4,
      initialPage: realItemCount * 500,
    );
    pageController.addListener(_pageListener);
    _syncCurrentPage();
  }

  void reinitializePageController() {
    pageController.removeListener(_pageListener);
    if (pageController.hasClients) {
      pageController.dispose(); // Chỉ dispose nếu controller đang hoạt động
    }
    _initializePageController();
    update(); // Thông báo GetX cập nhật giao diện
  }

  void _pageListener() {
    if (pageController.hasClients && pageController.positions.isNotEmpty) {
      // Kiểm tra số lượng positions để tránh assertion error
      if (pageController.positions.length == 1) {
        currentPage.value = pageController.page ?? currentPage.value;
      }
    }
  }

  void _syncCurrentPage() {
    if (pageController.hasClients && pageController.positions.isNotEmpty) {
      if (pageController.positions.length == 1) {
        currentPage.value = pageController.page ?? currentPage.value;
      }
    } else {
      currentPage.value = realItemCount * 500.toDouble();
    }
  }

  int getRealIndex(int virtualIndex) {
    return virtualIndex % realItemCount;
  }

  Matrix4 build3DTransform(int index) {
    double offsetFromCenter = index - currentPage.value;
    double angle = offsetFromCenter * pi / 5;
    double scale = 1 - (offsetFromCenter.abs() * 0.3).clamp(0.0, 1.0);
    double depth = -300 * cos(angle);

    return Matrix4.identity()
      ..rotateY(angle)
      ..translate(200 * sin(angle), 0.0, depth)
      ..scale(scale);
  }

  @override
  void onClose() {
    pageController.removeListener(_pageListener);
    pageController.dispose();
    super.onClose();
  }
}
