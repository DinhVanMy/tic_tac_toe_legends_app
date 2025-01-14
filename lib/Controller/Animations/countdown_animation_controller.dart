import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';

class CountdownController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController animationController;
  final BackgroundMusicController musicController = Get.find();
  var timeLeft = 95.obs;
  var progressColor = Colors.blue.obs;

  @override
  void onInit() {
    super.onInit();
    // Tạo AnimationController điều khiển animation cho border theo thời gian
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 95),
    );

    listenerCountdown();
    animationController.forward();
  }

  void listenerCountdown() {
    // Đăng ký listener để cập nhật timeLeft dựa trên animationController
    animationController.addListener(() {
      // Cập nhật timeLeft dựa trên tiến trình animation
      timeLeft.value = (95 - animationController.value * 95).round();

      // Thay đổi màu viền dựa trên thời gian còn lại
      if (timeLeft.value <= 30) {
        progressColor.value = Colors.red; // Dưới 30 giây: Màu đỏ
      } else if (timeLeft.value <= 60) {
        progressColor.value = Colors.orange; // Dưới 60 giây: Màu vàng
      } else {
        progressColor.value = Colors.blue; // Trên 60 giây: Màu xanh
      }

      // Kiểm tra nếu hết thời gian thì dừng animation
      if (animationController.isCompleted) {
        stopAnimation();
        Get.offAllNamed("/mainHome");
      }
    });
  }

  void stopAnimation() async {
    musicController.stopMusicOnScreen5();
    animationController.stop();
  }


  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
