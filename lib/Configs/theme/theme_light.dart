import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';

var lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: appBarLightTheme,
  scaffoldBackgroundColor: bgColor,
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
      color: lableColor,
    ),
  ),
  iconTheme: const IconThemeData(color: fontColor),
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    secondary: secondryColor,
    surface: bgColor,
    onSurface: fontColor,
    primaryContainer: containerColor,
    onPrimaryContainer: lableColor,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      fontFamily: "Poppins",
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
    ),
    labelMedium: TextStyle(
      fontSize: 15,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
      color: lableColor,
    ),
  ),
);

const AppBarTheme appBarLightTheme = AppBarTheme(
  backgroundColor: Colors.transparent,
  centerTitle: true,
  elevation: 0,
  iconTheme: IconThemeData(color: kPrimaryIconDarkColor),
  titleTextStyle: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: kPrimaryIconDarkColor,
  ),
);
