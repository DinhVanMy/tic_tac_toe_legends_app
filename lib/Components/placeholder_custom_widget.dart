import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class PlaceholderImageCustomWidget extends StatelessWidget {
  final double defaultHeight;
  const PlaceholderImageCustomWidget({super.key, this.defaultHeight = 100});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : defaultHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            GifsPath.loadingGif2,
            fit: BoxFit.cover,
            height: height,
            width: constraints.maxWidth,
          ),
        );
      },
    );
  }
}
