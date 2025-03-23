import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/model/bubble_models.dart';

// Widget hiển thị từng bóng riêng lẻ với hiệu ứng
class BubbleWidget extends StatelessWidget {
  final Bubble bubble;
  final double size;
  final double scale;
  final AnimationType animationType;

  const BubbleWidget({
    super.key,
    required this.bubble,
    required this.size,
    this.scale = 1.0,
    this.animationType = AnimationType.none,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định hiệu ứng dựa trên loại animation
    Widget bubbleContent = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      child: CircleAvatar(
        backgroundImage: AssetImage(bubble.heroAsset),
      ),
    );

    // Thêm các hiệu ứng animation dựa trên loại
    switch (animationType) {
      case AnimationType.appear:
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.5 + value * 0.5,
                child: bubbleContent,
              ),
            );
          },
        );
      case AnimationType.shoot:
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(1.5),
            child: CircleAvatar(
              backgroundImage: AssetImage(bubble.heroAsset),
            ),
          ),
        );
      case AnimationType.match:
      case AnimationType.detach:
        // Những hiệu ứng này được xử lý bên ngoài widget này
        return bubbleContent;
      default:
        // Hiệu ứng mặc định: hiển thị bình thường
        return Transform.scale(
          scale: scale,
          child: bubbleContent,
        );
    }
  }
}
