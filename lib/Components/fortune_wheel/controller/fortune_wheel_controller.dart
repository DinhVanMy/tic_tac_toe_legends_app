import 'package:flutter/widgets.dart';

import 'package:tictactoe_gameapp/Components/fortune_wheel/widgets/fortune_wheel_child.dart';

class FortuneWheelController<T> extends ChangeNotifier {
  FortuneWheelChild<T>? value;

  bool isAnimating = false;
  bool shouldStartAnimation = false;

  void rotateTheWheel() {
    shouldStartAnimation = true;
    notifyListeners();
  }

  void animationStarted() {
    shouldStartAnimation = false;
    isAnimating = true;
  }

  void setValue(FortuneWheelChild<T> fortuneWheelChild) {
    value = fortuneWheelChild;
    notifyListeners();
  }

  void animationFinished() {
    isAnimating = false;
    shouldStartAnimation = false;
    notifyListeners();
  }
}
