// Tiện ích rung
class HapticManager {
  static bool isHapticEnabled = true;

  static void vibrate() {
    if (!isHapticEnabled) return;
    // Rung nhẹ
  }

  static void heavyVibrate() {
    if (!isHapticEnabled) return;
    // Rung mạnh
  }

  static void toggleHaptic() {
    isHapticEnabled = !isHapticEnabled;
  }
}
