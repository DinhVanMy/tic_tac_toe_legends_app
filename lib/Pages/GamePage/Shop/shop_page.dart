import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/champions_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/emotes_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/maps_page.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.person_4), text: 'Champions'),
                Tab(icon: Icon(Icons.map), text: 'Maps'),
                Tab(icon: Icon(Icons.emoji_emotions), text: 'Emotes'),
                Tab(icon: Icon(Icons.emoji_events), text: '?'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ChampionsPage(),
                  MapsPage(),
                  EmotesPage(),
                  EmotesPage(),
                  // EmotesPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
