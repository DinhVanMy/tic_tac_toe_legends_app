import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Test/game_history/Widgets/tictactoe_history_widget.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<ProfileController>().user!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 30,
            color: Colors.blue,
          ),
        ),
        centerTitle: false,
        title: Row(
          children: [
            AvatarUserWidget(
              radius: 25,
              imagePath: user.image!,
              gradientColors: user.avatarFrame,
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Orbitron",
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      TrimRanking.diamondTrim,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      "Diamond II",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: "Orbitron",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.bar_chart_rounded,
              size: 30,
              color: Colors.blue,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border_rounded,
              size: 30,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.blueAccent,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Orbitron",
                ),
                tabs: [
                  Tab(
                      icon: Image.asset(
                        ImagePath.board_3x3,
                        width: 30,
                      ),
                      text: 'TicTacToe'),
                  Tab(
                      icon: Image.asset(
                        ImagePath.board_6x6,
                        width: 30,
                      ),
                      text: 'Sudoku'),
                  Tab(
                      icon: Image.asset(
                        ImagePath.board_9x9,
                        width: 30,
                      ),
                      text: 'Match3'),
                  Tab(
                      icon: Image.asset(
                        ImagePath.board_11x11,
                        width: 30,
                      ),
                      text: 'Minesweeper'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    TictactoeHistoryWidget(),
                    TictactoeHistoryWidget(),
                    TictactoeHistoryWidget(),
                    TictactoeHistoryWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
