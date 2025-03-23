// Tiện ích âm thanh
class SoundManager {
  static bool isSoundEnabled = true;

  // Mô phỏng các hàm phát âm thanh
  static void playShootSound() {
    if (!isSoundEnabled) return;
    // Phát âm thanh bắn
  }

  static void playPopSound() {
    if (!isSoundEnabled) return;
    // Phát âm thanh nổ
  }

  static void playMatchSound(int count) {
    if (!isSoundEnabled) return;
    // Phát âm thanh match, khác nhau dựa trên số lượng bóng
  }

  static void playVictorySound() {
    if (!isSoundEnabled) return;
    // Phát âm thanh chiến thắng
  }

  static void playGameOverSound() {
    if (!isSoundEnabled) return;
    // Phát âm thanh thua cuộc
  }

  static void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }
}