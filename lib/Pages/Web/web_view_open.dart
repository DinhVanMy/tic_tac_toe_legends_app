import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Web/web_view_edit_controller.dart';

class WebViewOpen extends StatelessWidget {
  final String url;

  const WebViewOpen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final WebViewEditController controller = Get.put(WebViewEditController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 35,
          ),
        ),
        title: Column(
          children: [
            const Text(
              "Tic Tac Toe",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Obx(
              () => Text(
                controller.currentUrl.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: controller.canGoBack.value ? Colors.blue : Colors.white,
              ),
              onPressed: () async {
                if (controller.canGoBack.value) {
                  await controller.webViewController.goBack();
                  controller.updateNavigationState();
                }
              },
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color:
                    controller.canGoForward.value ? Colors.blue : Colors.white,
              ),
              onPressed: () async {
                if (controller.canGoForward.value) {
                  await controller.webViewController.goForward();
                  controller.updateNavigationState();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.blueAccent,
              size: 30,
            ),
            onPressed: () {
              controller.webViewController.reload();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.blueAccent,
              size: 30,
            ),
            onPressed: () {
              controller.copyLink(controller.currentUrl.value);
            },
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        onWebViewCreated: (webViewController) {
          controller.webViewController = webViewController;
        },
        onLoadStop: (webViewController, url) async {
          await controller.updateNavigationState();
        },
        onProgressChanged: (webViewController, progress) async {
          await controller.updateNavigationState();
        },
      ),
    );
  }
}
