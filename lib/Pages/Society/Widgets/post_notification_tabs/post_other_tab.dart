import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_controller.dart';

class PostOthersTab extends StatelessWidget {
  final PostNotificationController postNotificationController;
  final UserModel user;
  final ThemeData theme;
  const PostOthersTab(
      {super.key,
      required this.postNotificationController,
      required this.theme,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (postNotificationController.sharedNotifications.isEmpty) {
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
        var sharedNotifications =
            postNotificationController.sharedNotifications.toList();
        return ListView.builder(
          itemCount: sharedNotifications.length,
          itemBuilder: (context, index) {
            var sharedNotification = sharedNotifications[index];
            var shareUser = sharedNotification.senderModel!;
            return Material(
              color: sharedNotification.isReaded!
                  ? Colors.transparent
                  : Colors.lightBlueAccent.shade100,
              child: InkWell(
                splashColor: Colors.white,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(shareUser.image!),
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
                                Icons.share,
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
                                      sharedNotification.timestamp!.toDate()),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              sharedNotification.message!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              "post : ${sharedNotification.postId!}",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
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
        );
      }
    });
  }
}
