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
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    flashModel = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiGemini,
    );
    proModel = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiGemini,
    );
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollDown();
    });
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
      if (response.text != null) {
        _scrollDown();
      }
    } catch (e) {
      errorMessage(e.toString());
      messages.add(Message(
        content: 'Failed to get response from API',
        isUser: false,
        timestamp: DateTime.now(),
      ));
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
      if (response.text != null) {
        _scrollDown();
      }
    } catch (e) {
      errorMessage(e.toString());
      messages.add(Message(
        content: contentAlertChatBot,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutCirc,
        );
      }
    });
  }

  Future<void> refreshChat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    messages.clear();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
