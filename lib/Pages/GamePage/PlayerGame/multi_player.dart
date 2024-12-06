import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/PlayerGame/body_multi_player.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_player_controller.dart';

class MultiPlayer extends StatelessWidget {
  final String roomId;
  const MultiPlayer({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final PlayWithPlayerController playWithPlayerController =
        Get.put<PlayWithPlayerController>(PlayWithPlayerController());
    playWithPlayerController.getRoomDetails(roomId);
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.user!;
    // final MusicController musicController = Get.find();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   musicController.stopMusicOnScreen7();
    // });
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: BodyMultiPlayer(
              roomId: roomId,
              playWithPlayerController: playWithPlayerController,
              userModel: user,
            ),
          ),
        ),
      ),
    );
  }
}
