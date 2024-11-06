import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const ExpandableText({super.key, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    RxBool isExpanded = false.obs;
    final fontSize = _calculateFontSize();
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {},
            child: Text(
              text,
              style: theme.textTheme.titleLarge!.copyWith(fontSize: fontSize),
              maxLines: isExpanded.value ? 1000 : 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              overlayColor: Colors.blueGrey,
            ),
            onPressed: () => isExpanded.value = !isExpanded.value,
            child: Text(
              isExpanded.value ? 'See Less' : 'See More',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    });
  }

  double _calculateFontSize() {
    if (text.length < 50) {
      return 25.0; // Văn bản ngắn, chữ lớn hơn
    } else if (text.length < 500) {
      return 20.0; // Văn bản trung bình, chữ vừa
    } else if (text.length < 2000) {
      return 17.0; // Văn bản trung bình, chữ vừa
    } else {
      return 16.0;
    }
  }
}

class ExpandableContent extends StatelessWidget {
  final String content;
  final int maxLines;
  final TextStyle style;
  final bool isAligCenter;

  const ExpandableContent({
    super.key,
    required this.content,
    this.maxLines = 5,
    required this.style,
    this.isAligCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    RxBool isExpanded = false.obs;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính toán để kiểm tra xem nội dung có vượt quá số dòng cho phép không
        final span = TextSpan(
          text: content,
          style: style,
        );
        final textPainter = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return Obx(() {
          return GestureDetector(
            onTap: () {
              isExpanded.value = !isExpanded.value;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  content,
                  style: style,
                  textAlign: isAligCenter ? TextAlign.center : TextAlign.start,
                  maxLines: isExpanded.value ? 1000 : maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOverflowing)
                  Text(
                    isExpanded.value ? "See Less" : "See More",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}
