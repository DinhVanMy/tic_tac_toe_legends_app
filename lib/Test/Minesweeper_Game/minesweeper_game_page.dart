import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Test/Minesweeper_Game/minesweeper_game_controller.dart';

class MinesweeperGame extends StatelessWidget {
  final MinesweeperController controller = Get.put(MinesweeperController());

  final int rows;
  final int columns;
  final double cellSize;

  MinesweeperGame({
    super.key,
    required this.rows,
    required this.columns,
    required this.cellSize,
  }) {
    controller.initializeBoard(rows, columns, 20); // Khởi tạo với 20 mìn
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: HexagonClipper(),
              child: Image.asset(
                GifsPath.androidGif,
                width: 50,
              ),
            ),
            Stack(
              children: [
                SizedBox(
                  width: (columns * 1.732 * cellSize) + (1.732 * cellSize / 2),
                  height: (rows * cellSize * 1.5),
                  child: CustomPaint(
                    painter: HexGridPainter(
                      rows: rows,
                      columns: columns,
                      cellSize: cellSize,
                      children: controller.board
                          .map(
                            (row) => row.map((cell) {
                              return GestureDetector(
                                onTap: () {
                                  controller.revealCell(cell.row, cell.col);
                                },
                                child: AnimatedOpacity(
                                  opacity: cell.isRevealed ? 1.0 : 0.5,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: !cell.isMine
                                          ? const DecorationImage(
                                              image: AssetImage(
                                                  ImagePath.background1),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: cell.isRevealed
                                        ? Text(
                                            cell.adjacentMines > 0
                                                ? '${cell.adjacentMines}'
                                                : '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                          .toList(),
                    ),
                  ),
                ),
                _buildGridInteractions(rows, columns, cellSize),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridInteractions(int rows, int columns, double cellSize) {
    final double gridWidth =
        (columns * 1.732 * cellSize) + (1.732 * cellSize / 2);
    final double gridHeight = (rows * cellSize * 1.5);

    return GestureDetector(
      onTapDown: (details) {
        final Offset localPosition = details.localPosition;
        final int? tappedCell =
            _getTappedHexCell(rows, columns, cellSize, localPosition);
        if (tappedCell != null) {
          controller.revealCell(tappedCell ~/ columns, tappedCell % columns);
        }
      },
      child: SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: Container(color: Colors.transparent), // Nền tương tác
      ),
    );
  }

  int? _getTappedHexCell(
      int rows, int columns, double cellSize, Offset position) {
    final double hexWidth = 1.732 * cellSize; // √3 * cellSize
    final double hexHeight = cellSize * 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final dx = col * hexWidth + (row % 2) * (hexWidth / 2);
        final dy = row * hexHeight * 0.75;

        final hexPath = HexGridPainter.createHexagonPath(dx, dy, cellSize);

        if (hexPath.contains(position)) {
          return row * columns + col;
        }
      }
    }
    return null;
  }
}

class HexGridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final double cellSize;
  final List<List<Widget>> children;

  HexGridPainter({
    required this.rows,
    required this.columns,
    required this.cellSize,
    required this.children,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final dx = col * 1.732 * cellSize + (row % 2) * (1.732 * cellSize / 2);
        final dy = row * cellSize * 1.5;
        final hexPath = createHexagonPath(dx, dy, cellSize);
        canvas.drawPath(hexPath, paint);
      }
    }
  }

  static Path createHexagonPath(double x, double y, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 180) * (60 * i - 30);
      final px = x + size * cos(angle);
      final py = y + size * sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path
      ..moveTo(size.width / 2, 0) // moving to topCenter 1st, then draw the path
      ..lineTo(size.width, size.height * .25)
      ..lineTo(size.width, size.height * .75)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .75)
      ..lineTo(0, size.height * .25)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
