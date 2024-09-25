import 'dart:async';

import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class CheckNetworkController extends GetxController {
  var isConnected = true.obs;
  late StreamSubscription<InternetConnectionStatus> _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkConnection(); // Kiểm tra kết nối ban đầu
    _listenForConnectionChanges(); // Lắng nghe thay đổi kết nối
  }

  Future<void> _checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    isConnected.value = result;
    if (!result) {
      _showNoConnectionDialog();
    }
  }

  void _listenForConnectionChanges() {
    _streamSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      isConnected.value = status == InternetConnectionStatus.connected;
      if (!isConnected.value) {
        _showNoConnectionDialog();
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
          successMessage("Connection is established!");
        }
      }
    });
  }

  void _showNoConnectionDialog() {
    if (Get.isDialogOpen == false) {
      Get.dialog(
        AlertDialog(
          title: const Text('Oops...'),
          content: const Text('No internet! Check your network connection'),
          actions: [
            TextButton(
              onPressed: () {
                _checkConnection()
                    .then((_) => errorMessage("Connection is failed..."));
              },
              child: const Text('Retry'),
            ),
          ],
          icon: const Icon(
            Icons.warning,
            size: 40,
          ),
          iconColor: Colors.red,
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
