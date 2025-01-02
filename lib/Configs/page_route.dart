import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/friend_zone/friend_zone_map_page.dart';
import 'package:tictactoe_gameapp/Pages/Auth/auth_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/friends_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Shop/shop_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/home_page.dart';
import 'package:tictactoe_gameapp/Pages/MainHome/main_home.dart';
import 'package:tictactoe_gameapp/Pages/RoomPage/room_page.dart';
import 'package:tictactoe_gameapp/Pages/Setting/setting_screen_main.dart';
import 'package:tictactoe_gameapp/Pages/Splace/splace_page.dart';
import 'package:tictactoe_gameapp/Pages/UpdateProfile/update_profile_page.dart';
import 'package:tictactoe_gameapp/Pages/Welcome/welcome_page.dart';
import '../Pages/GamePage/SingleGame/play_with_bot_page.dart';

var pages = [
  GetPage(
    name: "/room",
    page: () => const RoomPage(),
    transition: Transition.leftToRightWithFade,
  ),
  GetPage(
    name: "/auth",
    page: () => const AuthPage(),
  ),
  GetPage(
    name: "/home",
    page: () => const HomePage(),
  ),
  GetPage(
    name: "/splace",
    page: () => const SplacePage(),
  ),
  GetPage(
    name: "/mainHome",
    page: () => const MainHomePage(),
  ),
  GetPage(
    name: "/updateProfile",
    page: () => const UpdateProfile(),
    transition: Transition.zoom,
  ),
  GetPage(
    name: "/welcome",
    page: () => const WelcomePage(),
  ),
  GetPage(
    name: "/singlePlayer", //Todo rename
    page: () => const PlayWithBotPage(),
    transition: Transition.zoom,
  ),
  GetPage(
    name: "/settings",
    page: () => const SettingScreen(),
    transition: Transition.upToDown,
  ),
  GetPage(
    name: "/guides",
    page: () => const FriendsPage(),
  ),

  // pages in home page
  GetPage(
    name: "/shoppage",
    page: () => const ShopPage(),
    transition: Transition.zoom,
  ),
];
