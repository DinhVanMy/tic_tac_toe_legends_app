import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/extensions.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/gemini_model.dart';

class ChatController extends GetxController {
  var messages = <Message>[].obs;
  var isLoading = false.obs;
  late GenerativeModel flashModel;
  late GenerativeModel proModel;
  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    flashModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest', //"gemini-2.0-flash-latest",
      apiKey: apiGemini,
    );
    proModel = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiGemini,
    );
    scrollController = ScrollController();
    scrollDown();
  }

  Future<void> sendPrompt(String userInput) async {
    if (userInput.trim().isEmpty) return;

    final userMessage = Message(
      content: userInput,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);

    isLoading.value = true;

    try {
      final prompt = [Content.text(userInput)];
      final response = await flashModel.generateContent(prompt);

      final botMessage = Message(
        content: response.text ?? 'No response',
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(botMessage);
      displayMessage(botMessage);

      if (response.text != null) {
        scrollDown();
      }
    } catch (e) {
      generalCatcheFunction(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPromptWithImage(String userInput, XFile? image) async {
    if (userInput.trim().isEmpty) return;

    final userMessage = Message(
      content: userInput,
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: image!.path,
    );
    messages.add(userMessage);

    isLoading.value = true;

    try {
      // convert it to Uint8List
      final imageBytes = await image.readAsBytes();

      // Define your parts
      final promptText = TextPart(userInput);
      final mimeType = image.getMimeTypeFromExtension();
      final imagePart = DataPart(mimeType, imageBytes);

      // Make a mutli-model request to Gemini API
      final prompt = [
        Content.multi([
          promptText,
          imagePart,
        ])
      ];

      final response = await proModel.generateContent(prompt);

      final botMessage = Message(
        content: response.text ?? 'No response',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.add(botMessage);
      displayMessage(botMessage);
      if (response.text != null) {
        scrollDown();
      }
    } catch (e) {
      generalCatcheFunction(e);
    } finally {
      isLoading.value = false;
    }
  }

  void generalCatcheFunction(Object e) {
    errorMessage(e.toString());
    final alertFromBot = Message(
      content: contentAlertChatBot,
      isUser: false,
      timestamp: DateTime.now(),
    );
    messages.add(alertFromBot);
    displayMessage(alertFromBot);
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Timer? _hideButtonTimer;
  RxBool isOpenedJumpButton = false.obs;
  void resetHideButtonTimer() {
    _hideButtonTimer?.cancel();
    _hideButtonTimer = Timer(const Duration(seconds: 3), () {
      isOpenedJumpButton.value = false;
    });
  }

  Future<void> refreshChat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    messages.clear();
  }

  void displayMessage(Message botMessage) {
    // Reset danh sách từ hiển thị của tin nhắn
    botMessage.displayedWords.clear();

    // Tách câu trả lời thành các từ
    final allWords = botMessage.content.split(' ');

    // Khởi chạy timer để hiển thị từng từ
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (index < allWords.length) {
        botMessage.displayedWords.add(allWords[index]);
        index++;
      } else {
        timer.cancel(); // Dừng khi đã hiển thị xong
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
