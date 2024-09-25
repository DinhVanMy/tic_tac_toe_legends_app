import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import '../../Controller/splace_controller.dart';

class SplacePage extends StatelessWidget {
  const SplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplaceController());
    return Scaffold(
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
    );
  }
}
