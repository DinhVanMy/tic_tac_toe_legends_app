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
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImagePath.welcome1),
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
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImagePath.welcome2),
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
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImagePath.welcome3,
            ),
            const Text(
              "Earn points for each game and make your way to top the scoreboard!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            TextButton(
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
        colors: const [Colors.red, Colors.blue, Colors.green],
        itemCount: 3,
        physics: const BouncingScrollPhysics(),
        onFinish: () {
          // print("Completetd");
          // Get.offAll(AuthPage());
        },
        itemBuilder: (index) {
          return pages[index];
        },
      ),
    );
  }
}
