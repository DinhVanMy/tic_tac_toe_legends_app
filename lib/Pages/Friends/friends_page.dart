import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/webview_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/friends_group_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/friends_home_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/friends_notifications_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Drawer/drawer_nav_bar.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final WebViewControllers controller = Get.put(WebViewControllers());
    final NotifyInMainController notifyInMainController =
        controller.notifyInMainController;
    final FirestoreController firestoreController =
        Get.put(FirestoreController());
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.readProfileNewUser();
    return Scaffold(
      drawer: DrawerNavBar(
        firestoreController: firestoreController,
        profileController: profileController,
        user: user,
        notifyInMainController: notifyInMainController,
      ),
      appBar: AppBar(
        title: Text(
          "Friends",
          style: theme.textTheme.headlineLarge,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Builder(builder: (context) {
                  return TextField(
                    onChanged: (value) {
                      int indexTab = DefaultTabController.of(context).index;
                      if (indexTab == 0) {
                        firestoreController.updateSearchText(value);
                      } else if (indexTab == 1) {
                        print("Searching... groups");
                      } else if (indexTab == 2) {
                        notifyInMainController.updateSearchText(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Searching',
                      labelStyle: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      prefixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.search),
                      ),
                      prefixIconColor: Colors.blueGrey,
                    ),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: CircleAvatar(
                              backgroundImage:
                                  CachedNetworkImageProvider(user.image!),
                              radius: 40,
                            ),
                          ),
                          const Text(
                            "Your Story",
                            style: TextStyle(color: Colors.deepPurple),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Obx(
                      () {
                        if (firestoreController.friendsList.isEmpty) {
                          return const SizedBox();
                        }
                        var friends = firestoreController.friendsList.toList();
                        return Expanded(
                          child: SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: friends.length,
                              itemBuilder: (context, index) {
                                var friend = friends[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    friend.image!),
                                            radius: 35,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        friend.name!,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                TabBar(
                  labelColor: Colors.blueAccent,
                  indicatorColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.grey,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: theme.textTheme.bodyLarge,
                  tabs: const [
                    Tab(text: 'Home'),
                    Tab(text: 'Groups'),
                    Tab(text: 'Notes'),
                  ],
                ),
                SizedBox(
                  height: 1000,
                  child: TabBarView(children: [
                    FriendsHomePage(
                      firestoreController: firestoreController,
                      theme: theme,
                    ),
                    const FriendsGroupPage(),
                    FriendsNotificationsPage(
                      theme: theme,
                      notifyInMainController: notifyInMainController,
                      firestoreController: firestoreController,
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
