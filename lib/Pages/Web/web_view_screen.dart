import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class UltizeScreen extends StatelessWidget {
  const UltizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url2)),
          keepAlive: InAppWebViewKeepAlive(),
          key: GlobalKey(),
        ),
      ),
    );
  }
}
