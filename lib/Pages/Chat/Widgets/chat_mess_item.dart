import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/text_to_speech_controller.dart';
import 'package:tictactoe_gameapp/Data/gemini_api_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/hyperlink_text_function.dart';
import 'package:tictactoe_gameapp/Models/gemini_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/chat_friend_item.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatController chatController;
  final TextToSpeechController ttsController;
  final Message message;
  final UserModel user;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.user,
    required this.ttsController,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (!message.isUser)
          const CircleAvatar(
            backgroundImage: AssetImage(GifsPath.chloe1),
          ),
        if (!message.isUser) const SizedBox(width: 5),
        Flexible(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onLongPress: () async => await Clipboard.setData(
                        ClipboardData(text: message.content))
                    .then(
                  (value) => successMessage('Copied to Clipboard'),
                ),
                child: ChatBubble(
                  alignment:
                      message.isUser ? Alignment.topRight : Alignment.topLeft,
                  clipper: ChatBubbleClipper8(
                      type: message.isUser
                          ? BubbleType.sendBubble
                          : BubbleType.receiverBubble),
                  padding: const EdgeInsets.all(0),
                  margin: const EdgeInsets.only(top: 20),
                  backGroundColor: _checkColors().first,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: _checkColors(),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BubbleBackground(
                        colors: _checkColors(),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: message.isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                final displayedText =
                                    message.displayedWords.join(' ');
                                return SelectableText.rich(
                                  TextSpan(
                                    children:
                                        HyperlinkTextFunction.buildMessageText(
                                      context,
                                      text: message.isUser
                                          ? message.content
                                          : displayedText,
                                      color: Colors.blueAccent,
                                      colors: _checkColors(),
                                      previewUrlMode: true,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                );
                              }),
                              message.imagePath != null
                                  ? SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.file(
                                        File(
                                          message.imagePath!,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox(),
                              const SizedBox(height: 5),
                              Text(
                                message.timestamp
                                    .toLocal()
                                    .toString()
                                    .split(' ')[1]
                                    .substring(0, 5),
                                style: const TextStyle(
                                    color: Colors.blueGrey, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              message.isUser
                  ? const SizedBox()
                  : Positioned(
                      bottom: 3,
                      right: 3,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async => await Clipboard.setData(
                                    ClipboardData(text: message.content))
                                .then(
                              (value) => successMessage('Copied to Clipboard'),
                            ),
                            icon: const Icon(
                              Icons.content_copy_rounded,
                              color: Colors.grey,
                              size: 25,
                            ),
                          ),
                          Obx(() {
                            final data = ttsController
                                .getIconAndCallback(message.content);
                            return IconButton(
                              onPressed: data["callback"],
                              icon: Icon(
                                data["icon"],
                                color: Colors.grey,
                                size: 25,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        // if (message.isUser) const SizedBox(width: 5),
        // if (message.isUser)
        //   CircleAvatar(
        //     child: user.image != null && user.image!.isNotEmpty
        //         ? CircleAvatar(
        //             backgroundImage: CachedNetworkImageProvider(user.image!),
        //             maxRadius: 55,
        //           )
        //         : const Icon(Icons.person_2_outlined),
        //   )
      ],
    );
  }

  List<Color> _checkColors() {
    if (message.isUser) {
      return [
        Colors.lightBlue,
        Colors.lightBlueAccent,
      ];
    } else {
      return [Colors.greenAccent, Colors.lightGreenAccent];
    }
  }
}
