import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';

class StackImageWidget extends StatelessWidget {
  final List<String> imageUrls;
  const StackImageWidget({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return buildStackedImages(imageUrls);
  }

  Widget buildStackedImages(List<String> imageUrls) {
    return imageUrls.length < 2
        ? GestureDetector(
            onTap: () {
              _onTapToExtendImage();
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : SwipeDoubleTapStack(
            imageUrls: imageUrls,
          );
  }

  void _onTapToExtendImage() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(8),
            minScale: 0.00005,
            maxScale: 3,
            child: Container(
              width: double.infinity,
              height: 200,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(
                    base64Decode(imageUrls.first),
                  ),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
      ).animate().scale(duration: const Duration(milliseconds: 600)),
    );
  }
}

class NoneStackImageWidget extends StatelessWidget {
  final PostModel post;
  const NoneStackImageWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    var currentIndex = 0.obs;
    return SizedBox(
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: post.imageUrls!.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    currentIndex.value = index;
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: PageView.builder(
                            controller:
                                PageController(initialPage: currentIndex.value),
                            onPageChanged: (index) {
                              currentIndex.value = index;
                            },
                            itemCount: post.imageUrls!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: double.infinity,
                                height: 200,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(
                                        post.imageUrls![index],
                                      ),
                                    ),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                child: Text(
                                  "${index + 1} / ${post.imageUrls!.length}",
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              );
                              //  InteractiveViewer(
                              //   boundaryMargin:
                              //       const EdgeInsets.all(8),
                              //   minScale: 1,
                              //   maxScale: 3,
                              //   child:
                              //    ClipRRect(
                              //     borderRadius:
                              //         BorderRadius.circular(10),
                              //     child: Image.memory(
                              //       base64Decode(
                              //         post.imageUrls![index],
                              //       ),
                              //       width: double.infinity,
                              //     ),
                              //   ),
                              // );
                            },
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: const Duration(milliseconds: 750)),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(
                        post.imageUrls![index],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            );
          }),
    );
  }
}

class SwipeDoubleTapStack extends StatefulWidget {
  final List<String> imageUrls;

  const SwipeDoubleTapStack({super.key, required this.imageUrls});

  @override
  State<SwipeDoubleTapStack> createState() => _SwipeDoubleTapStackState();
}

class _SwipeDoubleTapStackState extends State<SwipeDoubleTapStack>
    with SingleTickerProviderStateMixin {
  late RxList<String> images;
  late RxInt topIndex;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    images = RxList<String>.from(widget.imageUrls);
    topIndex = RxInt(images.length - 1);

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _generateRandomDirection(), // Random hướng
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  /// Hàm xử lý sự kiện double tap
  void _onDoubleTap() {
    if (images.isEmpty) return;

    final String topImage = images[topIndex.value];

    // Cập nhật hiệu ứng
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _generateRandomDirection(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Chạy animation
    _controller.forward().then((_) {
      // Thay đổi trạng thái mà không cần setState
      images.removeAt(topIndex.value);
      images.insert(0, topImage);
      topIndex.value = images.length - 1;

      // Reset controller
      _controller.reset();
    });
  }

  Offset _generateRandomDirection() {
    final List<Offset> directions = [
      const Offset(1, 0), // Sang phải
      const Offset(-1, 0), // Sang trái
      const Offset(0, 1), // Xuống dưới
      const Offset(0, -1), // Lên trên
    ];
    return directions[Random().nextInt(directions.length)];
  }

  double _generateRandomAngle(int index) {
    final int sign = (index % 2 == 0) ? 1 : -1; // Quyết định chiều xoay
    final double baseAngle = 5 + index * 2; // Tăng dần theo index
    return sign * pi / 180 * (baseAngle + Random().nextDouble() * 5);
    // return (index % 3 == 0 ? -1 : 1) * pi / 180 * (5 + (index * 3) % 10);
  }

  void _onTapToExtendImageList({required int currentIndex}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: PageView.builder(
            controller: PageController(initialPage: currentIndex),
            onPageChanged: (index) {
              currentIndex = index;
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(8),
                minScale: 0.00005,
                maxScale: 3,
                child: Container(
                  height: 200,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(images[index])),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  child: Text(
                    "${index + 1} / ${images.length}",
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ).animate().scale(duration: const Duration(milliseconds: 750)),
    );
  }

  Widget _buildImage(String imageUrl, int index) {
    final bool isTopImage = index == topIndex.value;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOut,
      top: isTopImage ? 0 : 8.0 * (index - topIndex.value),
      left: isTopImage ? 0 : 8.0 * (index - topIndex.value),
      child: Transform.rotate(
        angle: _generateRandomAngle(index),
        child: GestureDetector(
          onDoubleTap: _onDoubleTap,
          onTap: () => _onTapToExtendImageList(currentIndex: topIndex.value),
          child: SlideTransition(
            position: isTopImage
                ? _offsetAnimation
                : const AlwaysStoppedAnimation(Offset.zero),
            child: Container(
              height: 100,
              width: MediaQuery.sizeOf(context).width / 2 - 25,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(-2, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          clipBehavior: Clip.none,
          children: images.asMap().entries.map((entry) {
            final index = entry.key;
            final imageUrl = entry.value;
            return _buildImage(imageUrl, index);
          }).toList(),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
