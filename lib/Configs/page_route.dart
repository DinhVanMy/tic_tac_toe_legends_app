import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Auth/auth_page.dart';
import 'package:tictactoe_gameapp/Pages/Friends/friends_page.dart';
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
  ),
  GetPage(
    name: "/welcome",
    page: () => const WelcomePage(),
  ),
  GetPage(
    name: "/singlePlayer", //Todo rename
    page: () => const PlayWithBotPage(),
  ),
  GetPage(
    name: "/settings",
    page: () => const SettingScreen(),
  ),
  GetPage(
    name: "/guides",
    page: () => const FriendsPage(),
  ),
];
