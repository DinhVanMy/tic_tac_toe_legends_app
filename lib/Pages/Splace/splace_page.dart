import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import '../../Controller/splace_controller.dart';

class SplacePage extends StatelessWidget {
  const SplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SplaceController splaceController = Get.put(SplaceController());
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
                    child: Image.asset(GifsPath.chatbotGif),
                  ),
                ),
                const SizedBox(height: 30),
                Obx(
                  () => _buildProgressBar(
                    splaceController.progress.value,
                    Colors.blue,
                    Colors.grey,
                  ),
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
                  Image.asset(GifsPath.cyberpunk),
                  const SizedBox(height: 30),
                  Obx(
                    () => _buildProgressBar(
                      splaceController.progress.value,
                      Colors.lightBlueAccent,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildProgressBar(double progress, Color fillColor, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 300,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [bgColor.withOpacity(0.3), bgColor.withOpacity(0.1)],
            ),
            boxShadow: [
              BoxShadow(
                color: fillColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 300 * progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [fillColor, fillColor.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${(progress * 100).toInt()}%", // Hiển thị số nguyên
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: fillColor,
            fontFamily: "Orbitron",
            shadows: [
              Shadow(
                color: fillColor.withOpacity(0.8),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
