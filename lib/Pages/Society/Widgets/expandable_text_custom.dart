import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/hyperlink_text_function.dart';

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
              isExpanded.value ? 'Show less' : 'Show more',
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
        // Kiểm tra overflow dựa trên số dòng
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: content, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        return Obx(() {
          if (!isOverflowing || isExpanded.value) {
            // Hiển thị toàn bộ nội dung khi mở rộng
            return GestureDetector(
              onTap: () {
                isExpanded.value = !isExpanded.value;
              },
              child: Text.rich(
                TextSpan(children: [
                  HyperlinkTextFunction.parseContent(
                    content: content,
                    defaultStyle: style,
                    linkColor: Colors.deepPurpleAccent,
                    tagColor: Colors.black,
                  ),
                  isExpanded.value
                      ? TextSpan(
                          text: '\n Show less',
                          style: style.copyWith(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              isExpanded.value = !isExpanded.value;
                            },
                        )
                      : const TextSpan(),
                ]),
                textAlign: isAligCenter ? TextAlign.center : TextAlign.start,
                maxLines: isExpanded.value ? null : maxLines,
              ),
            );
          } else {
            // Thu gọn nội dung
            final truncatedText = _getTruncatedTextByBinary(
              textPainter,
              content,
              constraints.maxWidth,
            );

            return GestureDetector(
              onTap: () {
                isExpanded.value = !isExpanded.value;
              },
              child: Text.rich(
                TextSpan(
                  children: [
                    HyperlinkTextFunction.parseContent(
                      content: truncatedText,
                      defaultStyle: style,
                      linkColor: Colors.blue,
                      tagColor: Colors.green,
                    ),
                    TextSpan(
                      text: ' ...',
                      style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ' Show more',
                      style: style.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          isExpanded.value = !isExpanded.value;
                        },
                    ),
                  ],
                ),
                textAlign: isAligCenter ? TextAlign.center : TextAlign.start,
              ),
            );
          }
        });
      },
    );
  }

  String _getTruncatedTextByBinary(
      TextPainter textPainter, String content, double maxWidth) {
    int start = 0;
    int end = content.length;
    String truncatedText = '';

    while (start <= end) {
      int mid = (start + end) ~/ 2;
      final testText = content.substring(0, mid);

      final testPainter = TextPainter(
        text: TextSpan(text: testText, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (testPainter.didExceedMaxLines) {
        end = mid - 1; // Cắt ngắn hơn
      } else {
        truncatedText = testText; // Lưu kết quả
        start = mid + 1; // Mở rộng văn bản
      }
    }

    return truncatedText.trim();
  }
}
