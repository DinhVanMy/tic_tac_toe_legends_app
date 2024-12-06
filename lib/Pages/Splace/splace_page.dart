import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import '../../Controller/splace_controller.dart';

class SplacePage extends StatelessWidget {
  const SplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplaceController());
    final ThemeController themeController = Get.find<ThemeController>();
    return !themeController.isDarkMode.value
        ? Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      GifsPath.chatbotGif,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const LinearProgressIndicator(
                  color: Colors.blue,
                  backgroundColor: Colors.grey,
                  minHeight: 10,
                ),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(GifsPath.lightGif),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    GifsPath.cyberpunk,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const LinearProgressIndicator(
                    color: Colors.lightBlueAccent,
                    backgroundColor: Colors.white,
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          );
  }
}
