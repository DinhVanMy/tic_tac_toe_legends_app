import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SpeechController extends GetxController {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
// state variables
  var isSpeechEnabled = false.obs;
  var lastWords = "".obs; //Hi, How is it going
  var isListening = false.obs;
  
// Inintial instance of speech
  Future<void> initializeSpeech() async {
    try {
      isSpeechEnabled.value = await _speechToText.initialize(
        onStatus: statusListener,
        onError: errorListener,
        debugLogging: true,
        options: [stt.SpeechToText.androidIntentLookup],
      );
    } catch (e) {
      if (e is PlatformException) {
        errorMessage('Speech initialization error: ${e.message}');
      } else {
        errorMessage('Unexpected error during initialization: ${e.toString()}');
      }
    }
  }

  void errorListener(SpeechRecognitionError error) {
    errorMessage('Speech error: ${error.errorMsg}');
    isListening.value = false;
  }

  void statusListener(String status) {
    if (status == 'done') {
      isListening.value = false;
    } else if (status == 'listening') {
      isListening.value = true;
    }
  }

// Listening--------------------------------
  Future<void> startListening() async {
    if (!isSpeechEnabled.value) {
      await initializeSpeech();
    } else {
      try {
        await _speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
        );
        isListening.value = _speechToText.isListening;
      } catch (e) {
        errorMessage('Error while starting listening: ${e.toString()}');
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      lastWords.value = result.recognizedWords;
    } else {
      errorMessage("No recognized words.");
    }
  }

//stop listening---------------------
  Future<void> stopListening() async {
    if (isListening.value) {
      try {
        await _speechToText.stop();
        isListening.value = false;
      } catch (e) {
        errorMessage('Error while stopping listening: ${e.toString()}');
      }
    }
  }

//reset lastwords variable
  void resetLastWords() {
    lastWords.value = '';
  }

  // @override
  // void onClose() {
  //   resetLastWords();
  //   super.onClose();
  // }
}
