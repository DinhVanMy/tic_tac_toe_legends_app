// chat_screen.dart
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Animations/dot_matching_animation_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';
import 'package:tictactoe_gameapp/Controller/text_to_speech_controller.dart';
import 'package:tictactoe_gameapp/Data/gemini_api_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/speech_to_text_controller.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/chat_mess_item.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/option_card.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/section_widget.dart';
import 'package:tictactoe_gameapp/Components/customized_widgets/tts_change_setting_widget.dart';
import 'package:tictactoe_gameapp/Components/emotes_picker_widget.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SpeechController speechController = Get.put(SpeechController());
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.user!;
    final ChatController chatController = Get.put(ChatController());
    final TextEditingController textController = TextEditingController();
    final GlobalKey<RefreshIndicatorState> refreshKey =
        GlobalKey<RefreshIndicatorState>();
    final TextToSpeechController ttsController =
        Get.put(TextToSpeechController());
    RxString imagePath = "".obs;
    RxBool isEmojiPickerVisible = false.obs;

    XFile? image;
    double appBarHeight = AppBar().preferredSize.height;
    final MatchingAnimationController matchingAnimationController =
        Get.put(MatchingAnimationController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreenAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(GifsPath.chloe1),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () {
                      return speechController.isListening.value
                          ? IconButton(
                              onPressed: () async {
                                await speechController.stopListening();
                                if (speechController
                                    .lastWords.value.isNotEmpty) {
                                  await chatController.sendPrompt(
                                      speechController.lastWords.value);
                                } else {
                                  await chatController
                                      .sendPrompt("Can you hear me?");
                                }
                              },
                              icon: const Icon(
                                Icons.done_outline_rounded,
                              ),
                            )
                          : IconButton(
                              onPressed: () async {
                                await speechController.startListening();
                              },
                              icon: const Icon(Icons.mic),
                            );
                    },
                  ),
                  Obx(() {
                    return Text(
                      speechController.isListening.value
                          ? "Listening ... 😴 ${speechController.lastWords.value}"
                          : "Chloe",
                      style: Theme.of(context).textTheme.headlineSmall,
                    );
                  }),
                  IconButton(
                    onPressed: () {
                      Get.dialog(
                        Stack(
                          children: [
                            Positioned(
                              top: appBarHeight, // Đặt dialog ngay dưới AppBar
                              left: 0,
                              right: 0,
                              child: Material(
                                child: TtsChangeSettingWidget(
                                  ttsController: ttsController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.keyboard_arrow_down_sharp),
                  ),
                ],
              ),
            ),
            user.image != null && user.image!.isNotEmpty
                ? AvatarUserWidget(radius: 25, imagePath: user.image!)
                : const Icon(Icons.person_2_outlined)
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.white54, Colors.blueGrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Column(
            children: [
              Expanded(
                child: Obx(
                  () => RefreshIndicator(
                    key: refreshKey,
                    backgroundColor: Colors.white,
                    color: Colors.blue,
                    onRefresh: () => chatController.refreshChat(),
                    child: chatController.messages.isEmpty
                        ? SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.white,
                                            spreadRadius: 2.0,
                                            blurRadius: 3.0,
                                            offset: Offset(0, 2.0),
                                          )
                                        ]),
                                    child: AnimatedTextKit(
                                      totalRepeatCount: 1,
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          "Hi ${user.name ?? " "}",
                                          speed:
                                              const Duration(milliseconds: 100),
                                          textStyle: theme
                                              .textTheme.headlineLarge!
                                              .copyWith(
                                                  color: Colors.deepPurple),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const SectionWidget(
                                    options: [
                                      OptionCard(
                                        icon: Icons.article,
                                        title: 'Write an Articles',
                                        description:
                                            'Generate well-written articles on any topic you want.',
                                      ),
                                      OptionCard(
                                        icon: Icons.school,
                                        title: 'Academic Writer',
                                        description:
                                            'Generate educational writing such as essays, reports, etc.',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const SectionWidget(
                                    options: [
                                      OptionCard(
                                        icon: Icons.science,
                                        title: 'Write an Science',
                                        description:
                                            'Generate well-written articles on any topic you want.',
                                      ),
                                      OptionCard(
                                        icon: Icons.favorite,
                                        title: 'Favorite Crusher',
                                        description:
                                            'Generate educational writing such as essays, reports, etc.',
                                      ),
                                    ],
                                  ),
                                  const SectionWidget(
                                    options: [
                                      OptionCard(
                                        icon: Icons.tv,
                                        title: 'Write a Content',
                                        description:
                                            'Generate well-written articles on any topic you want.',
                                      ),
                                      OptionCard(
                                        icon: Icons.image,
                                        title: 'Favorite Images',
                                        description:
                                            'Generate educational writing such as essays, reports, etc.',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo is ScrollUpdateNotification) {
                                    if (chatController
                                            .isOpenedJumpButton.value =
                                        chatController.messages.length > 2) {
                                      chatController.isOpenedJumpButton.value =
                                          true;
                                      chatController.resetHideButtonTimer();
                                    }
                                    if (scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                      if (chatController
                                          .isOpenedJumpButton.value) {
                                        chatController
                                            .isOpenedJumpButton.value = false;
                                      }
                                    }
                                  }
                                  return true;
                                },
                                child: ListView.builder(
                                  controller: chatController.scrollController,
                                  itemCount: chatController.messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        chatController.messages[index];
                                    return ChatMessageItem(
                                      chatController: chatController,
                                      message: message,
                                      user: user,
                                      ttsController: ttsController,
                                    ).animate().slide(
                                        duration:
                                            const Duration(milliseconds: 750));
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Obx(() => chatController
                                        .isOpenedJumpButton.value
                                    ? IconButton(
                                        onPressed: chatController.scrollDown,
                                        icon: const Icon(
                                          Icons.arrow_downward,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Obx(() => chatController.isLoading.value
                                    ? Container(
                                        height: 40,
                                        width: 100,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: Obx(
                                          () {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      matchingAnimationController
                                                          .dotsOffset1.value),
                                                  child: const Icon(
                                                    Icons.circle,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      matchingAnimationController
                                                          .dotsOffset2.value),
                                                  child: const Icon(
                                                    Icons.circle,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Transform.translate(
                                                  offset: Offset(
                                                      0,
                                                      matchingAnimationController
                                                          .dotsOffset3.value),
                                                  child: const Icon(
                                                    Icons.circle,
                                                    color:
                                                        Colors.lightBlueAccent,
                                                    size: 20,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                              )
                            ],
                          ),
                  ),
                ),
              ),
              Obx(() {
                if (imagePath.isNotEmpty) {
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          imagePath.value = "";
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        width: 100,
                        height: 100,
                        child: Image.file(
                          File(
                            imagePath.value,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              CustomEmojiPicker(
                onEmojiSelected: (emoji) {
                  textController.text += emoji;
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
                    textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: textController.text.length),
                    );
                  }
                },
                isEmojiPickerVisible: isEmojiPickerVisible,
                backgroundColor: const [
                  Colors.lightBlue,
                  Colors.lightBlueAccent,
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                        labelText: 'Type your message...',
                        labelStyle: theme.textTheme.bodySmall,
                        prefixIcon: IconButton(
                          onPressed: () async {
                            image = await profileController
                                .pickFileX(ImageSource.gallery);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            image = await profileController
                                .pickFileX(ImageSource.camera);
                            if (image != null) {
                              imagePath.value = image!.path;
                            } else {
                              imagePath.value = "";
                            }
                          },
                          icon: const Icon(Icons.camera_enhance),
                        ),
                      ),
                    ),
                  ),
                  Obx(() => IconButton(
                      onPressed: () {
                        isEmojiPickerVisible.toggle();
                      },
                      icon: isEmojiPickerVisible.value
                          ? const Icon(
                              Icons.emoji_emotions,
                              color: Colors.yellowAccent,
                              size: 30,
                            )
                          : const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.yellowAccent,
                              size: 30,
                            ))),
                  IconButton(
                    onPressed: () {
                      refreshKey.currentState?.show();
                      chatController.refreshChat();
                    },
                    icon: const Icon(
                      Icons.refresh_sharp,
                      size: 30,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  Obx(
                    () => chatController.isLoading.value
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.stop_circle_outlined,
                              size: 30,
                              color: Colors.black,
                            ),
                          )
                        : IconButton(
                            iconSize: 30,
                            icon: imagePath.isNotEmpty
                                ? const Icon(
                                    Icons.image_search_sharp,
                                    color: Colors.deepPurpleAccent,
                                    size: 30,
                                  )
                                : const Icon(
                                    Icons.send_sharp,
                                    color: Colors.deepPurpleAccent,
                                    size: 30,
                                  ),
                            onPressed: () async {
                              final BackgroundMusicController
                                  effectiveMusicController = Get.find();
                              await effectiveMusicController
                                  .digitalSoundEffect();
                              final text = textController.text;
                              if (text.isNotEmpty) {
                                if (imagePath.isNotEmpty) {
                                  //cancel keyboard
                                  FocusScope.of(context).unfocus();
                                  await chatController.sendPromptWithImage(
                                      text, image);
                                  //clear text
                                  textController.clear();
                                  //remove image
                                  imagePath.value = "";
                                } else {
                                  //cancel keyboard
                                  FocusScope.of(context).unfocus();
                                  await chatController.sendPrompt(text);
                                  //clear text
                                  textController.clear();
                                  //remove image
                                  imagePath.value = "";
                                }
                              } else {
                                errorMessage("Please enter your question");
                              }
                            },
                          ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
