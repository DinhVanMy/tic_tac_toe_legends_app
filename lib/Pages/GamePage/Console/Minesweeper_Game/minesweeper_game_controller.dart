import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';

class MinesweeperController extends GetxController {
  RxList<List<HexCell>> board = RxList<List<HexCell>>();
  late int rows;
  late int columns;
  late int mineCount;
  late GameLevel level;
  var gameOver = false.obs;
  var gameWon = false.obs;
  RxInt timeLeft = 0.obs; // Thời gian còn lại (giây)
  Timer? _timer;

  final List<String> heroImages = listChampions;
  final String placeholderImage = ImagePath.background1;

  void initializeBoard(int rows, int columns, GameLevel level) {
    this.rows = rows;
    this.columns = columns;
    this.level = level;
    mineCount = levelConfigs[level]!.mineCount;
    timeLeft.value = levelConfigs[level]!.timeLimit;
    _resetBoard();
    _startTimer();
  }

  void _resetBoard() {
    board.value = List.generate(
      rows,
      (row) => List.generate(columns, (col) {
        final randomImage = heroImages[Random().nextInt(heroImages.length)];
        return HexCell(row, col, image: randomImage);
      }),
    );

    _placeMines(mineCount);
    _calculateAdjacentMines();

    gameOver.value = false;
    gameWon.value = false;
    board.refresh();
  }

  void resetGame() {
    _stopTimer();
    timeLeft.value = levelConfigs[level]!.timeLimit;
    _resetBoard();
    _startTimer();
  }

  void _startTimer() {
    _stopTimer(); // Hủy timer cũ trước khi tạo mới
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameOver.value && timeLeft.value > 0) {
        timeLeft.value--;
      } else if (timeLeft.value <= 0) {
        timer.cancel(); // Hủy timer từ chính callback
        gameOver.value = true;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null; // Đặt lại null để tránh tham chiếu cũ
  }

  void _placeMines(int mineCount) {
    final random = Random();
    int placedMines = 0;

    while (placedMines < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(columns);

      if (!board[row][col].isMine.value) {
        board[row][col].isMine.value = true;
        placedMines++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!board[row][col].isMine.value) {
          board[row][col].adjacentMines.value = _countAdjacentMines(row, col);
        } else {
          board[row][col].adjacentMines.value = 0;
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (var delta in _hexNeighbors(row)) {
      int newRow = row + delta[0];
      int newCol = col + delta[1];
      if (_isValidCell(newRow, newCol) && board[newRow][newCol].isMine.value) {
        count++;
      }
    }
    return count;
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && col >= 0 && row < rows && col < columns;
  }

  List<List<int>> _hexNeighbors(int row) {
    if (row % 2 == 0) {
      return [
        [-1, 0],
        [-1, 1],
        [0, -1],
        [0, 1],
        [1, 0],
        [1, 1],
      ];
    } else {
      return [
        [-1, -1],
        [-1, 0],
        [0, -1],
        [0, 1],
        [1, -1],
        [1, 0],
      ];
    }
  }

  void revealCell(int row, int col) {
    if (!board[row][col].isRevealed.value && !gameOver.value) {
      board[row][col].isRevealed.value = true;

      if (board[row][col].isMine.value) {
        gameOver.value = true;
        _stopTimer();
      } else {
        board[row][col].image.value = placeholderImage;
        if (board[row][col].adjacentMines.value == 0) {
          _revealAdjacentCells(row, col);
        }
      }

      _checkWinCondition();
    }
  }

  void _revealAdjacentCells(int row, int col) {
    for (var delta in _hexNeighbors(row)) {
      int newRow = row + delta[0];
      int newCol = col + delta[1];
      if (_isValidCell(newRow, newCol) &&
          !board[newRow][newCol].isRevealed.value &&
          !board[newRow][newCol].isMine.value) {
        revealCell(newRow, newCol);
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (!board[row][col].isRevealed.value && !gameOver.value) {
      board[row][col].isFlagged.value = !board[row][col].isFlagged.value;
    }
  }

  void _checkWinCondition() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!board[row][col].isMine.value &&
            !board[row][col].isRevealed.value) {
          return;
        }
      }
    }
    gameWon.value = true;
    gameOver.value = true;
    _stopTimer();
    _awardCoins();
  }

  void _awardCoins() {
    int coinsEarned;
    switch (level) {
      case GameLevel.easy:
        coinsEarned = 10;
        break;
      case GameLevel.medium:
        coinsEarned = 20;
        break;
      case GameLevel.hard:
        coinsEarned = 30;
        break;
      case GameLevel.extreme:
        coinsEarned = 50;
        break;
      case GameLevel.legendary:
        coinsEarned = 100;
        break;
    }
    Get.find<FirestoreController>().incrementCoinsAndWins(coinsEarned);
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }
}

class HexCell {
  final int row;
  final int col;
  final RxBool isMine = false.obs;
  final RxBool isRevealed = false.obs;
  final RxBool isFlagged = false.obs;
  final RxInt adjacentMines = 0.obs;
  RxString image;

  HexCell(this.row, this.col, {required String image}) : image = image.obs;
}

enum GameLevel {
  easy,
  medium,
  hard,
  extreme,
  legendary,
}

class LevelConfig {
  final int mineCount;
  final int timeLimit; // Thời gian giới hạn tính bằng giây

  LevelConfig(this.mineCount, this.timeLimit);
}

final Map<GameLevel, LevelConfig> levelConfigs = {
  GameLevel.easy: LevelConfig(10, 300), // 10 mìn, 5 phút
  GameLevel.medium: LevelConfig(20, 240), // 20 mìn, 4 phút
  GameLevel.hard: LevelConfig(30, 180), // 30 mìn, 3 phút
  GameLevel.extreme: LevelConfig(50, 120), // 50 mìn, 2 phút
  GameLevel.legendary: LevelConfig(80, 60), // 80 mìn, 1 phút
};
