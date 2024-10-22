import 'package:get/get.dart';

class ProgressController extends GetxController {
  var currentValue = 0.obs; // Giá trị hiện tại bắt đầu từ 0
  final int targetValue; // Giá trị đích

  ProgressController(this.targetValue);

  // Hàm tăng giá trị hiện tại
  void incrementProgress(int value) {
    if (currentValue.value + value <= targetValue) {
      currentValue.value += value;
    }
  }
  
}
