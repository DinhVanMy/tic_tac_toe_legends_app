import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class Match3Controller extends GetxController with GetTickerProviderStateMixin {
  late int gridSize;
  late RxList<RxList<RxInt>> grid;
  late List<String> activeHeroes;
  final RxInt score = 0.obs;
  late RxBool isAnimating = false.obs;
  RxMap<String, int> selectedItem = RxMap<String, int>();
  late String difficultyLevel;
  late final ConfettiController confettiController;

  late AnimationController animationController;

  var progressColor = Colors.blue.obs;
  final int durationPlay;
  RxInt timeLeft = 95.obs;

  Match3Controller({
    required this.gridSize,
    required this.difficultyLevel,
    required this.durationPlay,
  });

  @override
  void onInit() {
    super.onInit();
    initializeHeroes();
    initializeGrid();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationPlay),
    );
    listenerCountdown();
    animationController.forward();
  }

  @override
  void onClose() {
    confettiController.dispose();
    animationController.dispose();
    super.onClose();
  }

  void listenerCountdown() {
    // Đăng ký listener để cập nhật timeLeft dựa trên animationController
    animationController.addListener(() {
      // Cập nhật timeLeft dựa trên tiến trình animation
      timeLeft.value =
          (durationPlay - animationController.value * durationPlay).round();

      // Thay đổi màu viền dựa trên thời gian còn lại
      if (timeLeft.value <= durationPlay / 3 || timeLeft.value == 0) {
        progressColor.value = Colors.red; // Dưới 30 giây: Màu đỏ
      } else if (timeLeft.value <= durationPlay / 2) {
        progressColor.value = Colors.orange; // Dưới 60 giây: Màu vàng
      } else {
        progressColor.value = Colors.blue; // Trên 60 giây: Màu xanh
      }

      // Kiểm tra nếu hết thời gian thì dừng animation
      if (animationController.isCompleted) {
        animationController.stop();
      }
    });
  }

  // Tạo danh sách hero
  void initializeHeroes() {
    int heroCount = _getHeroCountByLevel();
    if (heroCount > listChampions.length) return;

    // Copy danh sách các hero để tránh ảnh hưởng tới danh sách gốc
    List<String> allHeroes = List.from(listChampions);

    // Xáo trộn danh sách
    allHeroes.shuffle();

    // Lấy heroCount phần tử đầu tiên
    activeHeroes = allHeroes.sublist(0, heroCount);
  }

  int _getHeroCountByLevel() {
    switch (difficultyLevel) {
      case 'Easy':
        return max(3, gridSize ~/ 2);
      case 'Medium':
        return max(5, gridSize ~/ 2 + 2);
      case 'Hard':
        return max(7, gridSize ~/ 2 + 4);
      case 'Expert':
        return max(9, gridSize ~/ 2 + 6);
      default:
        return 5;
    }
  }

  // Khởi tạo lưới ban đầu
  void initializeGrid() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => 0.obs).obs,
    ).obs;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        do {
          grid[i][j].value = Random().nextInt(activeHeroes.length);
        } while (_isPartOfMatch(i, j));
      }
    }
  }

  // Kiểm tra chuỗi hợp lệ
  bool _isPartOfMatch(int x, int y) {
    return _isMatchInDirection(x, y, dx: 1, dy: 0) ||
        _isMatchInDirection(x, y, dx: 0, dy: 1);
  }

  bool _isMatchInDirection(int x, int y, {required int dx, required int dy}) {
    int value = grid[x][y].value;
    int count = 1;

    for (int step = 1; step < 3; step++) {
      int nx = x - dx * step;
      int ny = y - dy * step;

      if (nx < 0 || ny < 0 || nx >= gridSize || ny >= gridSize) break;
      if (grid[nx][ny].value == value) {
        count++;
      } else {
        break;
      }
    }

    return count >= 3;
  }

  // Set ô được chọn
  void setSelectedItem(int x, int y) {
    if (isAnimating.value) return;
    selectedItem.value = {'x': x, 'y': y};
  }

  // Xử lý thả ô
  void handleDrop(int x, int y) {
    if (isAnimating.value || selectedItem.isEmpty) return;

    int x1 = selectedItem['x']!;
    int y1 = selectedItem['y']!;

    if ((x1 == x && (y1 - y).abs() == 1) || (y1 == y && (x1 - x).abs() == 1)) {
      _swap(x1, y1, x, y);

      if (_checkMatches()) {
        _findAndDestroyMatches();
      } else {
        _swap(x1, y1, x, y); // Hoàn tác nếu không hợp lệ
      }
    }

    selectedItem.clear();
  }

  void _swap(int x1, int y1, int x2, int y2) {
    final temp = grid[x1][y1].value;
    grid[x1][y1].value = grid[x2][y2].value;
    grid[x2][y2].value = temp;
  }

  // Kiểm tra các chuỗi hợp lệ
  bool _checkMatches() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_isPartOfMatch(i, j)) return true;
      }
    }
    return false;
  }

  RxList<List<int>> destroyedCells = <List<int>>[].obs;

  // Tìm và phá hủy chuỗi
  void _findAndDestroyMatches() async {
    isAnimating.value = true;
    confettiController.play();
    List<List<int>> matches = _findMatches();
    destroyedCells.clear();
    destroyedCells.addAll(matches);
    for (var cell in matches) {
      grid[cell[0]][cell[1]].value = -1; // Đánh dấu phá hủy
    }

    score.value += matches.length * 10; // Tăng điểm
    await _dropCells();

    if (_checkMatches()) {
      _findAndDestroyMatches();
    } else {
      isAnimating.value = false;
    }

    if (isGameOver()) {
      _showGameOverDialog();
    }
  }

  List<List<int>> _findMatches() {
    Set<List<int>> matches = {};

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (_isPartOfMatch(i, j)) {
          matches.addAll(_findMatchCoordinates(i, j));
        }
      }
    }

    return matches.toList();
  }

  List<List<int>> _findMatchCoordinates(int x, int y) {
    List<List<int>> cells = [];
    int value = grid[x][y].value;

    // Theo hàng
    for (int j = y; j >= 0 && grid[x][j].value == value; j--) {
      cells.add([x, j]);
    }
    for (int j = y + 1; j < gridSize && grid[x][j].value == value; j++) {
      cells.add([x, j]);
    }

    // Theo cột
    for (int i = x; i >= 0 && grid[i][y].value == value; i--) {
      cells.add([i, y]);
    }
    for (int i = x + 1; i < gridSize && grid[i][y].value == value; i++) {
      cells.add([i, y]);
    }

    return cells;
  }

  bool isGameOver() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        // Kiểm tra khả năng swap hợp lệ với ô bên cạnh
        if (j + 1 < gridSize) {
          _swap(i, j, i, j + 1);
          if (_checkMatches()) {
            _swap(i, j, i, j + 1); // Hoàn tác swap
            return false;
          }
          _swap(i, j, i, j + 1); // Hoàn tác swap
        }

        // Kiểm tra khả năng swap hợp lệ với ô bên dưới
        if (i + 1 < gridSize) {
          _swap(i, j, i + 1, j);
          if (_checkMatches()) {
            _swap(i, j, i + 1, j); // Hoàn tác swap
            return false;
          }
          _swap(i, j, i + 1, j); // Hoàn tác swap
        }
      }
    }
    return true;
  }

  Future<void> _dropCells() async {
    List<int> affectedColumns = _getAffectedColumns();
    for (int j in affectedColumns) {
      int emptyCount = 0;
      for (int i = gridSize - 1; i >= 0; i--) {
        if (grid[i][j].value == -1) {
          emptyCount++;
        } else if (emptyCount > 0) {
          grid[i + emptyCount][j].value = grid[i][j].value;
          grid[i][j].value = -1;
        }
      }

      for (int i = 0; i < emptyCount; i++) {
        grid[i][j].value = Random().nextInt(activeHeroes.length);
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
  }

  List<int> _getAffectedColumns() {
    Set<int> columns = {};
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].value == -1) {
          columns.add(j);
        }
      }
    }
    return columns.toList();
  }

  void resetGame() {
    // 1. Dừng các hoạt ảnh đang chạy (nếu có)
    confettiController.stop();
    isAnimating.value = false;

    // 2. Đặt lại điểm số và trạng thái khác
    score.value = 0;
    animationController.reset();
    animationController.forward();
    grid.clear();
    initializeHeroes();
    initializeGrid();

    update();
  }

  void refreshHeroes() {
    // Chỉ thay đổi hero trong lưới mà không reset trạng thái khác
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        grid[i][j].value = Random().nextInt(activeHeroes.length);
      }
    }
    initializeGrid();
    // Cập nhật giao diện
    update();
  }

  void _showGameOverDialog() {
    Get.defaultDialog(
      title: "Game Over",
      middleText: "No more valid moves!",
      textConfirm: "Restart",
      onConfirm: () {
        resetGame();
        Get.back();
      },
      textCancel: "Exit",
      onCancel: () {
        Get.back();
        // Logic thoát game nếu cần
      },
    );
  }
}
