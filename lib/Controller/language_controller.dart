import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  var currentLanguage = 'en'.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    String? savedLanguage = _storage.read('language');
    if (savedLanguage != null) {
      currentLanguage.value = savedLanguage;
    } else {
      String systemLanguage = Get.deviceLocale?.languageCode ?? 'en';
      currentLanguage.value = systemLanguage;
    }
    _applyLanguage(currentLanguage.value);
  }

  Locale get locale => Locale(currentLanguage.value);

  // Thay đổi ngôn ngữ và lưu trạng thái
  void changeLanguage(String languageCode) {
    currentLanguage.value = languageCode;
    _applyLanguage(languageCode);
    _storage.write('language', languageCode);
  }

  // Áp dụng ngôn ngữ đã chọn
  void _applyLanguage(String languageCode) {
    var locale = Locale(languageCode);
    Get.updateLocale(locale);
  }

  // Trả về danh sách ngôn ngữ được hỗ trợ
  List<Locale> get supportedLocales => [
        const Locale('en'),
        const Locale('vi'),
        // Có thể thêm các ngôn ngữ khác tại đây
      ];

  // Lấy tên ngôn ngữ hiện tại
  String getCurrentLanguageName() {
    switch (currentLanguage.value) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
      default:
        return 'English';
    }
  }
}
