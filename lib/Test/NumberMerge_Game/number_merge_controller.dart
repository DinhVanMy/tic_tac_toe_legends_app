import 'dart:math';
import 'package:get/get.dart';

class NumberMergeController extends GetxController {
  late GameBoardModel gameBoard;
  RxInt score = 0.obs;
  Rx<BlockModel?> nextBlock = Rx<BlockModel?>(null); // Khối tiếp theo
  List<RxList<Rx<BlockModel?>>> previousState = [];

  int rows = 7; // Số hàng
  int columns = 5; // Số cột

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  void _initializeGame() {
    gameBoard = GameBoardModel(rows: rows, columns: columns);
    _generateNextBlock();
  }

  void _generateNextBlock() {
    int value =
        (List.generate(4, (index) => (1 << (index + 1))))[Random().nextInt(4)];
    nextBlock.value = BlockModel(value: value);
  }

  bool dropBlock(int columnIndex) {
    // Lưu trạng thái trước khi thay đổi (undo)
    savePreviousState();

    // Tìm hàng trống trong cột đã chọn
    for (int row = rows - 1; row >= 0; row--) {
      if (gameBoard.grid[row][columnIndex].value == null) {
        gameBoard.grid[row][columnIndex].value = nextBlock.value;
        _mergeBlocks(row, columnIndex);
        _generateNextBlock();
        return true;
      }
    }

    // Nếu không thể thả (cột đầy)
    return false;
  }

  void _mergeBlocks(int row, int col, {int comboMultiplier = 1}) {
    Rx<BlockModel?> currentBlock = gameBoard.grid[row][col];
    if (currentBlock.value == null) return;

    List<List<int>> directions = [
      [-1, 0], // Lên
      [1, 0], // Xuống
      [0, -1], // Trái
      [0, 1], // Phải
    ];

    for (var dir in directions) {
      int newRow = row + dir[0];
      int newCol = col + dir[1];

      if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < columns) {
        Rx<BlockModel?> adjacentBlock = gameBoard.grid[newRow][newCol];

        // Kiểm tra null và giá trị của adjacentBlock
        if (adjacentBlock.value != null &&
            adjacentBlock.value!.value == currentBlock.value!.value) {
          // Hợp nhất khối
          currentBlock.value!.value *= 2;
          adjacentBlock.value = null;

          // Cộng điểm
          score.value += currentBlock.value!.value * comboMultiplier;

          // Tiếp tục kiểm tra combo
          _mergeBlocks(newRow, newCol, comboMultiplier: comboMultiplier + 1);
        }
      }
    }
  }

  bool isGameOver() {
    // Kiểm tra cột đầy
    for (int col = 0; col < columns; col++) {
      if (gameBoard.grid[0][col].value == null) return false;
    }

    // Kiểm tra các cặp khối có thể hợp nhất
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        Rx<BlockModel?> current = gameBoard.grid[row][col];
        if (current.value == null) continue;

        // Kiểm tra cặp khối có thể hợp nhất
        for (var dir in [
          [1, 0], // Kiểm tra xuống dưới
          [0, 1], // Kiểm tra sang phải
        ]) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];
          if (newRow < rows &&
              newCol < columns &&
              gameBoard.grid[newRow][newCol].value?.value ==
                  current.value?.value) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void savePreviousState() {
    // Lưu trạng thái trước đó để Undo
    previousState = gameBoard.grid.map((row) {
      // Sao chép từng RxList bằng cách tạo một RxList mới
      return RxList(row
          .map((block) => block.value != null
              ? Rx<BlockModel?>(BlockModel(value: block.value!.value))
              : Rx<BlockModel?>(null))
          .toList());
    }).toList();
  }

  void undoMove() {
    if (previousState.isNotEmpty) {
      // Khôi phục trạng thái từ previousState
      for (int row = 0; row < gameBoard.grid.length; row++) {
        for (int col = 0; col < gameBoard.grid[row].length; col++) {
          gameBoard.grid[row][col] = previousState[row][col];
        }
      }
      // Xóa trạng thái trước đó sau khi khôi phục
      previousState.clear();
    }
  }
}

class BlockModel {
  int value;
  bool isMerging; // Để xác định khối đang trong quá trình sáp nhập

  BlockModel({required this.value, this.isMerging = false});
}

class GameBoardModel {
  List<RxList<Rx<BlockModel?>>> grid; // Lưới chơi (danh sách 2D)
  int rows; // Số hàng
  int columns; // Số cột

  GameBoardModel({required this.rows, required this.columns})
      : grid = List.generate(
          rows,
          (_) => List.generate(columns, (_) => Rx<BlockModel?>(null)).obs,
        );
}
