import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MessagesPlaceholderWidget extends StatelessWidget {
  final bool isMe;
  const MessagesPlaceholderWidget({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return _chatMessagePlaceholder(isMe: isMe);
  }

  Widget _chatMessagePlaceholder({required bool isMe}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) // Avatar chỉ hiển thị cho tin nhắn của người khác
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
            ),
          const SizedBox(width: 10),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
      delay: 500.ms, // Độ trễ trước khi bắt đầu hiệu ứng
      duration: 1500.ms, // Thời gian một chu kỳ shimmer
      colors: [
        Colors.grey[300]!,
        Colors.grey[100]!
      ], // Màu gradient của shimmer
    );
  }
}
