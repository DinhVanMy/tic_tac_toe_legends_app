import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/shimmers/friendavatar_placeholder_widget.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/notification_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/webview_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/messages_widget.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/notes_widget.dart';
import 'package:tictactoe_gameapp/Pages/Friends/listen_latest_messages_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Drawer/drawer_nav_bar.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';

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
    final user = profileController.user!;
    final ListenLatestMessagesController listenLatestMessagesController =
        Get.find();

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
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) {
                          return TextField(
                            onChanged: (value) {
                              int indexTab =
                                  DefaultTabController.of(context).index;
                              if (indexTab == 0) {
                                firestoreController.updateSearchText(value);
                              } else if (indexTab == 1) {
                                notifyInMainController.updateSearchText(value);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Searching',
                              labelStyle: theme.textTheme.bodyLarge!
                                  .copyWith(color: Colors.blueGrey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: Colors.blueAccent),
                              ),
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.search),
                              ),
                              prefixIconColor: Colors.blueGrey,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                AvatarUserWidget(
                                  radius: 40,
                                  imagePath: user.image!,
                                  gradientColors: user.avatarFrame,
                                ),
                                const Text(
                                  "Your Story",
                                  style: TextStyle(color: Colors.deepPurple),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Obx(() {
                            if (firestoreController.isLoadingFriends.value) {
                              return Expanded(
                                child: SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 5, // Số lượng placeholder
                                    itemBuilder: (context, index) {
                                      return const FriendavatarPlaceholderWidget();
                                    },
                                  ),
                                ),
                              );
                            } else {
                              if (firestoreController.friendsList.isEmpty) {
                                return const SizedBox();
                              } else {
                                var friends =
                                    firestoreController.friendsList.toList();
                                return Expanded(
                                  child: SizedBox(
                                    height: 120,
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
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(
                                                          UserAboutPage(
                                                            unknownableUser:
                                                                friend,
                                                          ),
                                                          transition: Transition
                                                              .upToDown);
                                                    },
                                                    child: AvatarUserWidget(
                                                      radius: 35,
                                                      imagePath: friend.image!,
                                                      gradientColors:
                                                          friend.avatarFrame,
                                                    ),
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
                                                            BorderRadius
                                                                .circular(100),
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(friend.name!),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          }),
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
                          Tab(text: 'Chats'),
                          Tab(text: 'News'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              MessagesWidget(
                firestoreController: firestoreController,
                theme: theme,
                listenLatestMessagesController: listenLatestMessagesController,
                notifyInMainController: notifyInMainController,
              ),
              NotesWidget(
                theme: theme,
                notifyInMainController: notifyInMainController,
                firestoreController: firestoreController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
