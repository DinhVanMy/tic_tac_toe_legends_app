import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfettiToController extends GetxController {
  late ConfettiController confettiController;

  @override
  void onInit() {
    super.onInit();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      confettiController.play();
    });
  }

  void startConfetti() {
    confettiController.play();
  }

  void stopConfetti() {
    confettiController.stop();
  }

  @override
  void onClose() {
    confettiController.dispose();
    super.onClose();
  }
}
