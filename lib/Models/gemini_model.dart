class Message {
  final String content;
  final String? imagePath;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imagePath,
  });
}
