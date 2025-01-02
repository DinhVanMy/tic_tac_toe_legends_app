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
                          gradientColors: const [
                            Colors.lightBlueAccent,
                            Colors.lightGreenAccent
                          ],
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
