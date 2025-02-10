import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class TinderCardController extends GetxController {
  final CardSwiperController cardController = CardSwiperController();
  final ThemeController themeController = Get.find();
  late final List<List<Color>> newGradients;

  final int colorsLength;
  TinderCardController({required this.colorsLength});

  @override
  void onInit() {
    super.onInit();
    newGradients = List.generate(colorsLength, (_) {
      final colors = GradientGeneratorFunctions.getDynamicRandomGradientColors(
        colorCount: 2,
        isDarkMode: themeController.isDarkMode.value,
      );

      return colors;
    });
  }

  @override
  void onClose() {
    cardController.dispose();
    super.onClose();
  }

  bool onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    print(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
    );
    return true;
  }

  bool onUndo(
      int? previousIndex, int currentIndex, CardSwiperDirection direction) {
    print(
      'The card $currentIndex was undone from the ${direction.name}',
    );
    return true;
  }

  void swipe(CardSwiperDirection direction) {
    cardController.swipe(direction);
  }

  void undo() {
    cardController.undo();
  }
}
