import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/chat_friend_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/chat_friend_item.dart';

class ChatWithFriendPage extends StatelessWidget {
  final UserModel userFriend;
  const ChatWithFriendPage({
    super.key,
    required this.userFriend,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextEditingController textController = TextEditingController();
    final FirestoreController firestoreController =
        Get.find<FirestoreController>();
    final ProfileController profileController = Get.find<ProfileController>();
    RxString imagePath = "".obs;
    XFile? image;
    final chatController = Get.put(ChatFriendController(
      firestoreController.userId,
      userFriend.id!,
    ));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.deepPurpleAccent,
              size: 35,
            )),
        title: Row(
          children: [
            Hero(
              tag: 'friendAvatar-${userFriend.id}',
              transitionOnUserGestures: true,
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userFriend.image!),
                radius: 25,
              ),
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
                          style: theme.textTheme.bodySmall!
                              .copyWith(color: Colors.grey),
                          maxLines: 2,
                        ),
                ],
              ),
            )
          ],
        ),
        elevation: 3.0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.call,
              color: Colors.deepPurpleAccent,
              size: 30,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.video_call,
              color: Colors.deepPurpleAccent,
              size: 30,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.info,
              color: Colors.deepPurpleAccent,
              size: 30,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => chatController.isEmptyMessage.value
                  ? _buildProfilePreview(theme)
                  : Expanded(
                      child: ChatFriendItem(
                        userFriend: userFriend,
                        currentUserId: firestoreController.userId,
                        chatController: chatController,
                        firestoreController: firestoreController,
                        theme: theme,
                      ),
                    ),
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
                          IconButton(
                            icon: const Icon(
                              Icons.mic,
                              color: Colors.blueAccent,
                              size: 30,
                            ),
                            onPressed: () {},
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
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      labelText: 'Message',
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.grey),
                      suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Colors.blue,
                            size: 30,
                          )),
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
                            );
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview(ThemeData theme) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userFriend.image!),
            radius: 100,
          ),
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
            onPressed: () {},
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
