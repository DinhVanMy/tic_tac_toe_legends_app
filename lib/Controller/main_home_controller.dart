import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Chat/chat_screen.dart';
import 'package:tictactoe_gameapp/Pages/GuidePage/guide_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/home_page.dart';
import 'package:tictactoe_gameapp/Pages/Setting/setting_screen_main.dart';
import 'package:tictactoe_gameapp/Pages/Web/web_view_screen.dart';

class MainHomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  var pages = <Widget>[
    const HomePage(),
    const GuidePage(),
    const ChatBotPage(),
    const ChatScreen(),
    const SettingScreen(),
  ];
}
