import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class RankingPlayerPage extends StatelessWidget {
  final ProfileController profileController;
  final FirestoreController firestoreController;
  final UserModel user;
  final RxInt expandedIndex;
  const RankingPlayerPage(
      {super.key,
      required this.profileController,
      required this.firestoreController,
      required this.user,
      required this.expandedIndex});

  @override
  Widget build(BuildContext context) {
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
                    collapsedBackgroundColor: users.name == user.name
                        ? Colors.purpleAccent.withOpacity(0.5)
                        : Colors.lightBlueAccent,
                    backgroundColor: users.name == user.name
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
                          SvgPicture.asset(
                            IconsPath.wonIcon,
                            width: 40,
                            color: index == 1
                                ? Colors.redAccent
                                : index == 2
                                    ? Colors.yellowAccent
                                    : index == 3
                                        ? Colors.greenAccent
                                        : Colors.white,
                          ),
                          Text(
                            "${users.totalWins} wins",
                            style: TextStyle(
                              fontSize: 10,
                              color: index == 1
                                  ? Colors.redAccent
                                  : index == 2
                                      ? Colors.yellowAccent
                                      : index == 3
                                          ? Colors.greenAccent
                                          : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      children: [
                        const Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.lightGreenAccent,
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
                                ? CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                        users.image!),
                                    radius: 25,
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
                                    fontSize: 20,
                                  ),
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
                      Row(
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
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add_alt_sharp),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.messenger_outline_sharp),
                          ),
                        ],
                      )
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
