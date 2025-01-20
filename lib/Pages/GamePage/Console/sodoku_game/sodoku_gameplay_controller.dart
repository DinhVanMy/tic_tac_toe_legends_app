// import 'dart:math';
// import 'package:get/get.dart';
// import 'package:sudoku_dart/sudoku_dart.dart';
// import 'package:tictactoe_gameapp/Configs/constants.dart';
// import 'package:tictactoe_gameapp/Configs/messages.dart';

// class SudokuController extends GetxController {
//   RxList<int> puzzle = RxList.filled(81, -1);
//   RxList<int> solution = RxList.filled(81, -1);
//   RxBool isSolved = false.obs;
//   RxList<String> selectedHeroes =
//       <String>[].obs; // Danh sách hero được chọn ngẫu nhiên
//   var selectedHeroIndex = (-1).obs;
//   RxList<List<int>> undoStack = RxList();
//   RxList<List<int>> redoStack = RxList();

//   final Level selectedLevel;
//   SudokuController({required this.selectedLevel});

//   @override
//   void onInit() {
//     super.onInit();
//     generateNewGame(selectedLevel);
//     ever(puzzle, (_) => checkCompletion());
//   }

//   void generateNewGame(Level level) {
//     // Tạo Sudoku
//     Sudoku sudoku = Sudoku.generate(level);
//     puzzle.value = sudoku.puzzle;
//     solution.value = sudoku.solution;

//     // Chọn 9 hero ngẫu nhiên từ danh sách
//     selectedHeroes.value = _getRandomHeroes(9);
//     isSolved.value = false;
//   }

//   List<String> _getRandomHeroes(int count) {
//     final random = Random();
//     final shuffled = List.of(listChampions)..shuffle(random);
//     return shuffled.take(count).toList();
//   }

//   void solveSudoku() {
//     puzzle.value = solution;
//     isSolved.value = true;
//   }

//   void updateCell(int index, int number) {
//     undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào undo
//     redoStack.clear(); // Xóa redo stack sau mỗi thay đổi
//     puzzle[index] = number;
//     // checkCompletion();
//   }

//   void undo() {
//     if (undoStack.isNotEmpty) {
//       redoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào redo
//       puzzle.value = undoStack.removeLast();
//       // checkCompletion();
//     }
//   }

//   void redo() {
//     if (redoStack.isNotEmpty) {
//       undoStack.add(List.of(puzzle)); // Lưu trạng thái hiện tại vào undo
//       puzzle.value = redoStack.removeLast();
//       // checkCompletion();
//     }
//   }

//   void checkCompletion() {
//     isSolved.value = _isPuzzleSolved();
//     if (isSolved.value) {
//       successMessage('Congratulation, You solved the Sudoku!');
//     }
//   }

//   bool _isPuzzleSolved() {
//     for (int i = 0; i < 81; i++) {
//       if (puzzle[i] != solution[i]) return false;
//     }
//     return true;
//   }

//   void hint(int index) {
//     puzzle[index] = solution[index]; // Điền số đúng vào ô
//   }
// }
