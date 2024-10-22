import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';

class WebViewControllers extends GetxController {
  late InAppBrowserClassSettings settings;
  final NotifyInMainController notifyInMainController =
      Get.put(NotifyInMainController());

  @override
  void onInit() {
    super.onInit();
    notifyInMainController.listenForFriendRequests();
    notifyInMainController.listenForGameInvites();
    settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(
        hideUrlBar: false,
        toolbarTopBackgroundColor: Colors.greenAccent,
        menuButtonColor: Colors.lightBlueAccent,
      ),
      webViewSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
      ),
    );
  }

  Future<void> openWebView({required String url}) async {
    await InAppBrowser().openUrlRequest(
      urlRequest: URLRequest(url: WebUri(url)),
      settings: settings,
    );
  }
}
