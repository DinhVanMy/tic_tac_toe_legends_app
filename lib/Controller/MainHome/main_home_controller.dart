import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Chat/chat_screen.dart';
import 'package:tictactoe_gameapp/Pages/Friends/messenger_page.dart';
import 'package:tictactoe_gameapp/Pages/HomePage/home_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_media_page.dart';

class MainHomeController extends GetxController {
  RxInt currentIndex = 2.obs;
  RxInt previousIndex = 2.obs;
  var pages = <Widget>[
    const ChatBotPage(),
    const FriendsPage(),
    const HomePage(),
    const ReelPage(),
    const SocialMediaPage(),
  ];
}
