import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/friend_zone_map_page.dart';
import 'package:tictactoe_gameapp/Components/primary_with_icon_button.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Controller/MainHome/notify_in_main_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';
import 'package:tictactoe_gameapp/Controller/Console/play_with_bot_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/webview_controller.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Pages/Friends/listen_latest_messages_controller.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Bottom/bottom_button_custom.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Drawer/drawer_nav_bar.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/expansion_side_left.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/expansion_side_right.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/jajas_top_icon_widget.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/middle_custom_widget.dart';
import 'package:tictactoe_gameapp/Components/fortune_wheel/fortune_wheel_page.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/daily_gift_page.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/missions_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/Widgets/looping_carousel_widget.dart';
import 'package:tictactoe_gameapp/Test/game_history/game_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final WebViewControllers controller = Get.put(WebViewControllers());
    final ListenLatestMessagesController listenLatestMessagesController =
        Get.put(ListenLatestMessagesController());

    final NotifyInMainController notifyInMainController =
        controller.notifyInMainController;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final theme = Theme.of(context);

    final BackgroundMusicController musicController =
        Get.find<BackgroundMusicController>();
    final FirestoreController firestoreController =
        Get.put(FirestoreController());
    final ProfileController profileController = Get.find<ProfileController>();
    final user = profileController.user!;

    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: false,
      drawer: DrawerNavBar(
        firestoreController: firestoreController,
        profileController: profileController,
        user: user,
        notifyInMainController: notifyInMainController,
      ),
      body: Stack(
        children: [
          const Positioned(
            bottom: 0,
            child: RotatedBox(
              quarterTurns: 2,
              child: LoopingCarousel(),
            ),
          ),
          const Positioned(
            top: 0,
            child: LoopingCarousel(),
          ),
          // const LoopingImageCarousel(),
          Positioned(
            right: 0,
            top: 30,
            child: Container(
              height: 45,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.purpleAccent.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
              left: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        user.image != null && user.image!.isNotEmpty
                            ? AvatarUserWidget(
                                radius: 30,
                                imagePath: user.image!,
                                gradientColors: const [
                                  Colors.white,
                                  Colors.blueAccent
                                ],
                                
                              )
                            : const Icon(Icons.person_2_outlined),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent[400],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(50),
                                  bottomRight: Radius.circular(10),
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "1000",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SvgPicture.asset(
                                    IconsPath.coinIcon,
                                    width: 20,
                                    colorFilter:
                                        const ColorFilter.linearToSrgbGamma(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent[400],
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(50),
                                  topLeft: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "1000",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  SvgPicture.asset(
                                    IconsPath.coinIcon,
                                    width: 20,
                                    colorFilter:
                                        const ColorFilter.linearToSrgbGamma(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.to(() => const GameHistoryPage(),
                                      transition: Transition.upToDown);
                                },
                                icon: const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(100)),
                                  child: Text(
                                    listenLatestMessagesController
                                        .latestMessages.length
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              Get.toNamed("/settings");
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              // musicController.boosterSoundEffect();
                              scaffoldKey.currentState!.openDrawer();
                            },
                            icon: const Icon(
                              Icons.storage_rounded,
                              color: Colors.lightBlueAccent,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(height: 250, child: MiddleCustomWidget()),
                Column(
                  children: [
                    PrimaryIconWithButton(
                      buttonText: "Single Player",
                      color: theme.colorScheme.primary,
                      onTap: () {
                        final PlayWithBotController playWithBotController =
                            Get.put(PlayWithBotController());
                        playWithBotController.showMapPicker();
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
                    BottomButtonCustom(
                      onPressed: () {
                        musicController.buttonSoundEffect();
                        Get.toNamed("/updateProfile");
                      },
                      theme: theme,
                      icon: IconsPath.info,
                    ),
                    BottomButtonCustom(
                      onPressed: () {
                        musicController.buttonSoundEffect();
                        controller.openWebView(url: url2);
                      },
                      theme: theme,
                      icon: IconsPath.game,
                    ),
                    BottomButtonCustom(
                      onPressed: () {
                        musicController.buttonSoundEffect();
                        controller.openWebView(url: url1);
                      },
                      theme: theme,
                      icon: IconsPath.github,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        musicController.buttonSoundEffect();
                        Get.toNamed("/shoppage");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              spreadRadius: 2.0,
                              color: Colors.white,
                              blurRadius: 15.0,
                              offset: Offset(5, 5),
                            ),
                            BoxShadow(
                              spreadRadius: 2.0,
                              color: Colors.white,
                              blurRadius: 15.0,
                              offset: Offset(-5, -5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 30,
            child: Wrap(
              children: [
                JajasTopIconWidget(
                    onTap: () {
                      Get.dialog(
                        const Dialog(
                                backgroundColor: Colors.transparent,
                                child: DailyRewardPage())
                            .animate()
                            .scale(),
                        barrierDismissible: true,
                      );
                    },
                    icon: Jajas.banner,
                    name: "Daily"),
                const SizedBox(
                  width: 20,
                ),
                JajasTopIconWidget(
                    onTap: _onTapCommingSoon, icon: Jajas.event, name: "Event"),
                const SizedBox(
                  width: 20,
                ),
                JajasTopIconWidget(
                    onTap: () {
                      Get.dialog(
                        const Dialog(
                          backgroundColor: Colors.transparent,
                          child: FortuneWheelMain(),
                        ).animate().scale(),
                        barrierDismissible: false,
                      );
                    },
                    icon: Jajas.spinner,
                    name: "Spinner"),
                const SizedBox(
                  width: 20,
                ),
                JajasTopIconWidget(
                    onTap: _onTapCommingSoon,
                    icon: Jajas.worldNews,
                    name: "Discovery"),
                const SizedBox(
                  width: 20,
                ),
                JajasTopIconWidget(
                    onTap: _onTapCommingSoon, icon: Jajas.clans, name: "Clans"),
                const SizedBox(
                  width: 20,
                ),
                JajasTopIconWidget(
                    onTap: () {
                      Get.dialog(
                        const Dialog(
                          backgroundColor: Colors.transparent,
                          // child: Example(),
                        ).animate().scale(),
                      );
                      // Get.to(() => const Example(),
                      //     transition: Transition.zoom);
                    },
                    icon: Jajas.tinder,
                    name: "Tinder"),
                const SizedBox(
                  width: 20,
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
          Positioned(
            top: 180,
            right: 2,
            child: JajasTopIconWidget(
                onTap: () {
                  late LatLng latlng;
                  if (user.location != null) {
                    latlng = LatLng(
                        user.location!.latitude, user.location!.longitude);
                  } else {
                    latlng = const LatLng(21.0000992, 105.8399243);
                  }
                  Get.to(
                    () => FriendZoneMapPage(
                      user: user,
                      firestoreController: firestoreController,
                      latlng: latlng,
                    ),
                    transition: Transition.zoom,
                  );
                },
                icon: Jajas.mission,
                name: "Map"),
          ),
          Positioned(
            top: 180,
            left: 2,
            child: JajasTopIconWidget(
                onTap: () {
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.transparent,
                      child: MissionsPage(
                        userId: user.id!,
                      ),
                    ).animate().scale(),
                  );
                },
                icon: Jajas.quest,
                name: "Missions"),
          ),
          const ExpansionSideWidgetLeft(),
          const ExpansionSideWidgetRight(),
        ],
      ),
    );
  }

  void _onTapCommingSoon() {
    Get.dialog(
      Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(GifsPath.chatbotGif)),
                Positioned(
                  top: -20,
                  left: 50,
                  right: 50,
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purpleAccent, width: 5),
                    ),
                    child: const Text(
                      "Comming Soon...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )).animate().scale(),
    );
  }
}
