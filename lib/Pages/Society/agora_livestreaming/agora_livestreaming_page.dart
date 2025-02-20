import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/preview_gif_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/Agoras_widget/agora_background_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/Widgets/bubbles_effect_widget.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/Widgets/livestream_comment_list_widget.dart';

import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/agora_livestreaming_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';
import 'package:tictactoe_gameapp/Components/emotes_picker_widget.dart';

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
    // final int hostUid =
    //     int.parse(_extractNumbers(liveStreamModel.streamer!.id!));
    final UserModel streamUser = liveStreamModel.streamer!;
    final ThemeData theme = Theme.of(context);
    final TextEditingController textController = TextEditingController();
    RxBool isSeeComment = true.obs;
    RxString comment = "".obs;
    RxBool isEmoteOpen = false.obs;
    RxBool isEmojiPickerVisible = false.obs;
    var selectedGif = Rx<GiphyGif?>(null);

    LiveStreamService liveStreamService = LiveStreamService();
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    canvas: VideoCanvas(
                        uid: int.parse(
                            _extractNumbers(liveStreamModel.streamer!.id!))),
                    connection: RtcConnection(
                      channelId: liveStreamModel.channelId,
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
                                        livestreamController.viewerCount.value
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
                                  await liveStreamService.decrementViewerCount(
                                      liveStreamModel.streamId!);
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
                              ? LiveStreamCommentListWidget(
                                  theme: theme,
                                  livestreamController: livestreamController)
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
                    PreviewGifWidget(selectedGif: selectedGif),
                    CustomEmojiPicker(
                      height: 200,
                      isSearchEmo: false,
                      onEmojiSelected: (emoji) {
                        textController.text += emoji;
                        comment.value = textController.text;
                        textController.selection = TextSelection.fromPosition(
                          TextPosition(offset: textController.text.length),
                        );
                      },
                      onBackspacePressed: () {
                        final text = textController.text;
                        if (text.isNotEmpty) {
                          // Xóa ký tự cuối (bao gồm cả emoji)
                          textController.text =
                              text.characters.skipLast(1).toString();
                          comment.value = textController.text;
                          textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: textController.text.length),
                          );
                        }
                      },
                      isEmojiPickerVisible: isEmojiPickerVisible,
                      backgroundColor: const [
                        Colors.blueGrey,
                        Colors.blueGrey,
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
                                    Icons.comment_rounded,
                                    size: 30,
                                    color: Colors.blue,
                                  )
                                : const Icon(
                                    Icons.comments_disabled_rounded,
                                    size: 30,
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
                            controller: textController,
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
                              prefixIcon: IconButton(
                                icon: const Icon(
                                  Icons.gif_box_outlined,
                                  color: Colors.blueAccent,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  final gif = await GiphyPicker.pickGif(
                                    context: context,
                                    apiKey: apiGifphy,
                                    showPreviewPage: false,
                                    showGiphyAttribution: false,
                                    loadingBuilder: (context) {
                                      return Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.asset(
                                            GifsPath.loadingGif,
                                            height: 200,
                                            width: 200,
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  if (gif != null) {
                                    selectedGif.value = gif;
                                  }
                                },
                              ),
                              suffixIcon: Obx(() => IconButton(
                                  onPressed: () {
                                    isEmojiPickerVisible.toggle();
                                  },
                                  icon: isEmojiPickerVisible.value
                                      ? const Icon(
                                          Icons.emoji_emotions,
                                          color: Colors.blue,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.emoji_emotions_outlined,
                                          color: Colors.blue,
                                          size: 30,
                                        ))),
                            ),
                          ),
                        ),
                        Obx(() => IconButton(
                            onPressed: () {
                              isEmoteOpen.toggle();
                            },
                            icon: isEmoteOpen.value
                                ? const Icon(
                                    Icons.card_giftcard_rounded,
                                    color: Colors.blue,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.card_giftcard_outlined,
                                    color: Colors.blue,
                                    size: 30,
                                  ))),
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
                                  selectedGif.value?.images.original!.url!,
                                );
                                textController.clear();
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

  String _extractNumbers(String userId) {
    return userId.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
