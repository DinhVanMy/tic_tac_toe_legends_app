import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class WebViewEditController extends GetxController {
  late InAppWebViewController webViewController;

  // Rx variables for reactive UI updates
  var canGoBack = false.obs;
  var canGoForward = false.obs;
  var currentUrl = ''.obs;

  // Copy current link to clipboard
  void copyLink(String url) {
    Clipboard.setData(ClipboardData(text: currentUrl.value));
    successMessage('Link "$url" Copied');
  }

  // Update navigation state
  Future<void> updateNavigationState() async {
    try {
      canGoBack.value = await webViewController.canGoBack();
      canGoForward.value = await webViewController.canGoForward();
      currentUrl.value = (await webViewController.getUrl())?.toString() ?? '';
    } catch (e) {
      errorMessage('Error updating navigation state: $e');
    }
  }
}
