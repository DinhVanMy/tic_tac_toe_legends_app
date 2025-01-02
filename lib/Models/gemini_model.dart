import 'package:get/get_rx/src/rx_types/rx_types.dart';

class Message {
  final String content;
  final String? imagePath;
  final bool isUser;
  final DateTime timestamp;
   final RxList<String> displayedWords;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
  }) : displayedWords = <String>[].obs;
}
