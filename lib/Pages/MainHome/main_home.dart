import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/main_home_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/bottom_nav_bar.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainHomeController controller = Get.put(MainHomeController());
    final MusicController musicController = Get.find();
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: BottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTabChanged: (value) {
          musicController.futuricSoundEffect();
          return controller.currentIndex.value = value;
        },
      ),
    );
  }
}
