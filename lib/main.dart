import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tictactoe_gameapp/Configs/page_route.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_dark.dart';
import 'package:tictactoe_gameapp/Configs/theme/theme_light.dart';
import 'package:tictactoe_gameapp/Configs/translation/translation.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Controller/language_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Pages/Splace/splace_page.dart';
import 'package:tictactoe_gameapp/Test/customed_error_widget.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setUpExternalLoad();
  await _setUpGeneralSystem();
  runApp(const MyApp());
}

Future<void> _setUpExternalLoad() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  await GetStorage.init();
}

Future<void> _setUpGeneralSystem() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
        Get.put(BackgroundMusicController(), permanent: true);
        // Get.put(EffectiveMusicController(), permanent: false);
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
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return CustomErrorWidget(errorDetails: errorDetails);
        };
        return child!;
      },
      home: const SplacePage(),
      //  const MultiPlayer(
      //   roomId: "339C80AB",
      // ),
    );
  }
}
