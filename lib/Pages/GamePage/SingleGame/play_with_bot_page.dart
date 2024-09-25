import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_bot_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/SingleGame/ui_playing_board.dart';
import '../../../Configs/assets_path.dart';

class PlayWithBotPage extends StatelessWidget {
  const PlayWithBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UiPlayingBoard uiPlayingBoard = UiPlayingBoard();
    final w = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final PlayWithBotController controller = Get.put(PlayWithBotController());
    // final DottedBorderAnimationController animationController =
    //     Get.put(DottedBorderAnimationController());
    final user = Get.find<ProfileController>().readProfileNewUser();
    final MusicController musicController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      musicController.playMusicOnScreen6();
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: controller.isXtime.value
                              ? Border.all(
                                  color: Colors.red,
                                  width: 7,
                                )
                              : Border.all(),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child:
                                  user.image != null && user.image!.isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  user.image!),
                                          maxRadius: 55,
                                        )
                                      : const Icon(Icons.person_2_outlined),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 45),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(IconsPath.xIcon),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    IconsPath.wonIcon,
                                  ),
                                  const SizedBox(width: 10),
                                  Obx(
                                    () => Text("WON : ${controller.xScore}"),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: !controller.isXtime.value
                              ? Border.all(
                                  color: Colors.orange,
                                  width: 7,
                                )
                              : Border.all(),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              backgroundImage: AssetImage(GifsPath.androidGif),
                              radius: 40,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 45),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SvgPicture.asset(IconsPath.oIcon),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    IconsPath.wonIcon,
                                  ),
                                  const SizedBox(width: 10),
                                  Obx(
                                    () => Text("WON : ${controller.oScore}"),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                uiPlayingBoard.buildGameBoard(w, controller, context),
                const SizedBox(height: 10),
                uiPlayingBoard.buildTurnIndicator(colorScheme, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
