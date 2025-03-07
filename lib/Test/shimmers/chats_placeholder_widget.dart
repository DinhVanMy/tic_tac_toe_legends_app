import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatsPlaceholderWidget extends StatelessWidget {
  const ChatsPlaceholderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _messagesLoadingPlaceholder();
  }

  Widget _messagesLoadingPlaceholder() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 6, // Số lượng placeholder
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple[100],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.deepPurple[100],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 200,
                      height: 12,
                      color: Colors.deepPurple[100],
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 14,
                color: Colors.deepPurple[100],
              ),
            ],
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              delay: 400.ms,
              duration: 1800.ms,
              colors: [Colors.deepPurple[100]!, Colors.deepPurple[50]!],
              size: 1.8,
              blendMode: BlendMode.srcATop,
            );
      },
    );
  }
}
