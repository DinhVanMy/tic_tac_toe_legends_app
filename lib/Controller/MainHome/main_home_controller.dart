import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Chat/chat_screen.dart';
import 'package:tictactoe_gameapp/Pages/Friends/friends_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/home_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/society_gaming_page.dart';
import 'package:tictactoe_gameapp/Pages/Web/web_view_screen.dart';

class MainHomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  var pages = <Widget>[
    const HomePage(),
    const FriendsPage(),
    const ChatBotPage(),
    const UltizeScreen(),
    const SocietyGamingPage(),
  ];
}
