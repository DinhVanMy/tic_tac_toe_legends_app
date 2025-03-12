import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/preview_gif_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/chat_friend_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/permission_handle_functions.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/agora_call_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/background_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/chat_friend_item.dart';
import 'package:tictactoe_gameapp/Components/emotes_picker_widget.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';
import 'package:uuid/uuid.dart';

class ChatWithFriendPage extends StatelessWidget {
  final NotifyInMainController notifyInMainController;
  final UserModel userFriend;
  const ChatWithFriendPage({
    super.key,
    required this.userFriend,
    required this.notifyInMainController,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextEditingController textController = TextEditingController();
    final FirestoreController firestoreController =
        Get.find<FirestoreController>();
    final ProfileController profileController = Get.find<ProfileController>();
    RxString imagePath = "".obs;
    var selectedGif = Rx<GiphyGif?>(null);
    XFile? image;
    final chatController = Get.put(ChatFriendController(
      firestoreController.userId,
      userFriend.id!,
    ));

    RxBool isEmojiPickerVisible = false.obs;

    return Obx(() {
      var themColors = chatController.chatSettings.value.themeColors;
      var backgroundColors = [Colors.transparent, Colors.transparent];
      if (themColors != null) {
        backgroundColors = themColors
            .map((hex) => ColorStringReverseFunction.hexToColor(hex))
            .toList();
      } else {
        backgroundColors = [Colors.transparent, Colors.transparent];
      }
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.deepPurpleAccent,
                size: 35,
              )),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              Get.to(
                  UserAboutPage(
                    unknownableUser: userFriend,
                  ),
                  transition: Transition.leftToRightWithFade);
            },
            child: Row(
              children: [
                Hero(
                  tag: 'friendAvatar-${userFriend.id}',
                  transitionOnUserGestures: true,
                  child: AvatarUserWidget(
                      radius: 25, imagePath: userFriend.image!),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userFriend.name!, style: theme.textTheme.bodyLarge),
                      userFriend.lastActive == null
                          ? Text(
                              "${userFriend.status ?? "Online"} 1 hour ago",
                              style: theme.textTheme.bodySmall!
                                  .copyWith(color: Colors.grey),
                            )
                          : Text(
                              "Online ${TimeFunctions.displayDate(userFriend.lastActive!)} - ${TimeFunctions.displayTimeDefault(userFriend.lastActive!)}",
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: themColors != null
                                    ? Colors.lightGreenAccent
                                    : Colors.blueGrey,
                              ),
                              maxLines: 2,
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
          elevation: 3.0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.call,
                color: Colors.deepPurpleAccent,
                size: 30,
              ),
              onPressed: () async {
                final permissionHandler = PermissionHandleFunctions();
                bool micGranted =
                    await permissionHandler.checkMicrophonePermission();
                if (micGranted == true) {
                  var userCurrent = profileController.user!;
                  var uuid = const Uuid();
                  final String channelId = uuid.v4().substring(0, 12);
                  await notifyInMainController.sendCallInvite(
                    receiverId: userFriend.id!,
                    senderUser: userCurrent,
                    channelId: channelId,
                    isVideoCall: false,
                  );
                  Get.to(
                    () => AgoraCallPage(
                      userFriend: userFriend,
                      userCurrent: userCurrent,
                      channelId: channelId,
                      initialMicState: true,
                      initialVideoState: false,
                    ),
                    transition: Transition.upToDown,
                  );
                } else {
                  errorMessage("Please microphone permission");
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.video_call,
                color: Colors.deepPurpleAccent,
                size: 30,
              ),
              onPressed: () async {
                final permissionHandler = PermissionHandleFunctions();
                bool camGranted =
                    await permissionHandler.checkCameraPermission();
                bool micGranted =
                    await permissionHandler.checkMicrophonePermission();
                if (camGranted == true && micGranted == true) {
                  var userCurrent = profileController.user!;
                  var uuid = const Uuid();
                  final String channelId = uuid.v4().substring(0, 12);
                  await notifyInMainController.sendCallInvite(
                    receiverId: userFriend.id!,
                    senderUser: userCurrent,
                    channelId: channelId,
                    isVideoCall: true,
                  );
                  Get.to(
                    () => AgoraCallPage(
                      userFriend: userFriend,
                      userCurrent: userCurrent,
                      channelId: channelId,
                      initialMicState: true,
                      initialVideoState: true,
                    ),
                    transition: Transition.upToDown,
                  );
                } else {
                  errorMessage("Please camera permission");
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.color_lens_rounded,
                color: Colors.deepPurpleAccent,
                size: 30,
              ),
              onPressed: () async => _openThemeChange(context, chatController),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onLongPress: () async =>
                      _openThemeChange(context, chatController),
                  child: Obx(
                    () => chatController.isEmptyMessage.value
                        ? _buildProfilePreview(theme)
                        : ChatFriendItem(
                            userFriend: userFriend,
                            currentUserId: firestoreController.userId,
                            chatController: chatController,
                            firestoreController: firestoreController,
                            color: backgroundColors,
                            theme: theme,
                          )
                            .animate()
                            .slide(duration: const Duration(milliseconds: 750)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(() {
                if (imagePath.value.isNotEmpty) {
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          imagePath.value = "";
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.deepPurpleAccent,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 120,
                        child: Image.file(
                          File(
                            imagePath.value,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
              PreviewGifWidget(selectedGif: selectedGif),
              Row(
                children: [
                  Obx(() => chatController.isFocused.value
                      ? IconButton(
                          onPressed: () {
                            chatController.focusNode.unfocus();
                          },
                          icon: const Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                        )
                      : Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.blueAccent,
                                size: 30,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.blueAccent,
                                size: 30,
                              ),
                              onPressed: () async {
                                image = await profileController
                                    .pickFileX(ImageSource.camera);
                                if (image != null) {
                                  imagePath.value = image!.path;
                                } else {
                                  imagePath.value = "";
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.image_rounded,
                                color: Colors.blueAccent,
                                size: 30,
                              ),
                              onPressed: () async {
                                image = await profileController
                                    .pickFileX(ImageSource.gallery);
                                if (image != null) {
                                  imagePath.value = image!.path;
                                } else {
                                  imagePath.value = "";
                                }
                              },
                            ),
                          ],
                        )),
                  Expanded(
                    child: TextField(
                      focusNode: chatController.focusNode,
                      controller: textController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                        labelText: 'Message',
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
                                    borderRadius: BorderRadius.circular(100),
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
                        icon: Icon(
                          imagePath.value.isEmpty
                              ? Icons.send_sharp
                              : Icons.image_search,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        onPressed: () async {
                          if (imagePath.value.isEmpty) {
                            if (textController.text.isNotEmpty) {
                              await chatController.sendMessage(
                                textController.text,
                                selectedGif.value?.images.original!.url!,
                              );

                              selectedGif.value = null;
                              textController.clear();
                              chatController.focusNode.unfocus();
                            } else {
                              errorMessage("Please enter a message");
                            }
                          } else {
                            await chatController.sendImageMessage(
                              textController.text,
                              image!,
                            );
                            imagePath.value = "";
                            if (textController.text.isNotEmpty) {
                              textController.clear();
                              chatController.focusNode.unfocus();
                            }
                          }
                        },
                      )),
                ],
              ),
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
                backgroundColor: backgroundColors,
              )
            ],
          ),
        ),
      );
    });
  }

  Future<void> _openThemeChange(
      BuildContext context, ChatFriendController chatController) async {
    await GeneralBottomsheetShowFunction.showScrollableGeneralBottomsheet(
      widgetBuilder: (context, controller) => BackgroundListSheet(
        scrollController: controller,
        chatFriendController: chatController,
      ),
      context: context,
      initHeight: 0.9,
    );
  }

  Widget _buildProfilePreview(ThemeData theme) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarUserWidget(radius: 80, imagePath: userFriend.image!),
          const SizedBox(
            height: 10,
          ),
          Text(
            userFriend.name!,
            style: theme.textTheme.headlineLarge!.copyWith(
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Email: ${userFriend.email!}",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            "You are friends on Tic Tac Toe",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total Wins: ${userFriend.totalWins ?? "0"}",
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Total Coins: ${userFriend.totalCoins ?? "0"}",
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Get.to(
                  UserAboutPage(
                    unknownableUser: userFriend,
                  ),
                  transition: Transition.upToDown);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white54,
            ),
            child: Text(
              "View Profile",
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
