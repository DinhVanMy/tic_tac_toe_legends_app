import 'dart:math';
import 'package:flutter/material.dart';

class GradientGeneratorFunctions {
  // Hàm sinh gradient ngẫu nhiên
  static LinearGradient generateRandomGradient({required bool isDarkMode}) {
    // Tạo đối tượng Random
    final random = Random();

    // Hàm sinh màu ngẫu nhiên
    Color randomColor() {
      int r = random.nextInt(256);
      int g = random.nextInt(256);
      int b = random.nextInt(256);
      return Color.fromRGBO(r, g, b, 1);
    }

    // Sinh màu dựa trên mode
    Color startColor;
    Color endColor;

    if (isDarkMode) {
      // Tạo màu tối cho dark mode
      startColor = randomColor().withOpacity(0.8);
      endColor = randomColor().withOpacity(0.8);
    } else {
      // Tạo màu sáng cho light mode
      startColor = randomColor().withOpacity(0.6);
      endColor = randomColor().withOpacity(0.6);
    }

    // Trả về gradient ngẫu nhiên
    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<Color> getDynamicRandomGradientColors({
    int colorCount = 5,
    bool isDarkMode = false,
  }) {
    final Random random = Random();
    final List<Color> colors = [];

    for (int i = 0; i < colorCount; i++) {
      // Sinh màu ngẫu nhiên
      Color randomColor = Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );

      // Điều chỉnh độ sáng tối cho isDarkMode
      if (isDarkMode) {
        randomColor = randomColor.withOpacity(0.8); // Màu tối hơn cho dark mode
      } else {
        randomColor =
            randomColor.withOpacity(0.6); // Màu sáng hơn cho light mode
      }

      colors.add(randomColor);
    }
    return colors;
  }

// Generate a random color
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255, // Always use full opacity
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  static String _getColorName(Color color) {
    if (color.red > color.green && color.red > color.blue) {
      return "Red";
    } else if (color.green > color.red && color.green > color.blue) {
      return "Green";
    } else if (color.blue > color.red && color.blue > color.green) {
      return "Blue";
    } else if (color.red == color.green && color.red > color.blue) {
      return "Yellow";
    } else if (color.red == color.blue && color.red > color.green) {
      return "Purple";
    } else {
      return "Gray";
    }
  }

  static String generateGradientName({required List<Color> colors}) {
    final Random random = Random();
    const adjectives = ["Vibrant", "Calm", "Energetic", "Peaceful", "Lively"];
    String primaryColorName = _getColorName(colors.first);
    const themes = ["Sunset", "Ocean", "Forest", "Rainbow", "Dusk"];

    return "${adjectives[random.nextInt(adjectives.length)]} "
        "$primaryColorName "
        "${themes[random.nextInt(themes.length)]}";
  }

  static List<Widget> generateGradientContainers({
    int length = 5,
    required bool isDarkMode,
  }) {
    return List.generate(length, (index) {
      // Sinh gradient mới cho mỗi container
      List<Color> colors = getDynamicRandomGradientColors(
        colorCount: 2, // Sử dụng 2 màu cho mỗi gradient
        isDarkMode: isDarkMode,
      );

      return Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100, // Chiều cao của mỗi Container
        width: 200, // Để Container có thể giãn đầy đủ theo chiều ngang
      );
    });
  }
}
