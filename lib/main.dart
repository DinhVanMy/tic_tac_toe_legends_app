import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tictactoe_gameapp/Configs/page_route.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_dark.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_light.dart';
import 'package:tictactoe_gameapp/Configs/translation/translation.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Controller/check_network_controller.dart';
import 'package:tictactoe_gameapp/Controller/language_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/notification_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Pages/Splace/splace_page.dart';
import 'package:tictactoe_gameapp/Test/test_widget.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.put(LanguageController());
    return GetMaterialApp(
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController(), permanent: true);
        Get.put(AuthController(), permanent: true);
        Get.put(MusicController(), permanent: true);
        // Get.put(CheckNetworkController(),permanent: true);
      }),
      // initialRoute: '/splace',
      getPages: pages, navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'XO Game App',
      theme: lightTheme,
      darkTheme: darktheme,
      translations: AppTranslations(),
      locale: languageController.locale,
      fallbackLocale: const Locale('en'),
      home: const SplacePage(),
      //  const MultiPlayer(

      //   roomId: "339C80AB",
      // ),
    );
  }
}
