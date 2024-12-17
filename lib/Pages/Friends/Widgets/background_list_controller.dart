import 'dart:ui';

import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class InfiniteGradientGridController extends GetxController {
  // Rx list to store gradients
  var gradients = <Map<String, dynamic>>[].obs;
  var colors = <Color>[].obs;
  var isLoading = false.obs;
  final ThemeController themeController = Get.find();

  final bool isGradient;
  InfiniteGradientGridController({required this.isGradient});

  @override
  void onInit() {
    super.onInit();
    if (isGradient) {
      loadMoreGradients();
    } else {
      loadMoreColors();
    }
  }

  // Load more gradients function
  void loadMoreGradients() {
    if (isLoading.value) return;
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      List<Map<String, dynamic>> newGradients = List.generate(9, (_) {
        final colors =
            GradientGeneratorFunctions.getDynamicRandomGradientColors(
          colorCount: 2,
          isDarkMode: themeController.isDarkMode.value,
        );

        return {
          "colors": colors,
          "name":
              GradientGeneratorFunctions.generateGradientName(colors: colors),
        };
      });

      // Sử dụng addAll để thêm nhiều phần tử một lần duy nhất
      gradients.addAll(newGradients);
      isLoading.value = false;
    });
  }

  // Load more colors function
  void loadMoreColors() {
    if (isLoading.value) return;
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 300), () {
      List<Color> newColors = List.generate(9, (_) {
        return GradientGeneratorFunctions.generateRandomColor();
      });

      // Thêm màu mới
      colors.addAll(newColors);
      isLoading.value = false;
    });
  }
}
