import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class EndDrawerLobby extends StatelessWidget {
  final String roomId;
  final UserModel user;
  const EndDrawerLobby({super.key, required this.roomId, required this.user});

  @override
  Widget build(BuildContext context) {
    final FirestoreController firestoreController =
        Get.put(FirestoreController());
    final NotifyInMainController notifyInMainController = Get.find();
    return Drawer(
      width: 250,
      child: Obx(
        () {
          if (firestoreController.friendsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          var friends = firestoreController.friendsList.toList();
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Column(
              children: [
                const Text(
                  'Friends',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      var friend = friends[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                AvatarUserWidget(
                                  radius: 35,
                                  imagePath: friend.image!,
                                  gradientColors: friend.avatarFrame,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    friend.name!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${friend.totalWins ?? "0"} wins",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(
                              () => notifyInMainController.isWaitingForOk.value
                                  ? const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.deepPurple,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        notifyInMainController.sendGameInvite(
                                          friend.id!,
                                          roomId,
                                          user,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
