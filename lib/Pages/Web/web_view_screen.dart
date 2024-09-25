import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String url =
        "https://ant.games/?utm_source=gg&utm_campaign=arb-161872";
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
          keepAlive: InAppWebViewKeepAlive(),
          key: GlobalKey(),
        ),
      ),
    );
  }
}
