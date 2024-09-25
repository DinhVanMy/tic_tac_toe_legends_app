import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_dark.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_light.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromStorage();
    _applyTheme();
  }

  bool _loadThemeFromStorage() {
    return _box.read(_key) ?? false;
  }

  void _saveThemeToStorage(bool isDarkMode) {
    _box.write(_key, isDarkMode);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _saveThemeToStorage(isDarkMode.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyTheme();
    });
  }

  void _applyTheme() {
    Future.microtask(() {
      Get.changeTheme(isDarkMode.value ? darktheme : lightTheme);
    });
  }

  
}
