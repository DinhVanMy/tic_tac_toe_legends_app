import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/translation/en.dart';
import 'package:tictactoe_gameapp/Configs/translation/vi.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'vi': vi,
  };
}
