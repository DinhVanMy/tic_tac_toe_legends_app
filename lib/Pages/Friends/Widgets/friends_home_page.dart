import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/chat_with_friend_page.dart';

class FriendsHomePage extends StatelessWidget {
  final FirestoreController firestoreController;
  final ThemeData theme;
  const FriendsHomePage(
      {super.key, required this.firestoreController, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (firestoreController.filterfriendsList.isEmpty) {
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
      }
      var friends = firestoreController.filterfriendsList.toList();
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          var friend = friends[index];
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
                      child: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(friend.image!),
                        radius: 35,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(friend.name!, style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 10),
                          const Text(
                            "You: Hello friend ! How are you? overflow: TextOverflow.ellipsis,overflow: TextOverflow.ellipsis,",
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
