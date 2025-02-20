import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/share_sheet_custom.dart';
import 'package:tictactoe_gameapp/Test/Reels/create_reel_page.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_controller.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_model.dart';
import 'package:video_player/video_player.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';

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
              WhiteCodelReels(
                key: UniqueKey(),
                context: context,
                loader: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        GifsPath.loadingGif2,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                isCaching: true,
                videoList: reels.map((e) => e.videoUrl!).toList(),
                builder: (context, index, child, videoPlayerController,
                    pageController) {
                  if (index < 0 || index >= reels.length) {
                    return const Center(
                      child: Text(
                        "Error!",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                  var reel = reels[index];
                  StreamController<double> videoProgressController =
                      StreamController<double>();
                  videoPlayerController.addListener(() {
                    double videoProgress =
                        videoPlayerController.value.position.inMilliseconds /
                            videoPlayerController.value.duration.inMilliseconds;
                    videoProgressController.add(videoProgress);
                  });
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
                            child: child),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            _buildVideoInfo(theme, reel),
                            _buildProcessingLine(context,
                                videoProgressController, videoPlayerController),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 70,
                        right: 10,
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
                  icon: const Icon(Icons.camera_enhance_rounded,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: ExpandableContent(
                content: reel.description ?? "",
                style: theme.textTheme.titleMedium!.copyWith(
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                )),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarUserWidget(
                radius: 25,
                imagePath: user.image!,
                borderThickness: 2,
                gradientColors: const [
                  Colors.lightBlueAccent,
                  Colors.lightGreenAccent
                ],
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name!,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.blueAccent,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                        color: Colors.transparent,
                      ),
                      child: Text(
                        "Follow",
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          // Text(
          //   reel.description ?? "",
          //   maxLines: 2,
          //   overflow: TextOverflow.ellipsis,
          //   style: const TextStyle(color: Colors.white, fontSize: 16),
          // ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ReelModel reel, int index,
      ReelController reelController) {
    return Column(
      children: [
        _buildActionButton(
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
        const SizedBox(height: 10),
        _buildActionButton(Icons.comment, Icons.comment, false, () {},
            reel.commentCount.toString()),
        const SizedBox(height: 10),
        _buildActionButton(Icons.share, Icons.share, false, () async {
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
            Icons.bookmark, Icons.bookmark_border, false, () {}, "Save"),
      ],
    );
  }

  Widget _buildActionButton(IconData iconActive, IconData iconInactive,
      bool isActive, VoidCallback onPressed, String label) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(isActive ? iconActive : iconInactive, color: Colors.white),
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
