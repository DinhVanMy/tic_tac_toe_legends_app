

// Tiện ích tính điểm combo
import 'dart:math';

import 'package:flutter/material.dart';

class ComboCalculator {
  static int calculateComboScore(int baseScore, int comboMultiplier) {
    return baseScore * max(1, comboMultiplier);
  }

  static String getComboText(int comboCount) {
    if (comboCount <= 1) return '';
    if (comboCount <= 3) return 'Combo x$comboCount';
    if (comboCount <= 5) return 'Super Combo x$comboCount';
    if (comboCount <= 8) return 'Ultra Combo x$comboCount';
    return 'MASTER COMBO x$comboCount';
  }

  static Color getComboColor(int comboCount) {
    if (comboCount <= 1) return Colors.white;
    if (comboCount <= 3) return Colors.blue;
    if (comboCount <= 5) return Colors.green;
    if (comboCount <= 8) return Colors.orange;
    return Colors.purple;
  }
}
