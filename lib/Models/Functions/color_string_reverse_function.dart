import 'dart:ui';

class ColorStringReverseFunction {
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', ''); // Loại bỏ dấu #
    if (hex.length == 6) {
      hex = 'FF$hex'; // Thêm alpha nếu thiếu
    }
    return Color(int.parse(hex, radix: 16));
  }
}
