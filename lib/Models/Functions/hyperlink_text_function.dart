import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/placeholder_custom_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/fetch_firestore_data_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';
import 'package:tictactoe_gameapp/Pages/Web/web_view_open.dart';

class HyperlinkTextFunction {
  // Mẫu biểu thức chính quy cho liên kết URL và tag người dùng
  static final RegExp combinedRegExp = RegExp(
    r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?|@([a-zA-Z0-9_]+)',
  );

  // Hàm để xây dựng `TextSpan` với định dạng cho các liên kết và tag

// Hàm để xây dựng `TextSpan` với định dạng cho các liên kết và tag
  static List<InlineSpan> buildMessageText(
    BuildContext context, {
    required String text,
    required Color color,
    bool previewUrlMode = false,
    List<Color> colors = const [Colors.grey, Colors.grey],
  }) {
    final List<InlineSpan> spans = [];
    final Iterable<RegExpMatch> matches = combinedRegExp.allMatches(text);

    int lastMatchEnd = 0;

    for (final match in matches) {
      // Thêm đoạn text trước liên kết hoặc tag
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // Xác định loại phát hiện (URL hoặc tag)
      final String matchedText = match.group(0)!;

      if (matchedText.startsWith('@')) {
        // Tag người dùng
        final String username = matchedText.substring(1); // Bỏ dấu @
        spans.add(
          TextSpan(
            text: matchedText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              decorationColor: color,
              fontSize: 18,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async => await openUserProfile(username),
          ),
        );
      } else {
        if (previewUrlMode) {
          spans.add(
            WidgetSpan(
              child: AnyLinkPreview(
                onTap: () => openLinkInWebView(matchedText),
                link: matchedText,
                displayDirection: UIDirection.uiDirectionHorizontal,
                cache: const Duration(hours: 1),
                backgroundColor: colors.last,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                bodyStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                placeholderWidget: const PlaceholderImageCustomWidget(),
                errorWidget: const ColoredBox(
                  color: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Oops!',
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                errorBody: 'Show my custom error body',
                errorTitle: 'Next one is youtube link, error title',
              ),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: matchedText,
              style: TextStyle(
                color: color,
                decoration: TextDecoration.underline,
                decorationColor: color,
                decorationThickness: 2,
                fontStyle: FontStyle.italic,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => openLinkInWebView(matchedText),
            ),
          );
        }
      }

      lastMatchEnd = match.end;
    }

    // Thêm đoạn text sau liên kết hoặc tag cuối cùng
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }

// Hàm để xây dựng TextSpan với định dạng cho các liên kết và tag
  // static TextSpan buildMessageText(
  //   return TextSpan(children: spans);
  // }

  // Mở liên kết trong WebView
  static void openLinkInWebView(String url) {
    final String formattedUrl = url.contains('http') ? url : 'https://$url';
    Get.to(() => WebViewOpen(url: formattedUrl), transition: Transition.zoom);
  }

  // Điều hướng đến trang hồ sơ của người dùng
  static Future<void> openUserProfile(String username) async {
    FetchFirestoreDataFunctions fetchFirestoreDataFunctions =
        FetchFirestoreDataFunctions();
    final UserModel? tagUser =
        await fetchFirestoreDataFunctions.fetchUserByName(username);
    if (tagUser != null) {
      Get.to(
          () => UserAboutPage(
                intdexString: username,
                unknownableUser: tagUser,
              ),
          transition: Transition.zoom);
    } else {
      errorMessage("This player profile is not exist");
    }
    // Thay thế bằng logic điều hướng đến trang hồ sơ của bạn
  }

  static TextSpan parseContent({
    required String content,
    required TextStyle defaultStyle,
    required Color linkColor,
    required Color tagColor,
  }) {
    final List<TextSpan> spans = [];
    final matches = combinedRegExp.allMatches(content);

    int lastMatchEnd = 0;

    for (final match in matches) {
      // Thêm đoạn text trước link hoặc tag
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: content.substring(lastMatchEnd, match.start),
          style: defaultStyle,
        ));
      }

      final matchedText = match.group(0)!;

      if (matchedText.startsWith('@')) {
        // Phát hiện tag @username
        final username = matchedText.substring(1);
        spans.add(
          TextSpan(
            text: matchedText,
            style: defaultStyle.copyWith(
              color: tagColor,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async => await openUserProfile(username),
          ),
        );
      } else {
        // Phát hiện link URL
        spans.add(
          TextSpan(
            text: matchedText,
            style: defaultStyle.copyWith(
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor.withOpacity(0.5),
              decorationThickness: 2,
              fontStyle: FontStyle.italic,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => openLinkInWebView(matchedText),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // Thêm đoạn text sau link hoặc tag cuối cùng
    if (lastMatchEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastMatchEnd),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
