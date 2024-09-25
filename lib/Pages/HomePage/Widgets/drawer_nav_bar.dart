import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/cham_ranking_drawer.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/player_ranking_drawer.dart';

class DrawerNavBar extends StatelessWidget {
  const DrawerNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final FirestoreController firestoreController =
        Get.put(FirestoreController());
    final user = profileController.readProfileNewUser();
    RxInt expandedIndex = (-1).obs;
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  GifsPath.lightGif,
                ),
                Positioned(
                  bottom: 0,
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.blue,
                                width: 5,
                                style: BorderStyle.solid),
                            shape: BoxShape.circle),
                        child: user.image != null && user.image!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(user.image!),
                                maxRadius: 55,
                              )
                            : const Icon(Icons.person_2_outlined),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        user.name ?? "Anonymous",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      ),
                      const Divider(
                        color: Colors.blueGrey,
                      ),
                      Text(
                        "Email: ${user.email ?? "${user.name}@gmail.com"}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurpleAccent, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    ImagePath.welcome3,
                    width: 70,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "RANKING",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tic Tac Toe",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.person), text: 'Players'),
                Tab(icon: Icon(Icons.leaderboard), text: 'Champions'),
              ],
            ),
            Expanded(
                child: TabBarView(
              children: [
                RankingPlayerPage(
                    profileController: profileController,
                    firestoreController: firestoreController,
                    user: user,
                    expandedIndex: expandedIndex),
                RankingChampionPage(
                    profileController: profileController,
                    firestoreController: firestoreController,
                    user: user,
                    expandedIndex: expandedIndex),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
