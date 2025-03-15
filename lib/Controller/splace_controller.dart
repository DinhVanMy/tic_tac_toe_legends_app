import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/online_status_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';

class SplaceController extends GetxController with GetSingleTickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  RxDouble progress = 0.0.obs;
  late AnimationController animationController;
  late Animation<double> progressAnimation;
  bool isLoadingComplete = false;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo AnimationController
    animationController = AnimationController(
      duration: const Duration(seconds: 3), // Thời gian tối đa để chạy từ 0-100%
      vsync: this,
    );

    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {
        progress.value = progressAnimation.value;
        // Chỉ chuyển trang khi cả loading hoàn tất và progress đạt 100%
        if (isLoadingComplete && progress.value >= 1.0) {
          _navigate();
        }
      });

    // Bắt đầu animation
    animationController.forward();
    // Chạy logic tải song song
    splaceHandle();
  }

  Future<void> splaceHandle() async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập bước đầu
    if (auth.currentUser == null) {
      isLoadingComplete = true;
      // Nếu animation chưa xong, tăng tốc để đạt 100%
      if (progress.value < 1.0) {
        animationController.duration = const Duration(milliseconds: 500); // Giảm thời gian còn lại
        animationController.forward(from: progress.value);
      }
    } else {
      final ProfileController profileController = Get.put(ProfileController());
      await profileController.initialize();
      Get.put(OnlineStatusController(), permanent: true);
      isLoadingComplete = true;
      // Nếu animation chưa xong, tăng tốc để đạt 100%
      if (progress.value < 1.0) {
        animationController.duration = const Duration(milliseconds: 500); // Giảm thời gian còn lại
        animationController.forward(from: progress.value);
      }
    }
  }

  void _navigate() {
    if (auth.currentUser == null) {
      Get.offAllNamed("/welcome");
    } else {
      Get.offAllNamed("/mainHome");
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}