import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/message_friend_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/chat_with_friend_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/listen_latest_messages_controller.dart';

class FriendsHomePage extends StatelessWidget {
  final ListenLatestMessagesController listenLatestMessagesController;
  final FirestoreController firestoreController;
  final NotifyInMainController notifyInMainController;
  final ThemeData theme;
  const FriendsHomePage(
      {super.key,
      required this.firestoreController,
      required this.theme,
      required this.listenLatestMessagesController,
      required this.notifyInMainController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (firestoreController.filterfriendsList.isEmpty) {
        return const Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Text(
              "No friends? Add more friends!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }
      var friends = firestoreController.filterfriendsList.toList();
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          var friend = friends[index];
          MessageFriendModel? latestMessage = listenLatestMessagesController
              .latestMessages
              .firstWhereOrNull((msg) =>
                  msg.receiverId == friend.id || msg.senderId == friend.id);

          return Dismissible(
            key: Key(friend.id!),
            direction: DismissDirection.endToStart,
            background: _backgroundDismissible(firestoreController, friend),
            confirmDismiss: (direction) async {
              await Future.delayed(const Duration(seconds: 5));
              return false;
            },
            child: InkWell(
              onTap: () {
                Get.to(ChatWithFriendPage(
                  userFriend: friend,
                  notifyInMainController: notifyInMainController,
                ));
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'friendAvatar-${friend.id}',
                      transitionOnUserGestures: true,
                      child: AvatarUserWidget(
                          radius: 35, imagePath: friend.image!),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(friend.name!, style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 10),
                          latestMessage != null
                              ? Text(latestMessage.content!)
                              : const Text(
                                  "Hello friend ! How are you? ",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    friend.lastActive == null
                        ? const Text(
                            "12:14 AM",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                          )
                        : Text(
                            TimeFunctions.displayTime(friend.lastActive!),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 15,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _backgroundDismissible(
      FirestoreController firestoreController, UserModel friend) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 10),
            const Icon(
              Icons.share,
              color: Colors.blue,
              size: 35,
            ), // Icon share
            const Icon(
              Icons.pin_drop,
              color: Colors.blue,
              size: 35,
            ),
            const Icon(
              Icons.notifications_off,
              color: Colors.blue,
              size: 35,
            ),
            IconButton(
                onPressed: () async {
                  await Get.dialog(
                    AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Do you want to delete this friend?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            firestoreController.removeFriend(friend.id!);
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 35,
                )), // Icon delete
          ],
        ));
  }
}
