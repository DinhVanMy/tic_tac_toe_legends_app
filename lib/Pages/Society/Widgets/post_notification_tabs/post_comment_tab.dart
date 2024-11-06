import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class PostCommentTab extends StatelessWidget {
  const PostCommentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            GifsPath.transitionGif,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
