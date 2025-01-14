import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Widgets/core/line_painter.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_player_controller.dart';

class UiPlayingMultiPlayerBoard {
  Widget buildGameBoard(
    double width,
    PlayWithPlayerController controller,
    BuildContext context,
    String roomId,
    RoomModel roomData,
    int gridSize,
    UserModel user,
  ) {
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
            child: Image.asset(roomData.pickedMap!),
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
            child: Stack(
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.0000000000001,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: SizedBox(
                    width: gridSize * 50,
                    height: gridSize * 50,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        int row = index ~/ gridSize;
                        int col = index % gridSize;
                        // Xác định xem người chơi là player1 hay player2
                        bool isPlayer1 = (roomData.player1 != null
                                ? roomData.player1!.email
                                : "") ==
                            user.email;
                        bool isPlayer2 = (roomData.player2 != null
                                ? roomData.player2!.email
                                : "") ==
                            user.email;
                        bool isPlayerTurn = (controller.isXtime.value &&
                                roomData.isXturn! &&
                                isPlayer1) ||
                            (!controller.isXtime.value &&
                                !roomData.isXturn! &&
                                isPlayer2);
                        bool isDisabled =
                            controller.board[row][col] != '' || !isPlayerTurn;
                        return InkWell(
                          onTap: () async {
                            if (!isDisabled) {
                              await controller.updateData(roomData, row, col);
                            } else {
                              errorMessage(
                                  'This cell is disabled or not your turn');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: _getTileColor(
                                controller,
                                row,
                                col,
                                context,
                              ),
                              // borderRadius: _getBorderRadius(index, gridSize),
                            ),
                            child: Center(
                              child: _buildTileContent(
                                controller.board[row][col],
                                context,
                                roomData,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // if (roomData.winnerVariable != '')
                //   CustomPaint(
                //     painter: LinePainter(
                //         controller.winningLineCoordinates,
                //         gridSize,
                //         roomData.winnerVariable == 'X'
                //             ? Colors.lightBlueAccent
                //             : Colors.yellowAccent),
                //     size: Size(gridSize * 50, gridSize * 50),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(PlayWithPlayerController controller, int row, int col,
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

  Widget _buildTileContent(
    String value,
    BuildContext context,
    RoomModel roomData,
  ) {
    if (value == "X") {
      return Image.asset(roomData.champX!).animate().fadeIn(duration: duration750);
    } else if (value == "O") {
      return Image.asset(roomData.champO!).animate().scale(duration: duration750);
    } else {
      return const SizedBox();
    }
  }

  Widget buildTurnIndicator(
    ColorScheme colorScheme,
    RoomModel roomData,
    PlayWithPlayerController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: controller.isXtime.value
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: controller.isXtime.value ? Colors.red : Colors.blue,
              width: 5,
            ),
          ),
          child: Row(
            children: [
              controller.isXtime.value
                  ? Image.asset(
                      roomData.champX!,
                      width: 40,
                      height: 40,
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Colors.blueGrey),
                    ),
              const SizedBox(width: 10),
              controller.isXtime.value
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: Colors.blueGrey),
                    )
                  : Image.asset(
                      roomData.champO!,
                      width: 40,
                      height: 40,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
