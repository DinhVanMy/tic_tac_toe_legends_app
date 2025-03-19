// import 'dart:async';
// import 'dart:math';
// import 'package:get/get.dart';

// class NumberMergeController extends GetxController {
//   late GameBoardModel gameBoard;
//   RxInt score = 0.obs;
//   Rx<BlockModel?> nextBlock = Rx<BlockModel?>(null); // Khối tiếp theo
//   RxInt currentColumn = 0.obs; // Cột hiện tại block đang ở
//   RxDouble blockPositionY = 0.0.obs; // Vị trí Y của block khi rơi
//   List<List<RxList<Rx<BlockModel?>>>> previousState = []; // Sửa kiểu dữ liệu
//   RxBool isDragging = false.obs; // Trạng thái kéo block
//   RxBool isPaused = false.obs; // Trạng thái tạm dừng
//   Timer? dropTimer; // Timer để điều khiển tốc độ rơi

//   // Các thông số từ tham số
//   late int rows;
//   late int columns;
//   late int level;
//   double containerHeight = 500.0;

//   // Tốc độ rơi theo level (pixel mỗi frame)
//   final Map<int, double> levelSpeeds = {
//     1: 2.0, // Chậm
//     2: 4.0, // Trung bình
//     3: 6.0, // Nhanh
//   };

//   NumberMergeController({
//     required this.rows,
//     required this.columns,
//     required this.level,
//   }) {
//     rows = rows.clamp(3, 10);
//     columns = columns.clamp(3, 7);
//     level = level.clamp(1, 3);
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeGame();
//     _startBlockDrop();
//   }

//   void _initializeGame() {
//     gameBoard = GameBoardModel(rows: rows, columns: columns);
//     currentColumn.value = columns ~/ 2;
//     score.value = 0; // Reset điểm
//     previousState.clear(); // Reset trạng thái undo
//     _generateNextBlock();
//   }

//   void _generateNextBlock() {
//     int value = [2, 4, 8, 16][Random().nextInt(4)];
//     nextBlock.value = BlockModel(value: value);
//     blockPositionY.value = 0.0;
//     currentColumn.value = columns ~/ 2;
//     isDragging.value = false;
//   }

//   void _startBlockDrop() {
//     dropTimer?.cancel();
//     double speed = levelSpeeds[level] ?? 2.0;
//     dropTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (!isDragging.value && !isPaused.value) {
//         blockPositionY.value += speed;
//         if (blockPositionY.value >= containerHeight - 70) {
//           _placeBlock();
//           timer.cancel();
//         }
//       }
//     });
//   }

//   void dragBlock(int newColumn) {
//     if (newColumn >= 0 && newColumn < columns) {
//       currentColumn.value = newColumn;
//       isDragging.value = true;
//     }
//   }

//   void releaseBlock() {
//     isDragging.value = false;
//     _placeBlock();
//   }

//   void tapToDrop(int columnIndex) {
//     currentColumn.value = columnIndex;
//     blockPositionY.value = containerHeight - 70;
//     _placeBlock();
//   }

//   void _placeBlock() {
//     savePreviousState();
//     int col = currentColumn.value;
//     int targetRow = -1;

//     for (int row = 0; row < rows; row++) {
//       if (gameBoard.grid[row][col].value == null) {
//         targetRow = row;
//         break;
//       }
//     }

//     if (targetRow != -1) {
//       gameBoard.grid[targetRow][col].value = nextBlock.value;

//       if (targetRow > 0) {
//         Rx<BlockModel?> currentBlock = gameBoard.grid[targetRow][col];
//         Rx<BlockModel?> belowBlock = gameBoard.grid[targetRow - 1][col];
//         if (belowBlock.value != null && belowBlock.value!.value == currentBlock.value!.value) {
//           belowBlock.value!.value *= 2;
//           gameBoard.grid[targetRow][col].value = null;
//           _mergeBlocks(targetRow - 1, col);
//         } else {
//           _mergeBlocks(targetRow, col);
//         }
//       } else {
//         _mergeBlocks(targetRow, col);
//       }

//       _generateNextBlock();
//       _startBlockDrop();
//     } else if (isGameOver()) {
//       Get.snackbar("Game Over", "No more moves!");
//     }
//   }

//   void _mergeBlocks(int row, int col, {int comboMultiplier = 1}) {
//     Rx<BlockModel?> currentBlock = gameBoard.grid[row][col];
//     if (currentBlock.value == null) return;

//     if (row < rows - 1) {
//       Rx<BlockModel?> aboveBlock = gameBoard.grid[row + 1][col];
//       if (aboveBlock.value != null && aboveBlock.value!.value == currentBlock.value!.value) {
//         currentBlock.value!.value *= 2;
//         aboveBlock.value = null;
//         score.value += currentBlock.value!.value * comboMultiplier;
//         _mergeBlocks(row, col, comboMultiplier: comboMultiplier + 1);
//       }
//     }
//   }

//   bool isGameOver() {
//     for (int col = 0; col < columns; col++) {
//       if (gameBoard.grid[rows - 1][col].value != null) return true;
//     }
//     return false;
//   }

//   void savePreviousState() {
//     // Tạo một bản sao của grid hiện tại
//     final currentState = gameBoard.grid.map((row) {
//       return RxList(row.map((block) {
//         return block.value != null
//             ? Rx<BlockModel?>(BlockModel(value: block.value!.value))
//             : Rx<BlockModel?>(null);
//       }).toList());
//     }).toList();
//     previousState.add(currentState); // Thêm bản sao vào previousState
//     if (previousState.length > 1) previousState.removeAt(0); // Giữ tối đa 1 trạng thái
//   }

//   void undoMove() {
//     if (previousState.isNotEmpty && !isPaused.value) {
//       dropTimer?.cancel(); // Dừng block đang rơi
//       for (int row = 0; row < rows; row++) {
//         for (int col = 0; col < columns; col++) {
//           // Gán giá trị .value thay vì cả Rx<BlockModel?>
//           gameBoard.grid[row][col].value = previousState.last[row][col].value;
//         }
//       }
//       previousState.clear();
//       blockPositionY.value = 0.0; // Reset vị trí block
//       _startBlockDrop(); // Tiếp tục rơi
//     }
//   }

//   void togglePause() {
//     isPaused.value = !isPaused.value;
//     if (!isPaused.value) _startBlockDrop();
//   }

//   void refreshGame() {
//     dropTimer?.cancel();
//     _initializeGame();
//     _startBlockDrop();
//   }

//   @override
//   void onClose() {
//     dropTimer?.cancel();
//     super.onClose();
//   }
// }

// class BlockModel {
//   int value;
//   BlockModel({required this.value});
// }

// class GameBoardModel {
//   List<RxList<Rx<BlockModel?>>> grid;
//   int rows;
//   int columns;

//   GameBoardModel({required this.rows, required this.columns})
//       : grid = List.generate(rows, (_) => List.generate(columns, (_) => Rx<BlockModel?>(null)).obs);
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'number_merge_controller.dart';

// class NumberMergeGame extends StatelessWidget {
//   final int rows;
//   final int columns;
//   final int level;

//   const NumberMergeGame({
//     super.key,
//     required this.rows,
//     required this.columns,
//     required this.level,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final NumberMergeController controller = Get.put(NumberMergeController(
//       rows: rows,
//       columns: columns,
//       level: level,
//     ));
//     const TextStyle textStyle = TextStyle(
//       color: Colors.black,
//       fontFamily: "Orbitron",
//       fontWeight: FontWeight.bold,
//       fontSize: 20,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30, color: Colors.blue),
//         ),
//         title: Column(
//           children: [
//             const Text("Number Merge", style: textStyle),
//             Obx(() => Text("Score: ${controller.score.value}", style: textStyle.copyWith(fontSize: 15))),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.rotate_left_rounded, size: 30, color: Colors.white),
//             onPressed: controller.undoMove,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded, size: 30, color: Colors.white),
//             onPressed: controller.refreshGame,
//           ),
//           IconButton(
//             icon: Obx(() => Icon(
//                   controller.isPaused.value ? Icons.play_arrow_rounded : Icons.pause_rounded,
//                   size: 30,
//                   color: Colors.white,
//                 )),
//             onPressed: controller.togglePause,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: 500,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.blueGrey,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.black, width: 5),
//                 ),
//                 child: Stack(
//                   children: [
//                     Row(
//                       children: List.generate(controller.columns, (col) {
//                         return Expanded(
//                           child: GestureDetector(
//                             onTap: () => controller.tapToDrop(col),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black),
//                                 color: Colors.grey[200],
//                               ),
//                               child: Obx(() => Stack(
//                                     children: List.generate(controller.rows, (row) {
//                                       final block = controller.gameBoard.grid[row][col].value;
//                                       return Positioned(
//                                         top: (controller.rows - 1 - row) * (500 / controller.rows),
//                                         child: Container(
//                                           height: 500 / controller.rows,
//                                           width: MediaQuery.of(context).size.width / controller.columns,
//                                           decoration: BoxDecoration(
//                                             color: block != null ? Colors.blueAccent : Colors.transparent,
//                                             border: Border.all(color: Colors.black),
//                                           ),
//                                           child: Center(
//                                             child: Text(
//                                               block?.value.toString() ?? "",
//                                               style: textStyle.copyWith(color: Colors.white),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     }),
//                                   )),
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                     Obx(() {
//                       return Positioned(
//                         top: controller.blockPositionY.value,
//                         left: (MediaQuery.of(context).size.width / controller.columns) * controller.currentColumn.value,
//                         child: GestureDetector(
//                           onHorizontalDragUpdate: (details) {
//                             int newColumn = (details.globalPosition.dx / (MediaQuery.of(context).size.width / controller.columns)).floor();
//                             controller.dragBlock(newColumn);
//                           },
//                           onHorizontalDragEnd: (_) => controller.releaseBlock(),
//                           child: Container(
//                             height: 500 / controller.rows,
//                             width: MediaQuery.of(context).size.width / controller.columns,
//                             decoration: BoxDecoration(
//                               color: Colors.blueAccent,
//                               border: Border.all(color: Colors.black),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "${controller.nextBlock.value?.value ?? ""}",
//                                 style: textStyle.copyWith(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//               Obx(() => Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text("Next: ${controller.nextBlock.value?.value ?? ""}", style: textStyle),
//                   )),
//             ],
//           ),
//           // Overlay khi tạm dừng
//           Obx(() {
//             return controller.isPaused.value
//                 ? Container(
//                     color: Colors.black54,
//                     child: Center(
//                       child: Text(
//                         "Paused",
//                         style: textStyle.copyWith(fontSize: 40, color: Colors.white),
//                       ),
//                     ),
//                   )
//                 : const SizedBox.shrink();
//           }),
//         ],
//       ),
//     );
//   }
// }