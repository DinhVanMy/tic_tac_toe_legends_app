import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_controller.dart';

class PostCommentTab extends StatelessWidget {
  final PostNotificationController postNotificationController;
  final UserModel user;
  final ThemeData theme;
  const PostCommentTab(
      {super.key,
      required this.postNotificationController,
      required this.theme,
      required this.user});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Obx(() {
      if (postNotificationController.commentNotifications.isEmpty) {
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
      } else {
        var commentNotifications =
            postNotificationController.commentNotifications.toList();
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              postNotificationController.loadMoreNotifications();
            }
            return true;
          },
          child: ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: commentNotifications.length,
            itemBuilder: (context, index) {
              var commentNotification = commentNotifications[index];
              var commentUser = commentNotification.senderModel!;
              return Material(
                color: commentNotification.isReaded!
                    ? Colors.transparent
                    : Colors.lightBlueAccent.shade100,
                child: InkWell(
                  splashColor: Colors.white,
                  onTap: () {
                    postNotificationController
                        .markAsRead(commentNotification.id!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  commentUser.image!),
                              radius: 25,
                            ),
                            Positioned(
                              bottom: -10,
                              right: -10,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                ),
                                child: const Icon(
                                  Icons.thumb_up,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TimeFunctions.timeAgo(
                                  now: DateTime.now(),
                                  createdAt:
                                      commentNotification.timestamp!.toDate(),
                                ),
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                commentNotification.message!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                ImagePath.board_9x9,
                                width: 50,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}
