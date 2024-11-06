import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Animations/Overlays/profile_tooltip.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Enums/popup_position.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class RankingPlayerPage extends StatelessWidget {
  final ProfileController profileController;
  final FirestoreController firestoreController;
  final UserModel userModel;
  final RxInt expandedIndex;
  final NotifyInMainController notifyInMainController;
  const RankingPlayerPage(
      {super.key,
      required this.profileController,
      required this.firestoreController,
      required this.userModel,
      required this.expandedIndex,
      required this.notifyInMainController});

  @override
  Widget build(BuildContext context) {
    final ProfileTooltip profileTooltip = Get.put(ProfileTooltip());
    return Obx(() {
      if (firestoreController.usersList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      // Sắp xếp danh sách usersList theo totalCoins giảm dần
      var sortedUsersList = firestoreController.usersList.toList();
      sortedUsersList.sort((a, b) {
        int totalCoinsA = int.tryParse(a.totalCoins ?? '0') ?? 0;
        int totalCoinsB = int.tryParse(b.totalCoins ?? '0') ?? 0;
        return totalCoinsB.compareTo(totalCoinsA);
      });
      return Scrollbar(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: sortedUsersList.length,
          itemBuilder: (context, index) {
            final GlobalKey itemKey = GlobalKey();
            var users = sortedUsersList[index];
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3.0,
                        spreadRadius: 5.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    onExpansionChanged: (bool expanded) {
                      if (expanded) {
                        expandedIndex.value = index;
                      } else if (expandedIndex.value == index) {
                        expandedIndex.value = -1;
                      }
                    },
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.pink,
                    collapsedBackgroundColor: users.name == userModel.name
                        ? Colors.purpleAccent.withOpacity(0.5)
                        : Colors.lightBlueAccent,
                    backgroundColor: users.name == userModel.name
                        ? Colors.purpleAccent.withOpacity(0.5)
                        : Colors.lightBlueAccent,
                    leading: Badge(
                      label: Text("${++index}"),
                      textColor: index == 1
                          ? Colors.red
                          : index == 2
                              ? Colors.yellow
                              : index == 3
                                  ? Colors.greenAccent
                                  : Colors.white,
                      backgroundColor: Colors.black,
                      child: Column(
                        children: [
                          Image.asset(
                            index == 1
                                ? TrimRanking.challTrim
                                : index == 2
                                    ? TrimRanking.masterTrim
                                    : index == 3
                                        ? TrimRanking.diamondTrim
                                        : TrimRanking.goldTrim,
                            width: 45,
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      children: [
                        users.status == "online"
                            ? const Text(
                                "Online",
                                style: TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontSize: 15,
                                ),
                              )
                            : const Text(
                                "Offline",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 15,
                                ),
                              ),
                        Obx(
                          () => Icon(
                            expandedIndex.value == index
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            users.image != null && users.image!.isNotEmpty
                                ? GestureDetector(
                                    key: itemKey,
                                    onTap: () {
                                      profileTooltip.showProfileTooltip(
                                        context,
                                        itemKey,
                                        users,
                                        PopupPosition.right,
                                        null,
                                        null,
                                        null,
                                    
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              users.image!),
                                      radius: 25,
                                    ),
                                  )
                                : const Icon(Icons.person_2_outlined),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  users.name!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      users.totalCoins ?? "0",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.yellowAccent,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SvgPicture.asset(
                                      IconsPath.coinIcon,
                                      width: 20,
                                      color: Colors.yellowAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Text(
                        "Email: ${users.email ?? "${users.name}@gmail.com"}",
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      users.name != userModel.name
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 3,
                                      ),
                                    ),
                                    child: Text(
                                      "Chat with ${users.name!}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite_border),
                                ),
                                Obx(() {
                                  bool isFriend = firestoreController
                                      .isFriend(users.id!)
                                      .value;
                                  return isFriend
                                      ? IconButton(
                                          onPressed: () async {
                                            await firestoreController
                                                .removeFriend(users.id!);
                                            errorMessage(
                                                'You removed ${users.name!} from the list of friends');
                                          },
                                          icon: const Icon(
                                              Icons.person_add_disabled_sharp),
                                        )
                                      : IconButton(
                                          onPressed: () async {
                                            // await firestoreController
                                            //     .addFriend(users.id!);
                                            notifyInMainController
                                                .sendFriendRequest(
                                                    users.id!, userModel);
                                            successMessage(
                                                'You added ${users.name!} to the list of friends');
                                          },
                                          icon: const Icon(
                                              Icons.person_add_alt_sharp),
                                        );
                                }),
                                IconButton(
                                  onPressed: () {},
                                  icon:
                                      const Icon(Icons.messenger_outline_sharp),
                                ),
                              ],
                            )
                          : const SizedBox(
                              height: 10,
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}
