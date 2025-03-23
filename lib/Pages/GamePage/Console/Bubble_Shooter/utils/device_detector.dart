// Tiện ích phát hiện thiết bị
import 'dart:math';

import 'package:flutter/material.dart';

class DeviceDetector {
  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 360 || size.height < 640;
  }

  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    return diagonal > 1100;
  }

  static double getBubbleSizeForDevice(BuildContext context, int columns) {
    final width = MediaQuery.of(context).size.width;
    final calculatedSize = width / columns;

    if (isTablet(context)) {
      return min(calculatedSize, 60.0);
    } else if (isSmallScreen(context)) {
      return calculatedSize * 0.9;
    } else {
      return calculatedSize;
    }
  }
}
