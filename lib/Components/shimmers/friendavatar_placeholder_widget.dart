import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FriendavatarPlaceholderWidget extends StatelessWidget {
  const FriendavatarPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _friendAvatarPlaceholder();
  }

  Widget _friendAvatarPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 60,
            height: 15,
            color: Colors.grey[300],
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
      delay: 500.ms,
      duration: 1500.ms,
      colors: [Colors.grey[300]!, Colors.grey[100]!],
    );
  }
}
