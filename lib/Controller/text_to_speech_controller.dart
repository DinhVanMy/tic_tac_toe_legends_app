import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

enum TtsState { playing, stopped, paused, continued }

class TextToSpeechController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();

  var language = 'en-US'.obs;
  var engine = 'default'.obs;
  var volume = 0.8.obs;
  var pitch = 1.0.obs;
  var rate = 0.5.obs;
  var isCurrentLanguageInstalled = false.obs;
  var ttsState = TtsState.stopped.obs;
  var isEchoMode = false.obs;
  var isAlexaMode = false.obs;

  bool get isPlaying => ttsState.value == TtsState.playing;
  bool get isStopped => ttsState.value == TtsState.stopped;
  bool get isPaused => ttsState.value == TtsState.paused;
  bool get isContinued => ttsState.value == TtsState.continued;

  @override
  void onInit() {
    super.onInit();
    initTts();
  }

  void initTts() {
    _setAwaitOptions();
    // flutterTts.setStartHandler(() => ttsState.value = TtsState.playing);
    // flutterTts.setCompletionHandler(() => ttsState.value = TtsState.stopped);
    // flutterTts.setCancelHandler(() => ttsState.value = TtsState.stopped);
    // flutterTts.setPauseHandler(() => ttsState.value = TtsState.paused);
    // flutterTts.setContinueHandler(() => ttsState.value = TtsState.continued);
    flutterTts.setErrorHandler((msg) {
      ttsState.value = TtsState.stopped;
      errorMessage("TTS Error: $msg");
    });
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    ttsState.value = TtsState.playing;
    // Adjust settings based on mode
    if (isEchoMode.value) {
      await _setEchoModeSettings();
    } else if (isAlexaMode.value) {
      await _setAlexaModeSettings();
    } else {
      await _setNormalSettings();
    }

    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
    ttsState.value = TtsState.stopped;
  }

  Future<void> stop() async {
    ttsState.value = TtsState.stopped;
    await flutterTts.stop();
  }

  Future<void> pause() async {
    ttsState.value = TtsState.paused;
    await flutterTts.pause();
  }

  Future<void> resume() async {
    ttsState.value = TtsState.continued;
    flutterTts.continueHandler;
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await flutterTts.setLanguage(lang);
    if (GetPlatform.isAndroid) {
      isCurrentLanguageInstalled.value =
          await flutterTts.isLanguageInstalled(lang) ?? false;
    }
  }

  Future<void> setVolume(double newVolume) async {
    volume.value = newVolume;
    await flutterTts.setVolume(newVolume);
  }

  Future<void> setPitch(double newPitch) async {
    pitch.value = newPitch;
    await flutterTts.setPitch(newPitch);
  }

  Future<void> setRate(double newRate) async {
    rate.value = newRate;
    await flutterTts.setSpeechRate(newRate);
  }

  // Mode settings
  Future<void> _setNormalSettings() async {
    await flutterTts.setVolume(volume.value);
    await flutterTts.setPitch(pitch.value);
    await flutterTts.setSpeechRate(rate.value);
  }

  Future<void> _setEchoModeSettings() async {
    await flutterTts.setVolume(0.7); // Echo effect volume
    await flutterTts.setPitch(0.9); // Lower pitch
    await flutterTts.setSpeechRate(0.8); // Moderate rate for echo
  }

  Future<void> _setAlexaModeSettings() async {
    await flutterTts.setVolume(0.85); // Alexa effect volume
    await flutterTts.setPitch(1.0); // Neutral pitch
    await flutterTts.setSpeechRate(0.75); // Slightly slower rate
  }

  Map<String, dynamic> getIconAndCallback(String text) {
    if (isPlaying) {
      return {
        "icon": Icons.volume_up_rounded,
        "callback": () async {
          await pause();
        }
      };
    } else if (isStopped || isContinued) {
      return {
        "icon": Icons.volume_off_rounded,
        "callback": () async {
          await speak(text);
        }
      };
    } else {
      return {
        "icon": Icons.error,
        "callback": null,
      };
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
