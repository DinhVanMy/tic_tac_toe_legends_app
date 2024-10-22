import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/language_controller.dart';

class ChangeLang extends StatelessWidget {
  final Color color;
  final Widget icon;
  final MusicController musicController;
  const ChangeLang(
      {this.color = bgColor,
      this.icon = const Icon(
        Icons.more_vert,
        color: Colors.lightBlueAccent,
      ),
      super.key, required this.musicController});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();
    return PopupMenuButton(
      color: color,
      shadowColor: primaryColor,
      elevation: 2.0,
      offset: const Offset(5, 5),
      icon: icon,
      onSelected: (value) {
        musicController.digitalSoundEffect();
        languageController.changeLanguage(value);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        const PopupMenuItem(
            value: 'en',
            child: Text(
              'English',
              style: TextStyle(color: Colors.black),
            )),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'vi',
            child: Text(
              'Tiếng Việt',
              style: TextStyle(color: Colors.black),
            )),
      ],
    );
  }
}