import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';

var darktheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: appBarDarkTheme,
  scaffoldBackgroundColor: kBackgroundDarkColor,
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    fillColor: containerColor,
    filled: true,
    hintStyle: const TextStyle(
      fontSize: 15,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
  ),
  // primaryColor: Color(0xff121212),
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kSecondaryDarkColor,
    surface: kSurfaceDarkColor,
    onSurface: kSurfaceDarkColor,
    primaryContainer: kPrimaryContainer,
    onPrimaryContainer: kSecondaryDarkColor,
  ),
  iconTheme: const IconThemeData(color: kPrimaryIconLightColor),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: 15,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
  ),
);

const AppBarTheme appBarDarkTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  centerTitle: true,
  elevation: 0,
  iconTheme: IconThemeData(color: Colors.white),
  titleTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  ),
);
