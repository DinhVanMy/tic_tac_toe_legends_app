import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/General_Widgets/gaming_dialogs.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Minesweeper_Game/minesweeper_game_controller.dart';

class MinesweeperGame extends StatelessWidget {
  final String controllerTag = UniqueKey().toString(); // Lưu tag ở đây
  late final MinesweeperController controller; // Sẽ khởi tạo trong constructor
  final int rows;
  final int columns;
  final double cellSize;
  final GameLevel level;

  MinesweeperGame({
    super.key,
    required this.rows,
    required this.columns,
    required this.cellSize,
    required this.level,
  }) {
    controller = Get.put(MinesweeperController(),
        tag: controllerTag); // Gán controller với tag
    controller.initializeBoard(rows, columns, level);
  }

  @override
  Widget build(BuildContext context) {
    final double hexWidth = sqrt(3) * cellSize;
    final double hexHeight = 2 * cellSize;
    const TextStyle textStyleBig = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (!controller.gameOver.value) {
          final shouldExit = await showExitConfirmationDialog();
          if (shouldExit) {
            Get.delete<MinesweeperController>(tag: controllerTag);
            Get.back();
          }
        } else {
          Get.delete<MinesweeperController>(tag: controllerTag);
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(
          //   onPressed: () async {
          //     await Get.delete<MinesweeperController>().then((_) => Get.back());
          //   },
          //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
          // ),
          title: Text('Minesweeper Hex - ${level.name.capitalize}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.resetGame();
              },
              tooltip: 'Reset Game',
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Hiển thị bộ đếm thời gian
                Obx(() => Text(
                      TimeFunctions.getFormattedTime(controller.timeLeft.value),
                      style: textStyleBig,
                    )),
                const SizedBox(height: 10),
                // Thông báo game over hoặc thắng
                Obx(() {
                  if (controller.gameOver.value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.dialog(
                        AlertDialog(
                          title: Text(controller.gameWon.value
                              ? 'Bạn Thắng!'
                              : 'Game Over'),
                          content: Text(controller.gameWon.value
                              ? 'Chúc mừng bạn đã dò hết mìn!'
                              : controller.timeLeft.value <= 0
                                  ? 'Hết thời gian! Boom!'
                                  : 'Bạn đã chọn trúng hero cầm boom!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.resetGame();
                              },
                              child: const Text('Chơi lại'),
                            ),
                          ],
                        ),
                        barrierDismissible: false,
                      );
                    });
                  }
                  return const SizedBox.shrink();
                }),
                // Lưới lục giác
                Obx(() => SizedBox(
                      width: columns * hexWidth + hexWidth / 2,
                      height: rows * hexHeight * 0.75 + hexHeight / 4,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(
                              columns * hexWidth + hexWidth / 2,
                              rows * hexHeight * 0.75 + hexHeight / 4,
                            ),
                            painter: HexGridPainter(
                                rows: rows,
                                columns: columns,
                                cellSize: cellSize),
                          ),
                          for (int row = 0; row < rows; row++)
                            for (int col = 0; col < columns; col++)
                              Positioned(
                                left:
                                    col * hexWidth + (row % 2) * (hexWidth / 2),
                                top: row * (hexHeight * 0.75),
                                child: HexCellWidget(
                                  cell: controller.board[row][col],
                                  cellSize: cellSize,
                                ),
                              ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HexCellWidget extends StatelessWidget {
  final HexCell cell;
  final double cellSize;

  const HexCellWidget({super.key, required this.cell, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<MinesweeperController>().revealCell(cell.row, cell.col);
      },
      child: Obx(() => ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              width: sqrt(3) * cellSize,
              height: 2 * cellSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(cell.image.value),
                  fit: BoxFit.cover,
                ),
              ),
              child: cell.isRevealed.value &&
                      !cell.isMine.value &&
                      cell.adjacentMines.value > 0
                  ? Center(
                      child: Text(
                        '${cell.adjacentMines.value}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : null,
            ),
          )),
    );
  }
}

class HexGridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double cellSize;

  HexGridPainter({
    required this.rows,
    required this.columns,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double hexWidth = sqrt(3) * cellSize;
    final double hexHeight = 2 * cellSize;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final dx = col * hexWidth + (row % 2) * (hexWidth / 2);
        final dy = row * hexHeight * 0.75;
        final hexPath =
            _createHexagonPath(dx + hexWidth / 2, dy + hexHeight / 2, cellSize);
        canvas.drawPath(hexPath, paint);
      }
    }
  }

  Path _createHexagonPath(double centerX, double centerY, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - (pi / 6);
      final x = centerX + size * cos(angle);
      final y = centerY + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - (pi / 6);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Hàm giả lập TimeFunctions (bạn có thể thay bằng hàm thật của bạn)
class TimeFunctions {
  static String getFormattedTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
