import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' as foundation;

class GlobalEmojiPicker extends StatelessWidget {
  final RxBool isEmojiPickerVisible;
  final Function(String emoji) onEmojiSelected; // Hàm callback khi chọn emoji
  final Function()? onBackspacePressed; // Hàm callback khi nhấn backspace
  const GlobalEmojiPicker({
    super.key,
    required this.isEmojiPickerVisible,
    required this.onEmojiSelected,
    this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Obx(() {
      if (!isEmojiPickerVisible.value) {
        return const SizedBox.shrink();
      }
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white,
          child: EmojiPicker(
            // textEditingController: _controller,
            scrollController: scrollController,
            config: Config(
              height: 256,
              checkPlatformCompatibility: true,
              emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 28 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.2
                        : 1.0),
              ),
              skinToneConfig: const SkinToneConfig(),
              categoryViewConfig: const CategoryViewConfig(),
              bottomActionBarConfig: const BottomActionBarConfig(),
              searchViewConfig: const SearchViewConfig(),
            ),
          ),
        ),
      );
    });
  }
}

class CustomEmojiPicker extends StatelessWidget {
  final RxBool isEmojiPickerVisible;
  final Function(String emoji) onEmojiSelected; // Hàm callback khi chọn emoji
  final Function()? onBackspacePressed; // Hàm callback khi nhấn backspace
  final double height; // Chiều cao của Emoji Picker
  final TextStyle? emojiTextStyle; // Kiểu chữ cho emoji
  final List<Color> backgroundColor; // Màu nền của picker
  final bool isSearchEmo;

  const CustomEmojiPicker({
    super.key,
    required this.onEmojiSelected,
    this.onBackspacePressed,
    this.height = 300,
    this.emojiTextStyle,
    required this.backgroundColor,
    required this.isEmojiPickerVisible,
    this.isSearchEmo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => isEmojiPickerVisible.value
        ? EmojiPicker(
            onEmojiSelected: (category, emoji) => onEmojiSelected(emoji.emoji),
            onBackspacePressed: onBackspacePressed,
            config: Config(
              height: height,
              checkPlatformCompatibility: true,
              emojiTextStyle: emojiTextStyle ?? const TextStyle(fontSize: 28),
              emojiViewConfig: _buildEmojiViewConfig(),
              skinToneConfig: _buildSkinToneConfig(),
              categoryViewConfig: _buildCategoryViewConfig(),
              bottomActionBarConfig: isSearchEmo
                  ? _buildBottomActionBarConfig()
                  : BottomActionBarConfig(
                      customBottomActionBar: (config, state, showSearchView) =>
                          const SizedBox(),
                    ),
              searchViewConfig: isSearchEmo
                  ? _buildSearchViewConfig()
                  : SearchViewConfig(
                      customSearchView: (config, state, showEmojiView) =>
                          const SizedBox(),
                    ),
            ),
          )
        : const SizedBox.shrink());
  }

  EmojiViewConfig _buildEmojiViewConfig() {
    return EmojiViewConfig(
      columns: 8,
      emojiSizeMax: 32.0,
      backgroundColor: backgroundColor.first.withOpacity(0.3),
      verticalSpacing: 10,
      horizontalSpacing: 8,
      gridPadding: const EdgeInsets.symmetric(horizontal: 10),
      recentsLimit: 30,
      replaceEmojiOnLimitExceed: true,
      loadingIndicator: const CircularProgressIndicator(),
      buttonMode: ButtonMode.MATERIAL,
    );
  }

  SkinToneConfig _buildSkinToneConfig() {
    return const SkinToneConfig(
      dialogBackgroundColor: Colors.white,
      indicatorColor: Colors.grey,
    );
  }

  CategoryViewConfig _buildCategoryViewConfig() {
    return CategoryViewConfig(
      tabBarHeight: 50,
      tabIndicatorAnimDuration: const Duration(milliseconds: 200),
      backgroundColor: backgroundColor.last.withOpacity(0.7),
      indicatorColor: Colors.blue,
      iconColor: Colors.blueGrey,
      iconColorSelected: Colors.white,
      backspaceColor: Colors.red,
      categoryIcons: const CategoryIcons(),
      customCategoryView: null,
    );
  }

  BottomActionBarConfig _buildBottomActionBarConfig() {
    return const BottomActionBarConfig(
      showBackspaceButton: true,
      showSearchViewButton: true,
      backgroundColor: Colors.blueGrey,
      buttonIconColor: Colors.white,
      customBottomActionBar: null,
    );
  }

  SearchViewConfig _buildSearchViewConfig() {
    return const SearchViewConfig(
      buttonColor: Colors.black,
      buttonIconColor: Colors.black26,
      hintText: 'Search Emoji...',
      customSearchView: null,
    );
  }
}
