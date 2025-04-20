# Source Code Summary

## Directory Structure
```
./
  agora_livestreaming_controller.dart
  agora_livestreaming_page.dart
  create_livestream_room_page.dart
  livestream_controller.dart
  livestream_doc_service.dart
  Widgets/
    bubbles_effect_widget.dart
    livestream_comment_list_widget.dart
```


## File Contents


### agora_livestreaming_controller.dart

```dart
import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';

class AgoraLivestreamController extends GetxController {
  late final RtcEngine agoraEngine;
  LiveStreamService liveStreamService = LiveStreamService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? liveStreamSubscription;
  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  final RxBool isMicEnabled = true.obs;
  final RxBool isVideoEnabled = true.obs;
  final RxBool isSharingScreen = false.obs;

  final String channelId;
  final String userId;
  final String url;
  final bool isStreamer;
  final String streamId;

  AgoraLivestreamController({
    required this.channelId,
    required this.userId,
    required this.url,
    required this.isStreamer,
    required this.streamId,
  });

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    if (isStreamer) {
      stopScreenSharing();
    }
    _disposeAgora();
    liveStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    await _initializeAgora();
    await _joinChannel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToForestoreLiveStreamEvent();
    });
  }

  // 2.1. Khởi tạo Agora Engine
  Future<void> _initializeAgora() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
       RtcEngineContext(appId: apiAgoraAppId),
    );
    await agoraEngine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    if (isStreamer) {
      await agoraEngine.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster);
      await agoraEngine.enableAudio();
      await agoraEngine.enableVideo();
    } else {
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  // 2.2. Tham gia phòng livestream
  Future<void> _joinChannel() async {
    final int intUserId = int.parse(_extractNumbers(userId));
    final expireTimestamp =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    final token = RtcTokenBuilder.build(
      appId: apiAgoraAppId,
      appCertificate: apiAgoraAppCertificate,
      channelName: channelId,
      uid: intUserId.toString(),
      role: isStreamer ? RtcRole.publisher : RtcRole.subscriber,
      expireTimestamp: expireTimestamp,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelId,
      uid: intUserId,
      options: ChannelMediaOptions(
        clientRoleType: isStreamer
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );
  }

  // 2.3. Bật chia sẻ màn hình (Host)
  Future<void> enableScreenSharing({required BuildContext context}) async {
    try {
      if (!isSharingScreen.value) {
        toggleVideo();
        await agoraEngine
            .setScreenCaptureScenario(ScreenScenarioType.screenScenarioGaming);
        const ScreenAudioParameters parametersAudioParams =
            ScreenAudioParameters(
          sampleRate: 100,
        );
        //todo: reposive screen sharing
        final FlutterView view = View.of(context);
        // final screenWidth = view.physicalSize.width.toInt();
        // final screenHeight = view.physicalSize.height.toInt();
        final int logicalWidth =
            (view.physicalSize.width / view.devicePixelRatio).toInt();
        final int logicalHeight =
            (view.physicalSize.height / view.devicePixelRatio).toInt();
        final VideoDimensions videoParamsDimensions = VideoDimensions(
          // width: 1280,
          // height: 720,
          width: logicalWidth,
          height: logicalHeight,
        );
        final ScreenVideoParameters parametersVideoParams =
            ScreenVideoParameters(
          dimensions: videoParamsDimensions,
          frameRate: 30,
          bitrate: 1000,
          contentHint: VideoContentHint.contentHintMotion,
        );
        final ScreenCaptureParameters2 parameters = ScreenCaptureParameters2(
          captureAudio: true,
          audioParams: parametersAudioParams,
          captureVideo: true,
          videoParams: parametersVideoParams,
        );

        await agoraEngine.startScreenCapture(parameters);

        isSharingScreen.value = true;
      } else {
        stopScreenSharing();
        toggleVideo();
      }
    } catch (e) {
      errorMessage("Failed to enable screen sharing: $e");
      isSharingScreen.value = false;
    }
  }

  // 2.4. Tắt chia sẻ màn hình
  Future<void> stopScreenSharing() async {
    if (isSharingScreen.value) {
      await agoraEngine.stopScreenCapture();
      isSharingScreen.value = false;
    }
  }

  // 2.6. Tắt mic
  void toggleMic() {
    isMicEnabled.toggle();
    agoraEngine.muteLocalAudioStream(!isMicEnabled.value);
  }

  void toggleVideo() {
    isVideoEnabled.toggle();
    agoraEngine.muteLocalVideoStream(!isVideoEnabled.value);
  }

  RxInt viewerCount = 1.obs;
  RxInt likeCount = 0.obs;
  RxList<Map<String, String>> comments = <Map<String, String>>[].obs;
  RxList<String> emojies = <String>[].obs;
  void _listenToForestoreLiveStreamEvent() {
    liveStreamSubscription = _firestore
        .collection('liveStreams')
        .doc(streamId)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        LiveStreamModel liveStreamModel =
            LiveStreamModel.fromJson(event.data()!);

        viewerCount.value = liveStreamModel.viewerCount ?? 1;

        likeCount.value = liveStreamModel.likeCount ?? 0;

        emojies.value = liveStreamModel.emotes ?? [];

        if (event.data()?['comments'] is Map) {
          comments.value = (event.data()?['comments'] as Map<String, dynamic>)
              .entries
              .map((entry) => {
                    "name": entry.value['name']?.toString() ?? '',
                    "photoUrl": entry.value['photoUrl']?.toString() ?? '',
                    "content": entry.value['content']?.toString() ?? '',
                    "gif": entry.value['gif']?.toString() ?? '',
                    "createdAt": entry.value['createdAt']?.toString() ?? '',
                  })
              .toList();

          comments.sort((a, b) {
            final timeA = DateTime.parse(a['createdAt']!);
            final timeB = DateTime.parse(b['createdAt']!);
            return timeA.compareTo(timeB);
          });
          _scrollToBottom();
        } else {
          comments.clear();
        }
      } else {
        errorMessage("Room is not existing");
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOut,
        );
        // _scrollController.jumpTo(
        //   _scrollController.position.maxScrollExtent,
        // );
      }
    });
  }

  // 2.8. Giải phóng Agora Engine
  Future<void> _disposeAgora() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
  }

  String _extractNumbers(String userId) {
    return userId.replaceAll(RegExp(r'[^0-9]'), '');
  }
}

```

---


### agora_livestreaming_page.dart

```dart
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
                            gradientColors: streamUser.avatarFrame,
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
                            textInputAction: TextInputAction.done,
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

```

---


### create_livestream_room_page.dart

```dart
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/optional_tile_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/agora_livestreaming_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';
import 'package:uuid/uuid.dart';

class CreateLivestreamRoomPage extends StatelessWidget {
  final UserModel currentUser;
  const CreateLivestreamRoomPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    RxString titleContent = "".obs;
    RxString descriptionContent = "".obs;
    RxString audienceMode = "Public".obs;
    RxString imagePath = "".obs;
    XFile? image;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              size: 40,
              color: Colors.deepPurple,
            ),
          ),
          centerTitle: false,
          title: Text(
            "Create a new live room",
            style: theme.textTheme.headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            Obx(
              () => titleContent.value.isEmpty ||
                      descriptionContent.value.isEmpty ||
                      imagePath.value.isEmpty
                  ? Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "LIVE",
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black45),
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        await Get.showOverlay(
                            asyncFunction: () async {
                              var uuid = const Uuid();
                              final String channelId =
                                  uuid.v4().substring(0, 12);
                              final String streamId = uuid.v4().substring(0, 8);
                              List<int> imageBytes = await image!.readAsBytes();
                              String? base64String = base64Encode(imageBytes);
                              LiveStreamService liveStreamService =
                                  LiveStreamService();
                              LiveStreamModel liveStreamModel = LiveStreamModel(
                                streamId: streamId,
                                channelId: channelId,
                                streamer: currentUser,
                                title: titleContent.value,
                                description: descriptionContent.value,
                                thumbnailUrl: base64String,
                                category: audienceMode.value,
                                viewerCount: 1,
                                likeCount: 0,
                                emotes: [],
                                createdAt: DateTime.now(),
                              );
                              await liveStreamService
                                  .createLiveStream(liveStreamModel);
                              Get.to(() => AgoraLivestreamingPage(
                                    currentUser: currentUser,
                                    liveStreamModel: liveStreamModel,
                                    channelId: channelId,
                                    isStreamer: true,
                                  ));
                            },
                            loadingWidget: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  GifsPath.loadingGif,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                            ));
                      },
                      child: Ink(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "LIVE",
                            style: theme.textTheme.bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(currentUser.image!),
                      radius: 35,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name!,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      audienceMode.value = "Private";
                                    },
                                    child: Obx(
                                      () => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Private"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: audienceMode.value ==
                                                      "Private"
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Private",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Private"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    audienceMode.value = "Friends";
                                  },
                                  child: Obx(() => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Friends"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_alt_rounded,
                                              color: audienceMode.value ==
                                                      "Friends"
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Friends",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Friends"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    audienceMode.value = "Public";
                                  },
                                  child: Obx(() => Container(
                                        height: 40,
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: audienceMode.value == "Public"
                                              ? Colors.blueAccent
                                              : Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.public,
                                              color:
                                                  audienceMode.value == "Public"
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              "Public",
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                color: audienceMode.value ==
                                                        "Public"
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 100,
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        titleContent.value = text;
                      } else {
                        titleContent.value = "";
                      }
                    },
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      labelText: 'Title for live',
                      alignLabelWithHint: true,
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 150,
                  child: TextField(
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        descriptionContent.value = text;
                      } else {
                        descriptionContent.value = "";
                      }
                    },
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      labelText: 'Description for live',
                      alignLabelWithHint: true,
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    const Text(
                      "Thumbnail",
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final ProfileController profileController =
                                Get.find();

                            image = await profileController
                                .pickFileX(ImageSource.camera);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final ProfileController profileController =
                                Get.find();

                            image = await profileController
                                .pickFileX(ImageSource.gallery);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(
                            Icons.image_rounded,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            imagePath.value = "";
                          },
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    Obx(() => Container(
                          height: 250,
                          width: 200,
                          alignment: Alignment.center,
                          decoration: imagePath.value.isNotEmpty
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                      File(
                                        imagePath.value,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey.shade300,
                                ),
                        )),
                    OptionalTileWidget(
                      onTap: () {},
                      title: "Tag people",
                      icon: Icons.person_add_alt_1_sharp,
                      color: Colors.blue,
                    ),
                    Container(
                      height: 50,
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "LIVE",
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black45),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

```

---


### livestream_controller.dart

```dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';

class LiveStreamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ScrollController để hỗ trợ lazy load
  late final ScrollController scrollController;

  // Danh sách live streams
  var liveStreamsList = <LiveStreamModel>[].obs;

  // Biến để theo dõi trạng thái tải
  bool isFetching = false;
  DocumentSnapshot? lastDocument;
  final int pageSize = 6;

  late StreamSubscription subscriptionListenStreams;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchInitialLiveStreams();
    listenToLiveStreamChanges();

    // Lắng nghe sự kiện scroll để tải thêm dữ liệu
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels >=
    //           scrollController.position.maxScrollExtent &&
    //       !isFetching) {
    //     fetchMoreLiveStreams();
    //   }
    // });
  }

  // Hàm tải dữ liệu trang đầu tiên
  Future<void> fetchInitialLiveStreams() async {
    if (isFetching) return;
    isFetching = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('liveStreams')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        liveStreamsList.value = snapshot.docs.map((doc) {
          return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print("Error fetching live streams: $e");
    } finally {
      isFetching = false;
    }
  }

  // Hàm tải thêm dữ liệu (lazy load)
  Future<void> fetchMoreLiveStreams() async {
    if (isFetching || lastDocument == null) return;
    isFetching = true;

    try {
      Query query = _firestore
          .collection('liveStreams')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        liveStreamsList.value = snapshot.docs.map((doc) {
          return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null; // Không còn dữ liệu để tải
      }
    } catch (e) {
      print("Error fetching more live streams: $e");
    } finally {
      isFetching = false;
    }
  }

  // Lắng nghe các thay đổi của collection liveStreams
  void listenToLiveStreamChanges() {
    subscriptionListenStreams = _firestore
        .collection('liveStreams')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          liveStreamsList.insert(
              0,
              LiveStreamModel.fromJson(
                  change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          int index = liveStreamsList
              .indexWhere((live) => live.streamId == change.doc.id);
          if (index != -1) {
            liveStreamsList[index] = LiveStreamModel.fromJson(
                change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          liveStreamsList.removeWhere((live) => live.streamId == change.doc.id);
        }
      }
    });
  }

  @override
  void onClose() {
    subscriptionListenStreams.cancel();
    scrollController.dispose();
    super.onClose();
  }
}

```

---


### livestream_doc_service.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:uuid/uuid.dart';

class LiveStreamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Collection Reference**
  /// Đây là tham chiếu đến collection trong Firestore nơi lưu trữ các livestream.
  CollectionReference get _liveStreamCollection =>
      _firestore.collection('liveStreams');

  /// **Tạo mới một livestream**
  Future<void> createLiveStream(LiveStreamModel liveStream) async {
    try {
      // Tạo ID tự động nếu không có
      final String newStreamId =
          liveStream.streamId ?? _liveStreamCollection.doc().id;

      liveStream.streamId = newStreamId;

      await _liveStreamCollection.doc(newStreamId).set(liveStream.toJson());
    } catch (e) {
      errorMessage("Error creating live stream: $e");
      rethrow;
    }
  }

  /// **Lấy danh sách tất cả các livestream**
  Future<List<LiveStreamModel>> getAllLiveStreams() async {
    try {
      final QuerySnapshot snapshot = await _liveStreamCollection.get();
      return snapshot.docs
          .map((doc) =>
              LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage("Error fetching live streams: $e");
      rethrow;
    }
  }

  /// **Lấy thông tin một livestream theo streamId**
  Future<LiveStreamModel?> getLiveStreamById(String streamId) async {
    try {
      final DocumentSnapshot doc =
          await _liveStreamCollection.doc(streamId).get();

      if (doc.exists) {
        return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      errorMessage("Error fetching live stream by ID: $e");
      rethrow;
    }
  }

  /// **Cập nhật thông tin livestream**
  Future<void> updateLiveStream(
      String streamId, LiveStreamModel liveStream) async {
    try {
      await _liveStreamCollection.doc(streamId).update(liveStream.toJson());
      print("Live stream updated successfully");
    } catch (e) {
      errorMessage("Error updating live stream: $e");
      rethrow;
    }
  }

  /// **Cập nhật một số trường của livestream**
  Future<void> updateLiveStreamFields(
      String streamId, String field, dynamic value) async {
    try {
      // Chỉ cập nhật các trường được truyền trong fieldsToUpdate
      await _liveStreamCollection.doc(streamId).update({field: value});
    } on FirebaseException catch (e) {
      // Bắt lỗi cụ thể từ Firebase
      errorMessage("Firebase error: ${e.message}");
      rethrow;
    } catch (e) {
      // Bắt các lỗi khác (nếu có)
      errorMessage("Unexpected error: $e");
      rethrow;
    }
  }

  /// **Xóa livestream**
  Future<void> deleteLiveStream(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).delete();
    } catch (e) {
      errorMessage("Error deleting live stream: $e");
      rethrow;
    }
  }

  /// **Tăng số lượt xem**
  Future<void> incrementViewerCount(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).update({
        'viewerCount': FieldValue.increment(1),
      });
    } catch (e) {
      errorMessage("Error incrementing viewer count: $e");
      rethrow;
    }
  }

  Future<void> decrementViewerCount(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).update({
        'viewerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      errorMessage("Error decrementing viewer count: $e");
    }
  }

  /// **Thêm bình luận vào livestream**
  Future<void> addComment(
    String streamId,
    String content,
    String avtCommentUser,
    String nameCommentUser,
    String? gifUrl,
  ) async {
    try {
      var uuid = const Uuid();
      final String commentId = uuid.v4().substring(0, 12);
      final Map<String, String> comment = {
        "name": nameCommentUser,
        "photoUrl": avtCommentUser,
        "content": content,
        "createdAt": DateTime.now().toIso8601String(),
        "gif":gifUrl??"",
      };
      await _liveStreamCollection
          .doc(streamId)
          .update({'comments.$commentId': comment});
    } catch (e) {
      errorMessage("Error adding comment: $e");
      rethrow;
    }
  }

  // Future<void> addComment(
  //   String streamId,
  //   String content,
  //   String avtCommentUser,
  //   String nameCommentUser,
  // ) async {
  //   try {
  //     var uuid = const Uuid();
  //     final String commentId = uuid.v4().substring(0, 12);
  //     final Map<String, dynamic> newComment = {
  //       "name": nameCommentUser,
  //       "photoUrl": avtCommentUser,
  //       "content": content,
  //       "createdAt": DateTime.now().toIso8601String(),
  //     };

  //     final docRef = _liveStreamCollection.doc(streamId);

  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       // Lấy dữ liệu hiện tại
  //       DocumentSnapshot snapshot = await transaction.get(docRef);

  //       if (!snapshot.exists) {
  //         throw Exception("Stream with ID $streamId does not exist.");
  //       }

  //       // Lấy danh sách comments hiện tại (Map)
  //       Map<String, dynamic> comments = snapshot.get("comments") ?? {};

  //       // Chuyển Map thành List để dễ xử lý
  //       List<MapEntry<String, dynamic>> commentList = comments.entries.toList();

  //       // Nếu đã đạt đến giới hạn, xóa comment cũ nhất
  //       if (commentList.length >= 100) {
  //         commentList.removeAt(0);
  //       }

  //       // Thêm comment mới vào danh sách
  //       commentList.add(MapEntry(commentId, newComment));

  //       // Chuyển danh sách trở lại Map và cập nhật Firestore
  //       Map<String, dynamic> updatedComments = Map.fromEntries(commentList);
  //       transaction.update(docRef, {"comments": updatedComments});
  //     });
  //   } catch (e) {
  //     errorMessage("Error adding comment: $e");
  //     rethrow;
  //   }
  // }

  Future<void> addEmotes(String streamId, String emote) async {
    final docRef = _liveStreamCollection.doc(streamId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Lấy document hiện tại
      DocumentSnapshot snapshot = await transaction.get(docRef);

      // Lấy danh sách messages hiện tại
      List<dynamic> messages = snapshot.get('emotes') ?? [];

      // Thêm message mới
      if (messages.length >= 30) {
        messages.removeAt(0); // Xóa message cũ nhất
      }
      messages.add(emote); // Thêm message mới

      // Cập nhật lại danh sách
      transaction.update(docRef, {'emotes': messages});
    }).catchError((e) {
      errorMessage("Failed to add emote: $e");
    });
  }

  /// **Nghe cập nhật realtime cho một livestream**
  Stream<LiveStreamModel?> streamLiveStreamUpdates(String streamId) {
    return _liveStreamCollection.doc(streamId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return LiveStreamModel.fromJson(
            snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}

```

---


### Widgets\bubbles_effect_widget.dart

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/gradient_generator_functions.dart';

class EmojiDisplay extends StatelessWidget {
  final RxList<String> emojies;
  const EmojiDisplay({super.key, required this.emojies});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: emojies.map((imagePath) {
          final random = Random();
          return Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedEmoji(
                imagePath: imagePath,
                startX: random.nextDouble(),
                startY: 0.5,
                controlX: random.nextDouble(),
                controlY: random.nextDouble(),
                endX: random.nextDouble(),
                endY: -1.0,
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class AnimatedEmoji extends StatefulWidget {
  final String imagePath;
  final double startX;
  final double startY;
  final double controlX;
  final double controlY;
  final double endX;
  final double endY;

  const AnimatedEmoji({
    super.key,
    required this.imagePath,
    required this.startX,
    required this.startY,
    required this.controlX,
    required this.controlY,
    required this.endX,
    required this.endY,
  });

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Opacity giảm dần
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeOut), //easeOut , easeInOut
    );

    // Kích thước emoji nhỏ dần
    _sizeAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Hiệu ứng thay đổi vị trí (Bezier Curve)
    _positionAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(widget.startX, widget.startY),
          end: Offset(widget.controlX, widget.controlY),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(widget.controlX, widget.controlY),
          end: Offset(widget.endX, widget.endY),
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: GradientGeneratorFunctions.generateRandomColor(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionalTranslation(
          translation: _positionAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _sizeAnimation.value / 50,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _colorAnimation.value ?? Colors.white,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  widget.imagePath,
                  width: _sizeAnimation.value,
                  height: _sizeAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

```

---


### Widgets\livestream_comment_list_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/display_gif_widget.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/agora_livestreaming_controller.dart';

class LiveStreamCommentListWidget extends StatelessWidget {
  final ThemeData theme;
  final AgoraLivestreamController livestreamController;
  const LiveStreamCommentListWidget(
      {super.key, required this.theme, required this.livestreamController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        width: 300,
        child: Obx(() => livestreamController.comments.isNotEmpty
            ? ListView.builder(
                clipBehavior: Clip.none,
                controller: livestreamController.scrollController,
                itemCount: livestreamController.comments.toList().length,
                itemBuilder: (context, index) {
                  final comment = livestreamController.comments[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarUserWidget(
                          radius: 25,
                          imagePath: comment['photoUrl']!,
                          borderThickness: 2,
                          
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['name']!,
                                  style: theme.textTheme.bodyLarge!),
                              Text(
                                comment["content"]!,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(color: Colors.white),
                              ),
                              comment["gif"] != null || comment["gif"] ==""
                                  ? DisplayGifWidget(gifUrl: comment["gif"]!)
                                  : const SizedBox(),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        TimeFunctions.timeAgo(
                                            now: DateTime.now(),
                                            createdAt: DateTime.parse(
                                                comment['createdAt']!)),
                                        style: theme.textTheme.bodySmall!
                                            .copyWith(color: Colors.blueGrey)),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.thumb_up_alt_rounded,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        )),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.thumb_down_alt_rounded,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        )),
                                    IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.reply_all_rounded,
                                          size: 25,
                                          color: Colors.white,
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
            : const SizedBox()));
  }
}

```

---
