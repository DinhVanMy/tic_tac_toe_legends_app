import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  const BottomNavBar(
      {super.key, required this.currentIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.8),
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(20),
        //   topRight: Radius.circular(20),
        // ),
      ),
      child: GNav(
        haptic: true, // haptic feedback
        tabBorderRadius: 25,
        tabActiveBorder:
            Border.all(color: Colors.green, width: 3), // tab button border
        tabBorder:
            Border.all(color: Colors.grey, width: 1), // tab button border
        tabShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1.0,
          ),
        ], // tab button shadow
        curve: Curves.easeInOutCubic, // tab animation curves
        gap: 8, // the tab button gap between icon and text
        color: Colors.white, // unselected icon color
        activeColor: Colors.lightGreenAccent, // selected icon and text color
        iconSize: 27, // tab button icon size
        tabBackgroundColor:
            kSurfaceDarkColor.withOpacity(0.5), // selected tab background color
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 7), // navigation bar padding
        tabs: const [
          GButton(
            icon: Icons.home_filled,
            text: 'Home',
          ),
          GButton(
            icon: Icons.chat_outlined,
            text: 'Chatting',
           
          ),
          GButton(
            icon: Icons.android_outlined,
            text: 'Joi',
          ),
          GButton(
            icon: Icons.widgets_outlined,
            text: 'Games',
          ),
          GButton(
            icon: Icons.newspaper_outlined,
            text: 'Society',
          ),
        ],
        selectedIndex: currentIndex,
        onTabChange: onTabChanged,
      ),
    );
  }
}
