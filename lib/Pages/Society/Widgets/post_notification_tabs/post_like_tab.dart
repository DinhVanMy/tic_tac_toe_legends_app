import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_tabs/edit_notify_bottomsheet.dart';

class PostLikeTab extends StatelessWidget {
  final PostNotificationController postNotificationController;
  final UserModel user;
  final ThemeData theme;
  const PostLikeTab(
      {super.key,
      required this.postNotificationController,
      required this.theme,
      required this.user});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Obx(() {
      if (postNotificationController.likeNotifications.isEmpty) {
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
        var likeNotifications =
            postNotificationController.likeNotifications.toList();
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
            itemCount: likeNotifications.length,
            itemBuilder: (context, index) {
              var likeNotification = likeNotifications[index];
              var likeUser = likeNotification.senderModel!;
              return Material(
                color: likeNotification.isReaded!
                    ? Colors.transparent
                    : Colors.lightBlueAccent.shade100,
                child: InkWell(
                  splashColor: Colors.white,
                  onTap: () async {
                    await postNotificationController
                        .markAsRead(likeNotification.id!);
                    Get.to(
                        UserAboutPage(
                          unknownableUser: likeUser,
                        ),
                        transition: Transition.leftToRightWithFade);
                  },
                  onLongPress: () async {
                    await postNotificationController
                        .checkIsNotifed(likeNotification.postId!);
                    await GeneralBottomsheetShowFunction
                        .showScrollableGeneralBottomsheet(
                      widgetBuilder: (context, controller) =>
                          EditNotifyBottomsheet(
                        likeNotification: likeNotification,
                        scrollController: controller,
                        postNotificationController: postNotificationController,
                      ),
                      context: context,
                      initHeight: 0.5,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarUserWidget(
                                radius: 25, imagePath: likeUser.image!),
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
                                      likeNotification.timestamp!.toDate(),
                                ),
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                likeNotification.message!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                "post : ${likeNotification.postId!}",
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
          ),
        );
      }
    });
  }
}
