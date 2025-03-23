
// Tiện ích lưu trữ
class GameStorage {
  // Lưu điểm cao
  static Future<void> saveHighScore(int score) async {
    // Thực hiện lưu điểm cao
  }

  // Lấy điểm cao
  static Future<int> getHighScore() async {
    // Lấy điểm cao từ lưu trữ
    return 0;
  }

  // Lưu cấp độ đã mở khóa
  static Future<void> saveUnlockedLevel(int level) async {
    // Thực hiện lưu cấp độ
  }

  // Lấy cấp độ đã mở khóa
  static Future<int> getUnlockedLevel() async {
    // Lấy cấp độ từ lưu trữ
    return 1;
  }

  // Lưu trạng thái game
  static Future<void> saveGameState(Map<String, dynamic> gameState) async {
    // Thực hiện lưu trạng thái
  }

  // Lấy trạng thái game
  static Future<Map<String, dynamic>?> getGameState() async {
    // Lấy trạng thái từ lưu trữ
    return null;
  }
}
