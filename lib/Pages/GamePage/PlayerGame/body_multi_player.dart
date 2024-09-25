import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/ingame_user_card.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_player_controller.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/PlayerGame/ui_playing_multi_board.dart';

class BodyMultiPlayer extends StatelessWidget {
  final String roomId;
  final PlayWithPlayerController playWithPlayerController;
  final UserModel userModel;
  const BodyMultiPlayer({
    super.key,
    required this.roomId,
    required this.playWithPlayerController,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final UiPlayingMultiPlayerBoard uiPlayingMultiPlayerBoard =
        UiPlayingMultiPlayerBoard();

    return Obx(() {
      final RoomModel? roomData = playWithPlayerController.roomModel.value;
      if (roomData == null) {
        return const Column(
          children: [
            CircularProgressIndicator(),
            Text("No data"),
          ],
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (roomData.winnerVariable != "") {
          if (roomData.winnerVariable == "X" &&
              roomData.player1!.email == userModel.email) {
            playWithPlayerController.winnerDialog(
                roomData.winnerVariable!, roomData);
          } else if (roomData.winnerVariable == "O" &&
              roomData.player2!.email == userModel.email) {
            playWithPlayerController.winnerDialog(
                roomData.winnerVariable!, roomData);
          } else {
            playWithPlayerController.defeatDialog(
                roomData.winnerVariable!, roomData);
          }
        }
      });

      return Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  InGameUserCard(
                    icon: IconsPath.xIcon,
                    name: roomData.player1!.name!,
                    imageUrl: roomData.player1!.image!,
                    color: roomData.isXturn! ? Colors.red : Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          IconsPath.wonIcon,
                        ),
                        const SizedBox(width: 10),
                        Text("WON : ${roomData.player1!.totalWins}")
                      ],
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  InGameUserCard(
                    icon: IconsPath.oIcon,
                    name: roomData.player2!.name!,
                    imageUrl: roomData.player2!.image!,
                    color: roomData.isXturn! ? Colors.white : Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          IconsPath.wonIcon,
                        ),
                        const SizedBox(width: 10),
                        Text("WON : ${roomData.player2!.totalWins}")
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          uiPlayingMultiPlayerBoard.buildGameBoard(
              w,
              playWithPlayerController,
              context,
              roomId,
              roomData,
              playWithPlayerController.board.length,
              userModel),
          const SizedBox(height: 10),
          uiPlayingMultiPlayerBoard.buildTurnIndicator(
            colorScheme,
            roomData,
            playWithPlayerController,
          ),
        ],
      );
    });
  }
}
