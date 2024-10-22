import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';

class FriendsNotificationsPage extends StatelessWidget {
  final ThemeData theme;
  final NotifyInMainController notifyInMainController;
  final FirestoreController firestoreController;
  const FriendsNotificationsPage(
      {super.key,
      required this.theme,
      required this.notifyInMainController,
      required this.firestoreController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: notifyInMainController.filteredFriendRequests.length,
        itemBuilder: (context, index) {
          var friendRequests =
              notifyInMainController.filteredFriendRequests.toList();
          var friendRequest = friendRequests[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      friendRequest.senderModel!.image!),
                  radius: 35,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friendRequest.senderModel!.name!,
                          style: theme.textTheme.bodyLarge),
                      const Text(
                        "have sent a friend request",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    friendRequest.timestamp == null
                        ? const Text(
                            "12:14 AM",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 13,
                            ),
                          )
                        : Text(
                            firestoreController
                                .displayTime(friendRequest.timestamp!),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 13,
                            ),
                          ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await notifyInMainController
                                .deleteFriendRequest(friendRequest.id!);
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.redAccent,
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await firestoreController.addFriend(
                                friendRequest.senderId!,
                                friendRequest.receiverId!);
                            await firestoreController.addFriend(
                                friendRequest.receiverId!,
                                friendRequest.senderId!);
                            await notifyInMainController
                                .deleteFriendRequest(friendRequest.id!);
                          },
                          icon: const Icon(
                            Icons.done_outline_outlined,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        },
      );
    });
  }
}
