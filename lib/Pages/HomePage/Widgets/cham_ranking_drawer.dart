import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Models/champion_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class RankingChampionPage extends StatelessWidget {
  final ProfileController profileController;
  final FirestoreController firestoreController;
  final UserModel user;
  final RxInt expandedIndex;
  const RankingChampionPage(
      {super.key,
      required this.profileController,
      required this.firestoreController,
      required this.user,
      required this.expandedIndex});

  @override
  Widget build(BuildContext context) {
    RxBool isLike = false.obs;
    RxBool isFriend = false.obs;
    return Obx(() {
      if (firestoreController.usersList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Scrollbar(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: listChampions.length,
          itemBuilder: (context, index) {
            var champ = listChampions[index];
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
                        color: Colors.lightBlueAccent,
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
                    collapsedBackgroundColor: Colors.blue[200],
                    leading: Badge(
                      label: Text("${++index}"),
                      textColor: index == 1
                          ? Colors.red
                          : index == 2
                              ? Colors.yellow
                              : index == 3
                                  ? Colors.greenAccent
                                  : Colors.white,
                      backgroundColor: Colors.blue,
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
                            "00 wins",
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
                    trailing: Obx(
                      () => Icon(
                        expandedIndex.value == index
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              champ,
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ChampionModel.capitalize(listChampName[index]),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text(
                                  "Elo: 00",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellowAccent,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Text(
                        ChampionModel.capitalize(listChampName[index]),
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
                              child: const Text(
                                "Chat with hero",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          Obx(() => IconButton(
                                onPressed: () {
                                  isLike.value = !isLike.value;
                                },
                                icon: Icon(isLike.value
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                              )),
                          Obx(() => IconButton(
                                onPressed: () {
                                  isFriend.value = !isFriend.value;
                                },
                                icon: Icon(isFriend.value
                                    ? Icons.person_add_alt_1
                                    : Icons.person_add_alt_1_outlined),
                              )),
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
