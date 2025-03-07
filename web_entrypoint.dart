// web/web_entrypoint.dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:tictactoe_gameapp/main.dart' as app;

void main() {
  // Đảm bảo URL strategy không dùng hash (#) trên web
  setUrlStrategy(PathUrlStrategy());
  // Gọi hàm main từ main.dart
  app.main();
}