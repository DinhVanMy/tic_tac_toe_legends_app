// chat_screen.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/gemini_api_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/speech_to_text_controller.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/chat_mess_item.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/option_card.dart';
import 'package:tictactoe_gameapp/Pages/Chat/Widgets/section_widget.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final SpeechController speechController = Get.put(SpeechController());
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.readProfileNewUser();
    final ChatController chatController = Get.put(ChatController());
    final TextEditingController textController = TextEditingController();
    final GlobalKey<RefreshIndicatorState> refreshKey =
        GlobalKey<RefreshIndicatorState>();
    RxString imagePath = "".obs;
    XFile? image;
    double appBarHeight =
        AppBar().preferredSize.height; // Lấy chiều cao của AppBar
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
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(GifsPath.androidGif),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.volume_up,
                ),
              ),
              Row(
                children: [
                  Obx(() {
                    return Text(
                      speechController.isListening.value
                          ? "Listening ... 😴 ${speechController.lastWords.value}"
                          : "chat ${user.name ?? "Anonymous"}",
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.file(
                                        File(user.image!),
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons
                                              .error); //TODO Hiển thị icon nếu lỗi
                                        },
                                      ),
                                      Image.asset(
                                        GifsPath.chatbotGif,
                                      ),
                                    ],
                                  ),
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
              Obx(
                () {
                  return speechController.isListening.value
                      ? IconButton(
                          onPressed: () async {
                            await speechController.stopListening();
                            if (speechController.lastWords.value.isNotEmpty) {
                              await chatController
                                  .sendPrompt(speechController.lastWords.value);
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
              CircleAvatar(
                child: user.image != null && user.image!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(user.image!),
                        maxRadius: 55,
                      )
                    : const Icon(Icons.person_2_outlined),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
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
                                  child: Text(
                                    "Hi ${user.name ?? " "}",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineLarge!
                                        .copyWith(color: Colors.deepPurple),
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
                            ListView.builder(
                              controller: chatController.scrollController,
                              itemCount: chatController.messages.length,
                              itemBuilder: (context, index) {
                                final message = chatController.messages[index];
                                return ChatMessageItem(
                                  message: message,
                                  user: user,
                                );
                              },
                            ),
                            Center(
                              child: Obx(() => chatController.isLoading.value
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        GifsPath.loadingGif,
                                        height: 200,
                                        width: 200,
                                      ),
                                    )
                                  : const SizedBox()),
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
                return const SizedBox();
              }
            }),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Colors.blueAccent),
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
                          // imagePath.value = await profileController
                          //     .pickImage(ImageSource.camera);
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
                IconButton(
                  onPressed: () {
                    refreshKey.currentState?.show();
                    chatController.refreshChat();
                  },
                  icon: const Icon(
                    Icons.refresh_sharp,
                    size: 30,
                  ),
                ),
                Obx(
                  () => chatController.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.blueGrey,
                        )
                      : IconButton(
                          iconSize: 30,
                          icon: imagePath.isNotEmpty
                              ? const Icon(Icons.image_search_sharp)
                              : const Icon(Icons.send_sharp),
                          onPressed: () async {
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
