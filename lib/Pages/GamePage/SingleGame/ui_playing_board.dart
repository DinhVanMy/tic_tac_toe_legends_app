import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_bot_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Widgets/core/line_painter.dart';

class UiPlayingBoard {
  Widget buildGameBoard(
      double width, PlayWithBotController controller, BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(3),
      strokeWidth: 5,
      dashPattern: const [10, 5],
      radius: const Radius.circular(20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(controller.selectedImagePath.value),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(5),
            width: width,
            height: width - 33,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(
              () {
                int gridSize = controller.board.length;

                return Stack(
                  children: [
                    InteractiveViewer(
                      panEnabled: true, // Cho phép kéo thả
                      scaleEnabled: true, // Cho phép phóng to, thu nhỏ
                      minScale: 0.0000000000001, // Tỷ lệ thu nhỏ tối thiểu
                      maxScale: 4.0, // Tỷ lệ phóng to tối đa
                      boundaryMargin: const EdgeInsets.all(
                          double.infinity), // Cho phép kéo ra ngoài biên
                      child: SizedBox(
                        width: gridSize * 50, // Adjust width based on grid size
                        height:
                            gridSize * 50, // Adjust height based on grid size
                        child: GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: gridSize * gridSize,
                          itemBuilder: (context, index) {
                            int row = index ~/ gridSize;
                            int col = index % gridSize;
                            bool isDisabled = controller.board[row][col] != '';
                            return InkWell(
                              onTap: isDisabled
                                  ? null
                                  : () async {
                                      controller.makeMove(
                                        controller.selectedDifficultyText.value,
                                        row,
                                        col,
                                      );
                                    },
                              child: Container(
                                margin: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  color: _getTileColor(
                                      controller, row, col, context),
                                  // borderRadius: _getBorderRadius(index, gridSize),
                                ),
                                child: Center(
                                  child: _buildTileContent(
                                    controller.board[row][col],
                                    context,
                                    controller,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (controller.winner.value != '')
                      CustomPaint(
                        painter: LinePainter(
                            controller.winningLineCoordinates,
                            gridSize,
                            controller.winner.value == 'X'
                                ? Colors.lightBlueAccent
                                : Colors.yellowAccent),
                        size: Size(gridSize * 50, gridSize * 50),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(PlayWithBotController controller, int row, int col,
      BuildContext context) {
    String value = controller.board[row][col];
    if (value == "X") {
      return Theme.of(context).colorScheme.primary.withOpacity(0.3);
    } else if (value == "O") {
      return Theme.of(context).colorScheme.secondary.withOpacity(0.3);
    } else {
      return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6);
    }
  }

  BorderRadius getBorderRadius(int index, int length) {
    if (index == 0) {
      return const BorderRadius.only(topLeft: Radius.circular(20));
    } else if (index == length - 1) {
      return const BorderRadius.only(topRight: Radius.circular(20));
    } else if (index == length * (length - 1)) {
      return const BorderRadius.only(bottomLeft: Radius.circular(20));
    } else if (index == length * length - 1) {
      return const BorderRadius.only(bottomRight: Radius.circular(20));
    } else {
      return const BorderRadius.only();
    }
  }

  Widget _buildTileContent(
      String value, BuildContext context, PlayWithBotController controller) {
    if (value == "X") {
      return Image.asset(controller.selectedImageX.value);
    } else if (value == "O") {
      return Image.asset(controller.selectedImageO.value);
    } else {
      return const SizedBox();
    }
  }

  Widget buildTurnIndicator(
      ColorScheme colorScheme, PlayWithBotController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            decoration: BoxDecoration(
              color: controller.isXtime.value
                  ? colorScheme.primary
                  : colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  controller.isXtime.value
                      ? controller.selectedImageX.value
                      : controller.selectedImageO.value,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                Text(
                  "Turn",
                  style: TextStyle(
                    fontSize: 25,
                    color: colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
