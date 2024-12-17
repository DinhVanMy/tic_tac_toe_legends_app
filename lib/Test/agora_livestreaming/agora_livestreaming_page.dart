import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/Agoras_widget/agora_background_sheet.dart';
import 'package:tictactoe_gameapp/Test/agora_livestreaming/Widgets/bubbles_effect_widget.dart';

import 'package:tictactoe_gameapp/Test/agora_livestreaming/agora_livestreaming_controller.dart';
import 'package:tictactoe_gameapp/Test/agora_livestreaming/livestream_doc_service.dart';

class AgoraLivestreamingPage extends StatelessWidget {
  final UserModel currentUser;
  final LiveStreamModel liveStreamModel;
  final String channelId;
  final bool isStreamer;

  const AgoraLivestreamingPage({
    super.key,
    required this.currentUser,
    required this.channelId,
    required this.isStreamer,
    required this.liveStreamModel,
  });

  @override
  Widget build(BuildContext context) {
    final AgoraLivestreamController livestreamController =
        Get.put(AgoraLivestreamController(
      isStreamer: isStreamer,
      channelId: channelId,
      userId: currentUser.id!,
      url: currentUser.image!,
      streamId: liveStreamModel.streamId!,
    ));
    final UserModel streamUser = liveStreamModel.streamer!;
    final ThemeData theme = Theme.of(context);
    final TextEditingController commentTextEditingController =
        TextEditingController();
    RxBool isSeeComment = true.obs;
    RxString comment = "".obs;
    RxBool isEmoteOpen = false.obs;

    LiveStreamService liveStreamService = LiveStreamService();
    return Scaffold(
      body: Stack(
        children: [
          isStreamer
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: livestreamController.agoraEngine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: livestreamController.agoraEngine,
                    canvas: VideoCanvas(uid: liveStreamModel.hostUid),
                    connection: RtcConnection(
                      channelId: channelId,
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AvatarUserWidget(
                            radius: 25,
                            imagePath: streamUser.image!,
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
                              Text(streamUser.name!,
                                  style: theme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.white)),
                              Text(liveStreamModel.category!,
                                  style: theme.textTheme.bodyMedium!
                                      .copyWith(color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          !isStreamer
                              ? ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.redAccent,
                                    padding: const EdgeInsets.all(5),
                                    elevation: 5,
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      Text("Add"),
                                    ],
                                  ))
                              : const SizedBox(),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Obx(() => Text(
                                        livestreamController.likeCount
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Obx(() => Text(
                                        livestreamController.viewerCount
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                await GeneralBottomsheetShowFunction
                                    .showScrollableGeneralBottomsheet(
                                  widgetBuilder: (context, controller) =>
                                      AgoraBackgroundSheet(
                                    scrollController: controller,
                                    imageAvatar: currentUser.image!,
                                  ),
                                  context: context,
                                  initHeight: 0.9,
                                );
                              },
                              icon: const Icon(Icons.menu_open_rounded,
                                  size: 35, color: Colors.white)),
                          IconButton(
                              onPressed: () async {
                                if (isStreamer) {
                                  LiveStreamService liveStreamService =
                                      LiveStreamService();
                                  await liveStreamService.deleteLiveStream(
                                      liveStreamModel.streamId!);
                                  Get.toNamed("mainHome");
                                } else {
                                  Get.back();
                                }
                              },
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.white,
                                size: 30,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Obx(
                          () => isSeeComment.value
                              ? SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: Obx(() => livestreamController
                                          .comments.isNotEmpty
                                      ? ListView.builder(
                                          clipBehavior: Clip.none,
                                          controller: livestreamController
                                              .scrollController,
                                          itemCount: livestreamController
                                              .comments
                                              .toList()
                                              .length,
                                          itemBuilder: (context, index) {
                                            final comment = livestreamController
                                                .comments[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AvatarUserWidget(
                                                    radius: 25,
                                                    imagePath:
                                                        comment['photoUrl']!,
                                                    borderThickness: 2,
                                                    gradientColors: const [
                                                      Colors.lightBlueAccent,
                                                      Colors.lightGreenAccent
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(comment['name']!,
                                                            style: theme
                                                                .textTheme
                                                                .bodyLarge!),
                                                        Text(
                                                          comment["content"]!,
                                                          softWrap: true,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                  TimeFunctions.timeAgo(
                                                                      now: DateTime
                                                                          .now(),
                                                                      createdAt:
                                                                          DateTime.parse(comment[
                                                                              'createdAt']!)),
                                                                  style: theme
                                                                      .textTheme
                                                                      .bodySmall!
                                                                      .copyWith(
                                                                          color:
                                                                              Colors.blueGrey)),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {},
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .thumb_up_alt_rounded,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .blueAccent,
                                                                  )),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {},
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .thumb_down_alt_rounded,
                                                                    size: 20,
                                                                    color: Colors
                                                                        .blueAccent,
                                                                  )),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {},
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .reply_all_rounded,
                                                                    size: 25,
                                                                    color: Colors
                                                                        .white,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          })
                                      : const SizedBox()),
                                )
                              : const SizedBox(),
                        ),
                        Positioned.fill(
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: EmojiDisplay(
                              emojies: livestreamController.emojies,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(
                          () => IconButton(
                            onPressed: () {
                              isSeeComment.toggle();
                            },
                            icon: isSeeComment.value
                                ? const Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 35,
                                    color: Colors.blue,
                                  )
                                : const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 35,
                                    color: Colors.blue,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            onChanged: (commentContent) {
                              if (commentContent.isNotEmpty) {
                                comment.value = commentContent;
                              } else {
                                comment.value = '';
                              }
                            },
                            controller: commentTextEditingController,
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    const BorderSide(color: Colors.blueAccent),
                              ),
                              labelText: 'Send a comment',
                              labelStyle: theme.textTheme.bodyLarge!
                                  .copyWith(color: Colors.grey),
                              suffixIcon: Obx(
                                () => IconButton(
                                  onPressed: () {
                                    isEmoteOpen.toggle();
                                  },
                                  icon: isEmoteOpen.value
                                      ? const Icon(
                                          Icons.emoji_emotions_rounded,
                                          color: Colors.blue,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.emoji_emotions_outlined,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            onPressed: () async {
                              if (comment.value.isNotEmpty) {
                                FocusScope.of(context).unfocus();
                                await liveStreamService.addComment(
                                  liveStreamModel.streamId!,
                                  comment.value,
                                  currentUser.image!,
                                  currentUser.name!,
                                );
                                commentTextEditingController.clear();
                              }
                            },
                            icon: comment.value.isNotEmpty
                                ? const Icon(
                                    Icons.send_rounded,
                                    size: 30,
                                    color: Colors.blue,
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => isEmoteOpen.value
                          ? SizedBox(
                              height: 100,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: emotes.length,
                                itemBuilder: (context, index) {
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(50),
                                      splashColor: Colors.blueAccent,
                                      onTap: () async {
                                        await liveStreamService.addEmotes(
                                            liveStreamModel.streamId!,
                                            emotes[index]);
                                      },
                                      child: Image.asset(
                                        emotes[index],
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox(),
                    )
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 60,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Live",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          isStreamer
              ? Positioned(
                  top: 100,
                  right: 0,
                  child: Column(
                    children: [
                      Obx(
                        () => IconButton(
                          onPressed: () async {
                            livestreamController.enableScreenSharing(
                                context: context);
                          },
                          icon: !livestreamController.isSharingScreen.value
                              ? const Icon(
                                  Icons.mobile_screen_share_rounded,
                                  color: Colors.white,
                                  size: 35,
                                )
                              : const Icon(
                                  Icons.mobile_off_rounded,
                                  color: Colors.white,
                                  size: 35,
                                ),
                        ),
                      ),
                      Obx(() => !livestreamController.isMicEnabled.value
                          ? IconButton(
                              icon: const Icon(
                                Icons.mic_off_rounded,
                                color: Colors.white,
                                size: 35,
                              ),
                              onPressed: () {
                                livestreamController.toggleMic();
                              },
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 35,
                              ),
                              onPressed: () {
                                livestreamController.toggleMic();
                              },
                            )),
                      IconButton(
                        icon: const Icon(
                          Icons.switch_camera_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          livestreamController.agoraEngine.switchCamera();
                        },
                      ),
                    ],
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }
}
