import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tictactoe_gameapp/Components/primary_with_icon_button.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_bot_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/webview_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/drawer_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final WebViewControllers controller = Get.put(WebViewControllers());
    final user = Get.find<ProfileController>().readProfileNewUser();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);
    final PlayWithBotController playWithBotController =
        Get.put(PlayWithBotController());
    final MusicController musicController = Get.find<MusicController>();

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: const DrawerNavBar(),
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              musicController.boosterSoundEffect();
              scaffoldKey.currentState!.openDrawer();
            },
            child: CircleAvatar(
              radius: 40,
              child: user.image != null && user.image!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.image!),
                      maxRadius: 55,
                    )
                  : const Icon(Icons.person_2_outlined),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 0,
          right: 20,
          left: 20,
          top: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("TIC TAC TOE",
                        style: theme.textTheme.headlineLarge!
                            .copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "With Multiplayer",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // SvgPicture.asset(
            //   IconsPath.applogo,
            //   width: 200,
            // ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                GifsPath.tictactoeGif,
                width: 200,
              ),
            ),
            Column(
              children: [
                PrimaryIconWithButton(
                  buttonText: "Single Player",
                  color: theme.colorScheme.primary,
                  onTap: () {
                    playWithBotController.showMapPicker();
                    // Get.toNamed("/singlePlayer");
                  },
                  iconPath: IconsPath.user,
                ),
                const SizedBox(height: 30),
                PrimaryIconWithButton(
                  buttonText: "Multi Player",
                  color: theme.colorScheme.primary,
                  onTap: () {
                    musicController.swordSoundEffect();
                    Get.toNamed("/room");
                  },
                  iconPath: IconsPath.group,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    musicController.buttonSoundEffect();
                    Get.toNamed("/updateProfile");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.deepOrangeAccent, width: 3),
                    ),
                    child: SvgPicture.asset(
                      IconsPath.info,
                      width: 40,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    musicController.buttonSoundEffect();
                    controller.openWebView(url: url2);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.deepOrangeAccent, width: 3),
                    ),
                    child: SvgPicture.asset(
                      IconsPath.game,
                      width: 40,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    musicController.buttonSoundEffect();
                    controller.openWebView(url: url1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.deepOrangeAccent, width: 3),
                    ),
                    child: SvgPicture.asset(
                      IconsPath.github,
                      width: 40,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    musicController.buttonSoundEffect();
                    logoutMessage(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.deepOrangeAccent, width: 3),
                    ),
                    child: Image.asset(
                      "assets/icons/icon_signout.png",
                      width: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Future<Uint8List> _loadImageData(String path) async {
  //   File imageFile = File(path);
  //   Uint8List imageBytes = await imageFile.readAsBytes();
  //   return imageBytes;
  // }
}
