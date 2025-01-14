import 'dart:math';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class MinesweeperController extends GetxController {
  late List<List<HexCell>> board;
  late int rows;
  late int columns;
  late int mineCount;
  var gameOver = false.obs;
  var gameWon = false.obs;

  final List<String> heroImages = listChampions;
  final String placeholderImage = ImagePath.girl;

  void initializeBoard(int rows, int columns, int mineCount) {
    this.rows = rows;
    this.columns = columns;
    this.mineCount = mineCount;

    // Khởi tạo bảng
    board = List.generate(
      rows,
      (row) => List.generate(columns, (col) {
        final randomImage = heroImages[Random().nextInt(heroImages.length)];
        return HexCell(row, col, image: randomImage);
      }),
    );

    // Đặt mìn
    _placeMines(mineCount);

    // Reset trạng thái trò chơi
    gameOver.value = false;
    gameWon.value = false;
    update();
  }

  void _placeMines(int mineCount) {
    final random = Random();
    int placedMines = 0;

    while (placedMines < mineCount) {
      int row = random.nextInt(rows);
      int col = random.nextInt(columns);

      if (!board[row][col].isMine) {
        board[row][col].isMine = true;
        placedMines++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!board[row][col].isMine) {
          board[row][col].adjacentMines = _countAdjacentMines(row, col);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (var delta in _hexNeighbors(row)) {
      int newRow = row + delta[0];
      int newCol = col + delta[1];
      if (_isValidCell(newRow, newCol) && board[newRow][newCol].isMine) {
        count++;
      }
    }
    return count;
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && col >= 0 && row < rows && col < columns;
  }

  List<List<int>> _hexNeighbors(int row) {
    // Các hướng di chuyển của ô lục giác
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
    if (!board[row][col].isRevealed && !gameOver.value) {
      board[row][col].isRevealed = true;

      if (board[row][col].isMine) {
        gameOver.value = true;
      } else if (board[row][col].adjacentMines == 0) {
        _revealAdjacentCells(row, col);
      } else {
        board[row][col].image = placeholderImage;
      }

      _checkWinCondition();
      update();
    }
  }

  void _revealAdjacentCells(int row, int col) {
    for (var delta in _hexNeighbors(row)) {
      int newRow = row + delta[0];
      int newCol = col + delta[1];
      if (_isValidCell(newRow, newCol) &&
          !board[newRow][newCol].isRevealed &&
          !board[newRow][newCol].isMine) {
        revealCell(newRow, newCol);
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (!board[row][col].isRevealed) {
      board[row][col].isFlagged = !board[row][col].isFlagged;
      update();
    }
  }

  void _checkWinCondition() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (!board[row][col].isMine && !board[row][col].isRevealed) {
          return; // Vẫn còn ô chưa mở
        }
      }
    }

    gameWon.value = true;
    gameOver.value = true;
  }
}

class HexCell {
  final int row;
  final int col;
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int adjacentMines = 0;
  String image;

  HexCell(this.row, this.col, {required this.image});
}
