import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_tabs/post_comment_tab.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_tabs/post_like_tab.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_tabs/post_other_tab.dart';

class PostNotificationPage extends StatelessWidget {
  final UserModel user;
  const PostNotificationPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PostNotificationController postNotificationController =
        Get.put(PostNotificationController(user.id!));
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 35,
            color: Colors.black,
          ),
        ),
        title: Text(
          "Notifications",
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              int indexTab = postNotificationController.tabController.index;
              if (indexTab == 0) {
                await postNotificationController.markAllAsReadByType("like");
              } else if (indexTab == 1) {
                await postNotificationController.markAllAsReadByType("comment");
              } else {
                await postNotificationController.markAllAsReadByType("share");
              }
            },
            icon: const Icon(
              Icons.done_all_rounded,
              size: 35,
              color: Colors.blueAccent,
            ),
          ),
          IconButton(
            onPressed: () {
              postNotificationController.loadMoreNotifications();
            },
            icon: const Icon(
              Icons.refresh_rounded,
              size: 35,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: postNotificationController.tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            splashBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            indicatorWeight: 5,
            indicatorColor: Colors.white,
            tabs: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Text(
                  "Interacts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Text(
                  "Comments",
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Text(
                  "Others",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: postNotificationController.tabController,
                children: [
                  PostLikeTab(
                    postNotificationController: postNotificationController,
                    theme: theme,
                    user: user,
                  ),
                  PostCommentTab(
                    postNotificationController: postNotificationController,
                    theme: theme,
                    user: user,
                  ),
                  PostOthersTab(
                    postNotificationController: postNotificationController,
                    theme: theme,
                    user: user,
                  ),
                ]),
          )
        ],
      ),
    );
  }
}
