import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/share_sheet_custom.dart';
import 'package:tictactoe_gameapp/Test/Reels/create_reel_page.dart';
import 'package:tictactoe_gameapp/Test/Reels/whitecodel/whitecodel_reels_page.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_controller.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_model.dart';
import 'package:video_player/video_player.dart';

class ReelPage extends StatelessWidget {
  final UserModel user;
  const ReelPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ReelController reelController = Get.put(ReelController());
    return Scaffold(
      body: Obx(() {
        if (reelController.reelsList.isEmpty) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  GifsPath.transitionGif,
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          var reels = reelController.reelsList.toList();
          return Stack(
            children: [
              WhiteCodelReelsPage(
                isCaching: true,
                reelController: reelController,
                videoList: reels.map((e) => e.videoUrl!).toList(),
                builder: (context, index, child, videoPlayerController,
                    pageController, videoProgressController) {
                  if (index < 0 || index >= reels.length) {
                    return const Center(
                      child: Text(
                        "Error!",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                  //todo:
                  // if (index == reels.length - 1) {
                  //   reelController.fetchMoreReels();
                  // }
                  var reel = reels[index];

                  return Stack(
                    children: [
                      Container(
                        color: Colors.transparent,
                        child: GestureDetector(
                            onDoubleTap: () async {
                              reelController
                                      .isLikedReel(user.id!, reel.reelId!)
                                      .value
                                  ? await reelController.unlikeReel(
                                      reel.reelId!, user.id!)
                                  : await reelController.likeReel(
                                      reel.reelId!, user.id!);
                            },
                            onLongPress: () {
                              successMessage("Saved reel successfully!");
                            },
                            child: child),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 0,
                        right: 50,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVideoInfo(theme, reel),
                            _buildProcessingLine(context,
                                videoProgressController, videoPlayerController),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: _buildActionButtons(
                            context, reel, index, reelController),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  onPressed: () => Get.toNamed("mainHome"),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => Get.to(
                    CreateReelPage(user: user),
                    transition: Transition.upToDown,
                  ),
                  icon: const Icon(Icons.camera_enhance_outlined,
                      color: Colors.white, size: 30),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildVideoInfo(ThemeData theme, ReelModel reel) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 8.0,
        bottom: 5.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "#${reel.privacy}",
            style: theme.textTheme.bodyLarge!.copyWith(color: Colors.blueGrey),
          ),
          const SizedBox(
            height: 5,
          ),
          ExpandableContent(
              content: reel.description ?? "",
              maxLines: 2,
              style: theme.textTheme.headlineSmall!.copyWith(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
              )),
          const SizedBox(
            height: 5,
          ),
          Text(
            TimeFunctions.timeAgo(
                now: DateTime.now(), createdAt: reel.createdAt!),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ReelModel reel, int index,
      ReelController reelController) {
    return Column(
      children: [
        AvatarUserWidget(
          radius: 30,
          imagePath: reel.reelUser!.image!,
          borderThickness: 2,
          gradientColors: const [
            Colors.lightBlueAccent,
            Colors.lightGreenAccent
          ],
        ),
        GestureDetector(
            onTap: () async {},
            child: const Text("Follow",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold))),
        Obx(
          () => _buildActionButton(
            Icons.thumb_up_alt,
            Icons.thumb_up_alt_outlined,
            reelController.isLikedReel(user.id!, reel.reelId!).value,
            () async {
              reelController.isLikedReel(user.id!, reel.reelId!).value
                  ? await reelController.unlikeReel(reel.reelId!, user.id!)
                  : await reelController.likeReel(reel.reelId!, user.id!);
            },
            reel.likedList == null ? "0" : reel.likedList!.length.toString(),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButton(Icons.comment, Icons.messenger_outline, false, () {},
            reel.commentCount.toString()),
        const SizedBox(height: 10),
        _buildActionButton(Icons.share, Icons.share_outlined, false, () async {
          await GeneralBottomsheetShowFunction.showScrollableGeneralBottomsheet(
            widgetBuilder: (context, controller) => ShareSheetCustom(
              scrollController: controller,
              currentUser: user,
              onPressed: () async {
                await reelController.incrementSharedCount(reel, user).then((_) {
                  Get.back();
                  successMessage("Reel shared successfully!");
                });
              },
            ),
            context: context,
            initHeight: 0.8,
            color: Colors.transparent,
          );
        }, "Share"),
        const SizedBox(height: 10),
        _buildActionButton(
            Icons.star_rounded, Icons.star_outline_rounded, false, () {
          successMessage("Saved reel successfully!");
        }, "Save"),
      ],
    );
  }

  Widget _buildActionButton(IconData iconActive, IconData iconInactive,
      bool isActive, VoidCallback onPressed, String label) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            isActive ? iconActive : iconInactive,
            color: Colors.white,
            size: 30,
          ),
        ),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProcessingLine(
    BuildContext context,
    StreamController<double> videoProgressController,
    VideoPlayerController videoPlayerController,
  ) {
    return StreamBuilder(
      stream: videoProgressController.stream,
      builder: (context, snapshot) {
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: SliderComponentShape.noThumb,
            overlayShape: SliderComponentShape.noOverlay,
            trackHeight: 2,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: SliderComponentShape.noThumb,
                overlayShape: SliderComponentShape.noOverlay,
                trackHeight: 2,
              ),
              child: Slider(
                value: (snapshot.data ?? 0).clamp(0.0, 1.0),
                min: 0.0,
                max: 1.0,
                activeColor: Colors.pinkAccent,
                inactiveColor: Colors.white,

                onChanged: (value) {
                  final position =
                      videoPlayerController.value.duration.inMilliseconds *
                          value;
                  videoPlayerController
                      .seekTo(Duration(milliseconds: position.toInt()));
                },
                // onChangeEnd: (value) {
                //   videoPlayerController.play();
                // },
              ),
            ),
          ),
        );
      },
    );
  }
}
