import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/display_gif_widget.dart';
import 'package:tictactoe_gameapp/Components/shimmers/messages_placeholder_widget.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Configs/paint_draws/bubble_chat_painter.dart';
import 'package:tictactoe_gameapp/Data/chat_friend_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/hyperlink_text_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/message_friend_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ChatFriendItem extends StatelessWidget {
  final UserModel userFriend;
  final String currentUserId;
  final FirestoreController firestoreController;
  final ChatFriendController chatController;
  final List<Color> color;
  final ThemeData theme;

  const ChatFriendItem({
    super.key,
    required this.userFriend,
    required this.currentUserId,
    required this.chatController,
    required this.firestoreController,
    required this.theme,
    required this.color,
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
            if (chatController.filtermessages.isEmpty &&
                chatController.isLoadingMore.value) {
              return Column(
                children: [
                  ListView.builder(
                    itemCount: 5, // Số lượng placeholder hiển thị
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return const MessagesPlaceholderWidget(
                        isMe: false,
                      );
                    },
                  ),
                  ListView.builder(
                    itemCount: 5, // Số lượng placeholder hiển thị
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return const MessagesPlaceholderWidget(
                        isMe: true,
                      );
                    },
                  ),
                ],
              );
            } else if (chatController.filtermessages.isEmpty) {
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
                      return _buildMessageBubble(
                          context, userFriend, message, isMe, index);
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
    BuildContext context,
    UserModel userFriend,
    MessageFriendModel message,
    bool isMe,
    int index,
  ) {
    // Kiểm tra nếu người gửi tin nhắn trước đó giống người hiện tại
    bool showAvatar = true;
    if (index < chatController.filtermessages.length - 1) {
      final previousMessage = chatController.filtermessages[index + 1];
      if (previousMessage.senderId == message.senderId) {
        showAvatar = false;
      }
    }
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
          if (!isMe && showAvatar)
            AvatarUserWidget(
              radius: 25,
              imagePath: userFriend.image!,
              gradientColors: userFriend.avatarFrame,
            ),
          if (!isMe && !showAvatar) const SizedBox(width: 50),
          Flexible(
            child: ChatBubble(
              alignment: isMe ? Alignment.topRight : Alignment.topLeft,
              clipper: isMe
                  ? ChatBubbleClipper3(type: BubbleType.sendBubble)
                  : ChatBubbleClipper8(type: BubbleType.receiverBubble),
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.only(top: 5),
              backGroundColor: _checkColors(isMe, color).last,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // gradient: LinearGradient(
                  //   colors: _checkColors(isMe, color),
                  // ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BubbleBackground(
                    colors: _checkColors(isMe, color),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          SelectableText.rich(
                            TextSpan(
                              children: HyperlinkTextFunction.buildMessageText(
                                context,
                                text: message.content!,
                                color: _checkColor(isMe: isMe, colors: color),
                                previewUrlMode: true,
                                colors: color,
                              ),
                            ),
                            style: TextStyle(
                              color: _checkColor(isMe: isMe, colors: color),
                            ),
                          ),
                          message.imagePath != null && message.imagePath != ""
                              ? GestureDetector(
                                  onTap: () {
                                    Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(10),
                                        child: GestureDetector(
                                          onTap: () => Get.back(),
                                          child: InteractiveViewer(
                                            boundaryMargin:
                                                const EdgeInsets.all(8),
                                            minScale: 0.0005,
                                            maxScale: 3,
                                            child: Container(
                                              width: double.infinity,
                                              height: 200,
                                              alignment: Alignment.topCenter,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: MemoryImage(
                                                    base64Decode(
                                                      message.imagePath!,
                                                    ),
                                                  ),
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(
                                        message.imagePath!,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          message.gif != null
                              ? DisplayGifWidget(gifUrl: message.gif!)
                              : const SizedBox(),
                          const SizedBox(height: 5),
                          Text(
                            TimeFunctions.displayTime(message.timestamp!),
                            style: TextStyle(
                                color: isMe
                                    ? color.length == 2 &&
                                            color[0] == Colors.transparent &&
                                            color[1] == Colors.transparent
                                        ? Colors.blueGrey.shade600
                                        : Colors.white54
                                    : Colors.blueGrey,
                                fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                    onPressed: () async => await Clipboard.setData(
                                ClipboardData(
                                    text: message.content ?? "https://"))
                            .then(
                          (value) => successMessage('Copied to Clipboard'),
                        ),
                    icon: const Icon(
                      Icons.menu,
                      size: 35,
                      color: Colors.blueAccent,
                    )),
                const Text('Copy'),
              ],
            ),
          ],
        ),
      ),
      elevation: 5.0,
    );
  }

  List<Color> _checkColors(bool isMe, List<Color> colors) {
    if (isMe) {
      if ((colors.length == 2 &&
          colors[0] == Colors.transparent &&
          colors[1] == Colors.transparent)) {
        return [
          Colors.lightBlue,
          Colors.lightBlueAccent,
        ];
      } else {
        return colors;
      }
    } else {
      return [Colors.greenAccent, Colors.lightGreenAccent];
    }
  }

  Color _checkColor({required bool isMe, required List<Color> colors}) {
    if (isMe) {
      if ((colors.length == 2 &&
          colors[0] == Colors.transparent &&
          colors[1] == Colors.transparent)) {
        return Colors.black;
      } else {
        return Colors.white;
      }
    } else {
      return Colors.black;
    }
  }
}

class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    super.key,
    required this.colors,
    this.child,
  });

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubbleChatPainter(
        scrollable: Scrollable.of(context),
        bubbleContext: context,
        colors: colors,
      ),
      child: child,
    );
  }
}
