import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewControllers extends GetxController {
  late InAppBrowserClassSettings settings;

  @override
  void onInit() {
    super.onInit();
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
