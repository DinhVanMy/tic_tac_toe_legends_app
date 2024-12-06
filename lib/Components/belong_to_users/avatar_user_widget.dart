import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarUserWidget extends StatelessWidget {
  final double radius;
  final String imagePath;
  final List<Color>? gradientColors;
  final double borderThickness;

  const AvatarUserWidget({
    super.key,
    required this.radius,
    required this.imagePath,
    this.gradientColors,
    this.borderThickness = 5,
  });

  @override
  Widget build(BuildContext context) {
    return gradientColors != null && gradientColors!.isNotEmpty
        ? Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(borderThickness), // Độ dày viền
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Màu viền trong cùng
                ),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(imagePath),
                  radius: radius - 5, // Kích thước CircleAvatar
                ),
              ),
            ),
          )
        : CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(imagePath),
            radius: radius,
          );
  }
}
