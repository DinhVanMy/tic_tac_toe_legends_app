import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    this.borderThickness = 3,
  });

  @override
  Widget build(BuildContext context) {
    return gradientColors != null && gradientColors!.isNotEmpty
        ? Container(
            width: radius * 2,
            height: radius * 2,
            padding: EdgeInsets.all(borderThickness),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: imagePath,
                placeholder: (context, url) => _buildPlacholderWidget(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
                fit: BoxFit.cover,
                width: radius * 2 - borderThickness * 2,
                height: radius * 2 - borderThickness * 2,
              ),
            ),
          )
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: imagePath,
              placeholder: (context, url) => _buildPlacholderWidget(),
              errorWidget: (context, url, error) => _buildErrorWidget(),
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
            ),
          );
  }

  Widget _buildPlacholderWidget() {
    return ColoredBox(
      color: Colors.blueAccent,
      child: Icon(
        Icons.person,
        size: radius,
        color: Colors.deepPurple[100],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
          delay: 400.ms,
          duration: 1800.ms,
          colors: [Colors.deepPurple[100]!, Colors.deepPurple[50]!],
          size: 1.8,
          blendMode: BlendMode.srcATop,
        );
  }

  Widget _buildErrorWidget() {
    return ColoredBox(
      color: Colors.blueGrey,
      child: Icon(
        Icons.error,
        size: radius,
        color: Colors.red,
      ),
    );
  }
}
