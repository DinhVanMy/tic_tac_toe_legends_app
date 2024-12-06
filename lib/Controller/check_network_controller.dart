import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class CheckNetworkController extends GetxController {
  var isConnected = true.obs;
  var ping = 0.obs; // Lưu thời gian ping (ms)
  late StreamSubscription<InternetConnectionStatus> _streamSubscription;
  Timer? _pingTimer;

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
      showNoConnectionDialog(onPressed: () {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        _checkConnection().then((_) => errorMessage("Connection is failed..."));
      });
    }
  }

  void _listenForConnectionChanges() {
    _streamSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      isConnected.value = status == InternetConnectionStatus.connected;
      if (!isConnected.value) {
        showNoConnectionDialog(onPressed: () {
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          _checkConnection()
              .then((_) => errorMessage("Connection is failed..."));
        });
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
          successMessage("Connection is established!");
        }
      }
    });
  }

  /// Bắt đầu theo dõi ping
  void _startPingMonitoring() {
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _measurePing();
    });
  }

  /// Đo thời gian ping
  Future<void> _measurePing() async {
    const String host = '8.8.8.8'; // Google DNS
    try {
      final stopwatch = Stopwatch()..start();
      final socket =
          await Socket.connect(host, 80, timeout: const Duration(seconds: 5));
      stopwatch.stop();
      ping.value = stopwatch.elapsedMilliseconds;
      socket.destroy();
    } catch (e) {
      ping.value = -1; // -1 để biểu thị lỗi khi không đo được ping
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }
}
