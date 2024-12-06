import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/text_to_speech_controller.dart';
import 'package:tictactoe_gameapp/Models/gemini_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ChatMessageItem extends StatelessWidget {
  final TextToSpeechController ttsController;
  final Message message;
  final UserModel user;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.user,
    required this.ttsController,
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
            backgroundImage: AssetImage(GifsPath.androidGif),
          ),
        if (!message.isUser) const SizedBox(width: 10),
        Flexible(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: message.isUser
                        ? [
                            Colors.lightBlue,
                            Colors.lightBlueAccent,
                          ]
                        : [Colors.greenAccent, Colors.lightGreenAccent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(color: Colors.black),
                    ),
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
                      style:
                          const TextStyle(color: Colors.blueGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              message.isUser
                  ? const SizedBox()
                  : Positioned(
                      bottom: 3,
                      right: 3,
                      child: Obx(() {
                        final data =
                            ttsController.getIconAndCallback(message.content);
                        return IconButton(
                          onPressed: data["callback"],
                          icon: Icon(
                            data["icon"],
                            color: Colors.grey,
                            size: 30,
                          ),
                        );
                      }),
                    ),
            ],
          ),
        ),
        if (message.isUser) const SizedBox(width: 10),
        if (message.isUser)
          CircleAvatar(
            child: user.image != null && user.image!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.image!),
                    maxRadius: 55,
                  )
                : const Icon(Icons.person_2_outlined),
          )
      ],
    );
  }
}
