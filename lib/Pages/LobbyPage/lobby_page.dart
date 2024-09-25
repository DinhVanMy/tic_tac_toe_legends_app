import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/user_card.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/PlayerGame/multi_player.dart';
import 'package:tictactoe_gameapp/Pages/LobbyPage/Widget/game_info.dart';
import 'package:tictactoe_gameapp/Pages/LobbyPage/Widget/room_info.dart';
import 'package:tictactoe_gameapp/Controller/matching_controller.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_player_controller.dart';
import '../../Components/primary_button.dart';
import '../../Configs/assets_path.dart';
import '../../Controller/room_controller.dart';

class LobbyPage extends StatelessWidget {
  final String roomId;
  const LobbyPage({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final RoomController roomController = Get.find();
    roomController.listenRoomChanges(roomId);
    final MatchingController matchController = Get.find();
    final PlayWithPlayerController playWithPlayerController =
        Get.put(PlayWithPlayerController());
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.readProfileNewUser();

    final musicController = Get.find<MusicController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // musicController.playMusicOnScreen7();
      // Get.find<NotificationController>().showNotification(
      //   'Your Great!',
      //   'You have joined room: $roomId',
      //   {'screen': 'SplacePage'},
      // );
    });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        // musicController.stopMusicOnScreen7();
                        await matchController.deleteRoom(roomId);
                        Get.offAllNamed("/mainHome");
                      },
                      child: SvgPicture.asset(IconsPath.backIcon),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "Play With Private Room",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RoomInfo(roomCode: roomId),
                const SizedBox(height: 30),
                Obx(() {
                  if (roomController.roomData.value == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final room = roomController.roomData.value;

                  if (room == null) {
                    return const Text("Room does not exist.");
                  }

                  var player1 = room.player1;
                  var player2 = room.player2;

                  if (player2 != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await Future.delayed(const Duration(seconds: 2));
                      matchController.cancelFindingPlayer2();
                    });
                  } else {}

                  if (room.player1Status == "ready" &&
                      room.player2Status == "ready") {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      await Future.delayed(const Duration(seconds: 2));
                      Get.to(MultiPlayer(
                        roomId: roomId,
                      ));
                    });
                  } else {}

                  return Stack(
                    children: [
                      Column(
                        children: [
                          GameInfo(
                            roomData: room,
                          ),
                          const SizedBox(height: 80),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              player1 != null
                                  ? UserCard(
                                      imageUrl: player1.image ?? '',
                                      name: player1.name ?? 'Player 1',
                                      coins: player1.totalCoins ?? "00",
                                      status: room.player1Status ?? 'waiting',
                                      email: player1.email ?? "No Email",
                                      role: player1.role ?? 'anonymous',
                                    )
                                  : SizedBox(
                                      width: w / 2.6,
                                      child: const Text(
                                        "Waiting for Player 1...",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                              player2 != null
                                  ? UserCard(
                                      imageUrl: player2.image ?? '',
                                      name: player2.name ?? 'Player 2',
                                      coins: player2.totalCoins ?? "00",
                                      status: room.player2Status ?? 'waiting',
                                      email: player2.email ?? "No Email",
                                      role: player2.role ?? 'guest',
                                    )
                                  : SizedBox(
                                      width: w / 2.6,
                                      child: Obx(
                                        () => Column(
                                          children: [
                                            matchController
                                                    .isFindingPlayer2.value
                                                ? const Text(
                                                    "Finding for Player 2...",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.redAccent),
                                                  )
                                                : const Text(
                                                    "Waiting for Player 2...",
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            matchController
                                                    .isFindingPlayer2.value
                                                ? Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: Image.asset(
                                                          GifsPath.loadingGif,
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            matchController
                                                    .isFindingPlayer2.value
                                                ? ElevatedButton.icon(
                                                    onPressed: () {
                                                      matchController
                                                          .cancelFindingPlayer2();
                                                    },
                                                    label: const Text("Cancel"),
                                                    icon: const Icon(
                                                        Icons.search_off),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 12),
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                    ),
                                                  )
                                                : ElevatedButton.icon(
                                                    onPressed: () {
                                                      matchController
                                                          .findingPlayer2();
                                                    },
                                                    label:
                                                        const Text("Finding"),
                                                    icon: const Icon(
                                                      Icons.search,
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.blue,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 12),
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          room.player1 != null &&
                                  room.player1!.email == user.email
                              ? PrimaryButton(
                                  buttonText: room.player1Status! == "ready"
                                      ? " Waiting for start"
                                      : "Start Game",
                                  onTap: () {
                                    if (room.player1Status! != "ready") {
                                      playWithPlayerController
                                          .showPickerMultiPlayer(
                                              roomId: roomId);
                                    } else {
                                      errorMessage("Waiting for game start");
                                    }
                                  },
                                )
                              : room.player2Status == "waiting"
                                  ? PrimaryButton(
                                      buttonText: "Ready",
                                      onTap: () async {
                                        await roomController
                                            .updatePlayer2Status(
                                                roomId, "ready");
                                      },
                                    )
                                  : PrimaryButton(
                                      buttonText: "Waiting for start",
                                      onTap: () async {
                                        await roomController
                                            .updatePlayer2Status(
                                                roomId, "waiting");
                                      },
                                    ),
                        ],
                      ),
                      room.player1Status == "ready" &&
                              room.player2Status == "ready"
                          ? Positioned.fill(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: const SizedBox(),
                              ),
                            )
                          : const SizedBox(),
                      room.player1Status == "ready" &&
                              room.player2Status == "ready"
                          ? Positioned(
                              top: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    GifsPath.loadingGif,
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
