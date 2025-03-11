import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PostsPlaceholderWidget extends StatelessWidget {
  final int itemCount;
  const PostsPlaceholderWidget({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return _postPlaceholder();
  }

  Widget _postPlaceholder() {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar và tên người dùng
            Row(
              children: [
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
                  width: 100,
                  height: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Nội dung bài viết
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            // Hình ảnh bài viết
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            // Footer: Like, comment, share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey[300],
                ),
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey[300],
                ),
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ],
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
        delay: 500.ms,
        duration: 1500.ms,
        colors: [Colors.grey[300]!, Colors.grey[100]!],
      ),
    );
  }
}
