import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Configs/assets_path.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var pages = [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.background1),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const Text(
              "Most fun game now available on your smartphone device!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Image.asset(ImagePath.welcome1, width: 100),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.background1),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Compete",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const Text(
              "Play online with your friends and top the leaderboard!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            Image.asset(ImagePath.welcome2, width: 100),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.background3),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              ImagePath.welcome3,
              width: 100,
            ),
            const Text(
              "Earn points for each game and make your way to top the scoreboard!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed("/auth");
              },
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: ConcentricPageView(
        colors: const [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
        ],
        itemCount: 3,
        physics: const BouncingScrollPhysics(),
        onFinish: () {
          Get.offAllNamed("/auth");
        },
        itemBuilder: (index) {
          return pages[index];
        },
      ),
    );
  }
}
