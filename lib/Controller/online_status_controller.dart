import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';

class OnlineStatusController extends GetxController
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = Get.find<AuthController>().getCurrentUserId();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance
        .addObserver(this); // Lắng nghe trạng thái app lifecycle.
    setOnline(); // Đặt trạng thái online khi khởi động app.
  }

  @override
  void onClose() {
    setOffline(); // Đặt trạng thái offline khi đóng app.
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Cập nhật trạng thái khi thay đổi vòng đời của app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setOnline(); // App vào foreground (online).
    } else if (state == AppLifecycleState.paused) {
      setOffline(); // App vào background (offline).
    }
  }

  // Đặt trạng thái online trong Firestore
  Future<void> setOnline() async {
    await _firestore.collection('users').doc(userId).update({
      'status': 'online',
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Đặt trạng thái offline trong Firestore
  Future<void> setOffline() async {
    await _firestore.collection('users').doc(userId).update({
      'status': 'offline',
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
}
