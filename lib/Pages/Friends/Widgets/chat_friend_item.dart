import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Data/chat_friend_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/message_friend_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ChatFriendItem extends StatelessWidget {
  final UserModel userFriend;
  final String currentUserId;
  final FirestoreController firestoreController;
  final ChatFriendController chatController;
  final ThemeData theme;

  const ChatFriendItem({
    super.key,
    required this.userFriend,
    required this.currentUserId,
    required this.chatController,
    required this.firestoreController,
    required this.theme,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => chatController.isLoadingMore.value
            ? Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              )
            : const SizedBox()),
        Expanded(
          child: Obx(() {
            if (chatController.filtermessages.isEmpty) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !chatController.isLoadingMore.value) {
                  chatController.loadMessages();
                }
                return true;
              },
              child: Stack(
                children: [
                  ListView.builder(
                    controller: chatController.scrollController,
                    itemCount: chatController.filtermessages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = chatController.filtermessages[index];
                      final isMe =
                          message.senderId == chatController.currentUserId;
                      return _buildMessageBubble(userFriend, message, isMe);
                    },
                  ),
                  SizedBox(
                    height: double.maxFinite,
                    width: double.infinity,
                    child: Obx(
                      () => chatController.isSearching.value
                          ? Positioned(
                              top: 0,
                              child: TextField(
                                onChanged: (value) {
                                  chatController.updateSearchText(value);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Search messages',
                                  labelStyle: theme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.blueGrey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: Colors.blueAccent),
                                  ),
                                  prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.search),
                                  ),
                                  prefixIconColor: Colors.blueGrey,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
      UserModel userFriend, MessageFriendModel message, bool isMe) {
    return GestureDetector(
      onTap: () {
        _showMessageActions(message, chatController);
      },
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userFriend.image!),
              radius: 25,
            ),
          if (!isMe) const SizedBox(width: 10),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: message.imagePath != null && message.imagePath != ""
                    ? Colors.transparent
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: isMe
                      ? [
                          Colors.lightBlue,
                          Colors.lightBlueAccent,
                        ]
                      : [Colors.greenAccent, Colors.lightGreenAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content!,
                    style: const TextStyle(color: Colors.black),
                  ),
                  message.imagePath != null && message.imagePath != ""
                      ? Image.memory(
                          base64Decode(
                            message.imagePath!,
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 5),
                  Text(
                    TimeFunctions.displayTime(message.timestamp!),
                    style:
                        const TextStyle(color: Colors.blueGrey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 5),
        ],
      ),
    );
  }

  void _showMessageActions(
    MessageFriendModel message,
    ChatFriendController chatController,
  ) {
    Get.bottomSheet(
      Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                    onPressed: () {
                      // chatController.sendMessage(
                      //     'Replying to: ${message.messageId}',
                      //     replyToMessageId: message.messageId);
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.reply,
                      size: 35,
                      color: Colors.blueAccent,
                    )),
                const Text('Reply'),
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () async {
                      await chatController.deleteMessage(message.messageId!);
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 35,
                      color: Colors.blueAccent,
                    )),
                const Text('Delete'),
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {
                      chatController.shareMessage(
                          message.content!, 'targetUserId');
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.share,
                      size: 35,
                      color: Colors.blueAccent,
                    )),
                const Text('Share'),
              ],
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.menu,
                      size: 35,
                      color: Colors.blueAccent,
                    )),
                const Text('Menu'),
              ],
            ),
          ],
        ),
      ),
      elevation: 5.0,
    );
  }
}
