import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/main_home_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';
import 'package:tictactoe_gameapp/Controller/check_network_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Bottom/button_nav_bar_curve.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainHomeController controller = Get.put(MainHomeController());
    final BackgroundMusicController effectiveMusicController = Get.find();

    //todo check network
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Get.put(CheckNetworkController(), permanent: true);
    // });
    return Scaffold(
      body: Obx(() {
        final currentPage = controller.pages[controller.currentIndex.value];

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 750),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Apply different transition effects based on currentIndex
            if (controller.currentIndex.value < 2) {
              // For the first two pages, use Left to Right transition
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0), // From Left to Right
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            } else if (controller.currentIndex.value > 2) {
              // For the last two pages, use Right to Left transition
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0), // From Right to Left
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            } else {
              // For the middle page, use Down to Up transition
              // return SlideTransition(
              //   position: Tween<Offset>(
              //     begin: const Offset(0.0, 1.0), // From Bottom to Top
              //     end: Offset.zero,
              //   ).animate(animation),
              //   child: child,
              // );
              return ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0, // Bắt đầu nhỏ hơn một chút
                  end: 1.0, // Kết thúc với kích thước bình thường
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                )),
                child: child,
              );
            }
          },
          child: currentPage,
        );
      }),
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: controller.currentIndex.value,
        onTabChanged: (value) async {
          // await effectiveMusicController.buttonSoundEffect();
          controller.currentIndex.value = value;
        },
      ),
    );
  }
}
