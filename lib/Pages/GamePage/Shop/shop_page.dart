import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/champions_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/emotes_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/Widgets/maps_page.dart';
import 'package:tictactoe_gameapp/Components/customized_widgets/draggble_fab_widget.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 30,
              )),
          title: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person_4), text: 'Champions'),
              Tab(icon: Icon(Icons.map), text: 'Maps'),
              Tab(icon: Icon(Icons.emoji_emotions), text: 'Emotes'),
              Tab(icon: Icon(Icons.emoji_events), text: '?'),
            ],
          ),
        ),
        body: Stack(
          children: [
            const TabBarView(
              children: [
                ChampionsPage(),
                MapsPage(),
                EmotesPage(),
                EmotesPage(),
                // EmotesPage(),
              ],
            ),
            DraggableFloatingActionButton(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(GifsPath.chloe1)),
            ),
            // DraggableFloatingActionButton(
            //   child: const Icon(
            //     Icons.shopping_cart_rounded,
            //     color: Colors.white,
            //     size: 30,
            //   ),
            //   onPressed: () {
            //     printInfo(info: "hi");
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
