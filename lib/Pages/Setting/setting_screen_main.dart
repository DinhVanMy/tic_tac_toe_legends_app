import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/language_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/background_music_controller.dart';
import 'package:tictactoe_gameapp/Controller/online_status_controller.dart';
import 'package:tictactoe_gameapp/Controller/theme_controller.dart';
import 'package:tictactoe_gameapp/Pages/Login/change_password_dialog.dart';
import 'package:tictactoe_gameapp/Pages/Setting/Widgets/locale_button.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BackgroundMusicController musicController =
        Get.find<BackgroundMusicController>();
    final storage = GetStorage();
    if (!storage.hasData('isDarkMode')) {
      storage.write('isDarkMode', false);
    }
    final ThemeController themeController = Get.find<ThemeController>();

    final LanguageController languageController =
        Get.find<LanguageController>();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 4),
              ),
              child: const Icon(
                Icons.settings_accessibility_outlined,
                size: 30,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 4),
              ),
              child: Text(
                "app_bar_sett".tr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.greenAccent, width: 4),
              ),
              child: const Icon(Icons.search_off_outlined, size: 30),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SettingsList(
        shrinkWrap: true,
        sections: [
          SettingsSection(
            title: Text("common_sett".tr),
            tiles: [
              SettingsTile(
                title: Text("languages_sett".tr),
                onPressed: (BuildContext context) {
                  musicController.buttonSoundEffect();
                },
                leading: const Icon(
                  Icons.language_outlined,
                ),
                description: Obx(
                    () => Text(languageController.getCurrentLanguageName())),
                trailing: ChangeLang(
                  musicController: musicController,
                ),
              ),
              SettingsTile(
                title: Text("dark_theme_sett".tr),
                onPressed: (BuildContext context) {
                  musicController.buttonSoundEffect();
                },
                leading: const Icon(Icons.contrast_outlined),
                description: Row(
                  children: [
                    const Icon(Icons.dark_mode),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "description_dark_theme_sett".tr,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Obx(() {
                  return Switch(
                    value: themeController.isDarkMode.value,
                    onChanged: (value) {
                      themeController.toggleTheme();
                    },
                    activeTrackColor: Colors.lightBlueAccent,
                    activeColor: Colors.blue,
                  );
                }),
              ),
            ],
          ),
          SettingsSection(
            title: Text("account_tile_sett".tr),
            tiles: [
              SettingsTile(
                title: Text("profile_tile_sett".tr),
                onPressed: (BuildContext context) {
                  musicController.digitalSoundEffect();
                  Get.toNamed("/updateProfile");
                },
                leading: const Icon(Icons.account_circle_rounded),
                description: Text("edit_profile_file_sett".tr),
                trailing: const Icon(
                  Icons.edit,
                  color: Colors.lightBlueAccent,
                ),
              ),
              SettingsTile(
                title: Text("change_password_sett".tr),
                onPressed: (BuildContext context) async {
                  musicController.digitalSoundEffect();
                  await PasswordChangeDialog.showPasswordChangeDialogWhenUser();
                },
                leading: const Icon(Icons.change_circle_outlined),
                description: Text("everything_is_ok_sett".tr),
                trailing: const Icon(
                  Icons.password,
                  color: Colors.lightBlueAccent,
                ),
              ),
              SettingsTile(
                title: Text("logout_sett".tr),
                onPressed: (BuildContext context) {
                  if (Get.isRegistered<OnlineStatusController>()) {
                    final OnlineStatusController onlineStatusController =
                        Get.find<OnlineStatusController>();
                    musicController.digitalSoundEffect();
                    logoutMessage(context, onlineStatusController);
                  } else {
                    errorMessage("you haven't singed in?");
                  }
                },
                leading: const Icon(Icons.logout),
                description: Text("logout_from_app_sett".tr),
                trailing: const Icon(
                  Icons.subdirectory_arrow_right,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text("sound_sett".tr),
            tiles: [
              SettingsTile(
                title: Text("play_music_sett".tr),
                onPressed: (BuildContext context) {},
                leading: const Icon(Icons.vibration_outlined),
                description: Text("turn _on_off_sett".tr),
                trailing: Obx(() {
                  bool isDarkMode = themeController.isDarkMode.value;
                  bool isPlaying = musicController.isPlaying.value;
                  return LiteRollingSwitch(
                    width: 110,
                    value: isPlaying,
                    textOn: 'stop_sett'.tr,
                    textOff: 'play_sett'.tr,
                    animationDuration: const Duration(milliseconds: 300),
                    colorOn: Colors.redAccent,
                    colorOff: Colors.greenAccent,
                    iconOn: Icons.stop,
                    iconOff: Icons.play_arrow,
                    onChanged: (bool value) {
                      if (value) {
                        if (isDarkMode) {
                          musicController
                              .playMusic([AudioSPath.infinityCastle]);
                        } else {
                          musicController.playMusic([AudioSPath.matchingSound]);
                        }
                      } else {
                        musicController.stopMusic();
                      }
                    },
                    onTap: () {
                      musicController.digitalSoundEffect();
                    },
                    onDoubleTap: () {},
                    onSwipe: () {},
                  );
                }),
              ),
              SettingsTile(
                title: Text("volume_sett".tr),
                onPressed: (BuildContext context) {},
                leading: const Icon(Icons.volume_up),
                description: Obx(() => Slider(
                      value: musicController.volume.value,
                      onChanged: (newVolume) {
                        musicController.setVolume(newVolume);
                      },
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: '${(musicController.volume.value * 100).toInt()}',
                    )),
              ),
              SettingsTile(
                title: Text("background_music_sett".tr),
                onPressed: (BuildContext context) {},
                leading: const Icon(Icons.music_note_outlined),
                description: Text("turn_off_background_music_sett".tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
