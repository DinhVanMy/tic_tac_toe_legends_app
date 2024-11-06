import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/create_post_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/friend_blog_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/world_blog_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';

class SocietyGamingPage extends StatelessWidget {
  const SocietyGamingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final GlobalKey<RefreshIndicatorState> refreshIndicatorState =
        GlobalKey<RefreshIndicatorState>();
    final ProfileController profileController = Get.find<ProfileController>();
    final PostController postController = Get.put(PostController());
    final user = profileController.readProfileNewUser();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      postController.listenToUnreadNotifications(userId: user.id!);
    });
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        postController.scrollToTop();
                        refreshIndicatorState.currentState?.show();
                      },
                      highlightColor: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(10),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 5),
                        ),
                        child: const Text(
                          "SOCIETY",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.to(() => PostNotificationPage(
                                        user: user,
                                      ));
                                },
                                icon: const Icon(
                                  Icons.notifications,
                                  size: 35,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              Obx(() => postController.unreadCount.value == 0
                                  ? const SizedBox()
                                  : Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        height: 25,
                                        width: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.pinkAccent,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                            shape: BoxShape.circle),
                                        child: Text(
                                          postController.unreadCount.value > 99
                                              ? "99+"
                                              : postController.unreadCount.value
                                                  .toString(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ))
                            ],
                          ),
                          IconButton(
                            onPressed: () => Get.to(CreatePostPage(
                              userModel: user,
                              postController: postController,
                            )),
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              size: 35,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.search_rounded,
                              size: 35,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              postController.scrollToTop();
                              refreshIndicatorState.currentState?.show();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 35,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TabBar(
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
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Friend",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "World",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(children: [
                    FriendBlogPage(
                      postController: postController,
                      user: user,
                      theme: theme,
                      refreshIndicatorState: refreshIndicatorState,
                    ),
                    WorldBlogPage(
                      user: user,
                      theme: theme,
                    ),
                  ]),
                )
              ],
            )),
      ),
    );
  }
}
