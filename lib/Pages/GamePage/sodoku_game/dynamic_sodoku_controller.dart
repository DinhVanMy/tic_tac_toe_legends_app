import 'dart:math';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class Sudoku {
  final List<int> puzzle;
  final List<int> solution;

  Sudoku({required this.puzzle, required this.solution});

  static Sudoku generate(Levels level, {int size = 9}) {
    final totalCells = size * size;

    // Bảng hoàn chỉnh (giải pháp)
    List<int> solution = List.filled(totalCells, -1);
    _fillGrid(solution, size);

    // Bảng bị xóa ô (dựa theo độ khó)
    List<int> puzzle = List.of(solution);
    _removeCellsForDifficulty(puzzle, level, size);

    return Sudoku(puzzle: puzzle, solution: solution);
  }

  // Điền các số hợp lệ vào bảng
  static void _fillGrid(List<int> grid, int size, {int maxRetries = 5}) {
    final helper = SudokuHelper(size);
    int subgridSize = sqrt(size).toInt();

    if (subgridSize * subgridSize != size) {
      throw Exception('Kích thước không hợp lệ: $size');
    }

    for (int i = 0; i < grid.length; i++) {
      grid[i] = -1; // Đặt giá trị ban đầu
    }

    if (!_solve(grid, size, subgridSize, helper)) {
      if (maxRetries > 0) {
        _fillGrid(grid, size, maxRetries: maxRetries - 1);
      } else {
        throw Exception('Không thể tạo bảng sau nhiều lần thử.');
      }
    }
  }

  static void _fillSubgrid(
      List<int> grid, int startRow, int startCol, int size, int subgridSize) {
    final random = Random();
    List<int> numbers = List.generate(size, (index) => index + 1)
      ..shuffle(random);

    for (int row = 0; row < subgridSize; row++) {
      for (int col = 0; col < subgridSize; col++) {
        int calculatedIndex = (startRow + row) * size + (startCol + col);

        bool numberPlaced = false;
        for (int num in numbers) {
          if (_isValid(
              grid, startRow + row, startCol + col, num, size, subgridSize)) {
            grid[calculatedIndex] = num;
            numbers.remove(num);
            numberPlaced = true;
            break;
          }
        }

        // Nếu không thể đặt số, khởi động lại subgrid này.
        if (!numberPlaced) {
          grid.fillRange(0, grid.length, -1);
          return;
        }
      }
    }
  }

  // Backtracking để điền số hợp lệ vào bảng
  static bool _solve(
      List<int> grid, int size, int subgridSize, SudokuHelper helper) {
    int emptyIndex = grid.indexOf(-1);
    if (emptyIndex == -1) return true;

    int row = emptyIndex ~/ size;
    int col = emptyIndex % size;
    int subgrid = (row ~/ subgridSize) * subgridSize + (col ~/ subgridSize);

    for (int num = 1; num <= size; num++) {
      if (!helper.rows[row].contains(num) &&
          !helper.cols[col].contains(num) &&
          !helper.subgrids[subgrid].contains(num)) {
        grid[emptyIndex] = num;
        helper.rows[row].add(num);
        helper.cols[col].add(num);
        helper.subgrids[subgrid].add(num);

        if (_solve(grid, size, subgridSize, helper)) return true;

        // Quay lui
        grid[emptyIndex] = -1;
        helper.rows[row].remove(num);
        helper.cols[col].remove(num);
        helper.subgrids[subgrid].remove(num);
      }
    }

    return false;
  }

  static bool _isValid(
      List<int> grid, int row, int col, int num, int size, int subgridSize) {
    // Kiểm tra hàng.
    for (int c = 0; c < size; c++) {
      if (grid[row * size + c] == num) {
        return false;
      }
    }

    // Kiểm tra cột.
    for (int r = 0; r < size; r++) {
      if (grid[r * size + col] == num) {
        return false;
      }
    }

    // Kiểm tra subgrid.
    int startRow = (row ~/ subgridSize) * subgridSize;
    int startCol = (col ~/ subgridSize) * subgridSize;

    for (int r = 0; r < subgridSize; r++) {
      for (int c = 0; c < subgridSize; c++) {
        if (grid[(startRow + r) * size + (startCol + c)] == num) {
          return false;
        }
      }
    }

    return true;
  }

  // Xóa các ô khỏi bảng dựa theo độ khó
  static void _removeCellsForDifficulty(
      List<int> grid, Levels level, int size) {
    final random = Random();
    int totalCells = grid.length;

    // Số ô cần xóa dựa vào cấp độ khó
    int cellsToRemove = (totalCells * _difficultyFactor(level)).toInt();

    for (int i = 0; i < cellsToRemove; i++) {
      int index;
      do {
        index = random.nextInt(totalCells);
      } while (grid[index] == -1); // Đảm bảo ô chưa bị xóa

      grid[index] = -1; // Xóa ô
    }
  }

  // Hệ số dựa trên độ khó
  static double _difficultyFactor(Levels level) {
    switch (level) {
      case Levels.easy:
        return 0.4; // 40% ô bị xóa
      case Levels.medium:
        return 0.6; // 60% ô bị xóa
      case Levels.hard:
        return 0.75; // 75% ô bị xóa
      case Levels.expert:
        return 0.85;
      default:
        return 0.5; // Mặc định trung bình
    }
  }
}

// Định nghĩa các cấp độ khó
enum Levels { easy, medium, hard, expert }

class SudokuGamePlayController extends GetxController {
  // Các biến trạng thái
  RxList<int> puzzle = <int>[].obs;
  RxList<int> solution = <int>[].obs;
  RxBool isSolved = false.obs;
  RxList<String> selectedHeroes = <String>[].obs; // Danh sách hero được chọn
  var selectedHeroIndex = (-1).obs;

  RxList<List<int>> undoStack = RxList(); // Stack cho Undo
  RxList<List<int>> redoStack = RxList(); // Stack cho Redo

  // Cấu hình bảng
  final Levels selectedLevel; // Độ khó
  final int size; // Kích thước bảng (vd: 9, 11, 13)
  SudokuGamePlayController({required this.selectedLevel, required this.size});

  @override
  void onInit() {
    super.onInit();
    generateNewGame();
    ever(puzzle,
        (_) => checkCompletion()); // Kiểm tra hoàn thành khi bảng thay đổi
  }

  // Tạo game mới
  void generateNewGame() {
    Sudoku sudoku = Sudoku.generate(selectedLevel, size: size);

    puzzle.value = sudoku.puzzle;
    solution.value = sudoku.solution;

    // Chọn hero ngẫu nhiên tương ứng với kích thước bảng
    selectedHeroes.value = _getRandomHeroes(size);
    isSolved.value = false;
  }

  // Chọn ngẫu nhiên danh sách hero
  List<String> _getRandomHeroes(int count) {
    final random = Random();
    final shuffled = List.of(listChampions)..shuffle(random);
    return shuffled.take(count).toList(); // Chọn số lượng hero tương ứng
  }

  // Điền số vào ô
  void updateCell(int index, int number) {
    undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào Undo
    redoStack.clear(); // Xóa redo stack sau mỗi thay đổi
    puzzle[index] = number;
  }

  // Undo thao tác
  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào Redo
      puzzle.value = undoStack.removeLast();
    }
  }

  // Redo thao tác
  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào Undo
      puzzle.value = redoStack.removeLast();
    }
  }

  // Kiểm tra hoàn thành
  void checkCompletion() {
    isSolved.value = _isPuzzleSolved();
    if (isSolved.value) {
      successMessage('Congratulation! You solved the Sudoku!');
    }
  }

  bool _isPuzzleSolved() {
    for (int i = 0; i < puzzle.length; i++) {
      if (puzzle[i] != solution[i]) return false;
    }

    // Kiểm tra thêm tính hợp lệ của hàng, cột, subgrid
    int subgridSize = sqrt(size).toInt();
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        int num = puzzle[row * size + col];
        if (!Sudoku._isValid(puzzle, row, col, num, size, subgridSize)) {
          return false;
        }
      }
    }

    return true;
  }

  // Giải toàn bộ bảng
  void solveSudoku() {
    if (!_isPuzzleSolved()) {
      undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại.
      puzzle.value = List.of(solution); // Điền toàn bộ đáp án.
      isSolved.value = true;
    }
  }

  // Điền gợi ý cho một ô
  void hintForSpecify(int index) {
    if (puzzle[index] == -1) {
      undoStack.add(List.of(puzzle)); // Lưu trạng thái trước khi gợi ý.
      puzzle[index] = solution[index]; // Điền đáp án đúng.
    }
    Get.back();
  }

  // Điền gợi ý cho một ô
  void hintForRandom() {
    // Tìm vị trí đầu tiên còn trống trong bảng (giá trị -1)
    int index = puzzle.indexWhere((value) => value == -1);

    // Nếu còn ô trống, cung cấp gợi ý
    if (index != -1) {
      undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào Undo stack
      puzzle[index] = solution[index]; // Điền số đúng từ solution vào puzzle
    } else {
      // Nếu không còn ô trống
      errorMessage('No empty cells available for hints!');
    }
  }

  // Đặt lại bảng
  void resetGame() {
    generateNewGame();
    undoStack.clear();
    redoStack.clear();
  }
}

class SudokuHelper {
  final List<Set<int>> rows;
  final List<Set<int>> cols;
  final List<Set<int>> subgrids;

  SudokuHelper(int size)
      : rows = List.generate(size, (_) => <int>{}),
        cols = List.generate(size, (_) => <int>{}),
        subgrids = List.generate(size, (_) => <int>{});
}
