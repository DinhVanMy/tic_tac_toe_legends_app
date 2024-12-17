import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/main_home_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/check_network_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Bottom/bottom_nav_bar.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Bottom/button_nav_bar_curve.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainHomeController controller = Get.put(MainHomeController());
    final MusicController musicController = Get.find();
//todo check network
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Get.put(CheckNetworkController(), permanent: true);
    // });
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTabChanged: (value) {
          // musicController.futuricSoundEffect();
          return controller.currentIndex.value = value;
        },
      ),
    );
  }
}
