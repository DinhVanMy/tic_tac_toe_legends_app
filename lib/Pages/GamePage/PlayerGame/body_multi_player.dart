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
        return Column(
          children: [
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "No data",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // await Future.delayed(const Duration(seconds: 2));
        if (roomData.winnerVariable != "" &&
            roomData.player1 != null &&
            roomData.player2 != null) {
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
        if (roomData.player1 != null && roomData.player2 != null) {
          if (roomData.player1!.quickMess != null ||
              roomData.player2!.quickMess != null) {
            playWithPlayerController.removeMessage(roomData);
          }
        }
        if (roomData.player1 != null && roomData.player2 != null) {
          if (roomData.player1!.quickEmote != null ||
              roomData.player2!.quickEmote != null) {
            playWithPlayerController.removeEmote(roomData);
          }
        }
      });

      return Column(
        children: [
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              roomData.player1 != null
                  ? Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InGameUserCard(
                              icon: IconsPath.xIcon,
                              name: roomData.player1!.name!,
                              imageUrl: roomData.player1!.image!,
                              color:
                                  roomData.isXturn! ? Colors.red : Colors.white,
                              coins: roomData.player1!.totalCoins ?? "0",
                            ),
                            roomData.player1!.quickMess != null
                                ? Positioned(
                                    right: -20,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          roomData.player1!.quickMess ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            roomData.player1!.quickEmote != null
                                ? Positioned(
                                    right: -20,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(50),
                                          bottomLeft: Radius.circular(50),
                                          bottomRight: Radius.circular(50),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.asset(
                                          roomData.player1!.quickEmote!,
                                          width: 70,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    IconsPath.wonIcon,
                                  ),
                                  const SizedBox(width: 10),
                                  Text("WON : ${roomData.player1!.totalWins}")
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      playWithPlayerController
                                          .chatFeature(context);
                                    },
                                    icon: const Icon(Icons.messenger_outline),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.mic_none),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      playWithPlayerController.emoteFeature(
                                          context, roomData);
                                    },
                                    icon: const Icon(
                                        Icons.emoji_emotions_outlined),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.toNamed("mainHome");
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 35,
                          ),
                        ),
                        const Text("Leave the room")
                      ],
                    ),
              roomData.player2 != null
                  ? Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InGameUserCard(
                              icon: IconsPath.oIcon,
                              name: roomData.player2!.name!,
                              imageUrl: roomData.player2!.image!,
                              color: roomData.isXturn!
                                  ? Colors.white
                                  : Colors.blue,
                              coins: roomData.player2!.totalCoins??"0",
                            ),
                            roomData.player2!.quickMess != null
                                ? Positioned(
                                    left: -20,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          bottomLeft: Radius.circular(30),
                                          bottomRight: Radius.circular(30),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          roomData.player2!.quickMess ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            roomData.player2!.quickEmote != null
                                ? Positioned(
                                    left: -20,
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(50),
                                          bottomLeft: Radius.circular(50),
                                          bottomRight: Radius.circular(50),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.asset(
                                          roomData.player2!.quickEmote!,
                                          width: 70,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    IconsPath.wonIcon,
                                  ),
                                  const SizedBox(width: 10),
                                  Text("WON : ${roomData.player2!.totalWins}")
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      playWithPlayerController
                                          .chatFeature(context);
                                    },
                                    icon: const Icon(Icons.messenger_outline),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.mic_none),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      playWithPlayerController.emoteFeature(
                                          context, roomData);
                                    },
                                    icon: const Icon(
                                        Icons.emoji_emotions_outlined),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.toNamed("mainHome");
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 35,
                          ),
                        ),
                        const Text("Leave the room")
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 10),
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
