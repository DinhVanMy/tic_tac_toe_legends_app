import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  const CurvedBottomNavBar(
      {super.key, required this.currentIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      key: GlobalKey(),
      index: currentIndex,
      items: <Widget>[
        // Icon(Icons.android_outlined, size: 30, color: Colors.white),
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              GifsPath.chloe1,
              width: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Icon(Icons.chat_outlined, size: 30, color: Colors.white),
        const Icon(Icons.home_filled, size: 30, color: Colors.white),
        const Icon(Icons.widgets_outlined, size: 30, color: Colors.white),
        const Icon(Icons.newspaper_outlined, size: 30, color: Colors.white),
      ],
      color: Colors.blue,
      buttonBackgroundColor: Colors.blueAccent,
      backgroundColor: Colors.white,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 750),
      onTap: onTabChanged,
    );
  }
}
