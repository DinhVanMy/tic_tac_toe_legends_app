import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class BorderFrameController extends GetxController {
  // Rx list to store gradients
  var gradients = <List<Color>>[].obs;
  var isLoading = false.obs;
  final ThemeController themeController = Get.find();
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    loadMoreGradients();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // Load more gradients function
  void loadMoreGradients() {
    if (isLoading.value) return;
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      List<List<Color>> newGradients = List.generate(30, (_) {
        final colors =
            GradientGeneratorFunctions.getDynamicRandomGradientColors(
          colorCount: 2,
          isDarkMode: themeController.isDarkMode.value,
        );

        return colors;
      });

      // Sử dụng addAll để thêm nhiều phần tử một lần duy nhất
      gradients.addAll(newGradients);
      isLoading.value = false;
    });
  }
}
