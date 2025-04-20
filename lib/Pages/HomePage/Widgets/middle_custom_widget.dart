import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'dart:math';

class MiddleCustomWidget extends StatelessWidget {
  MiddleCustomWidget({
    super.key,
  });
  final CarouselController carouselController =
      Get.put(CarouselController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    carouselController.reinitializePageController();
    return PageView.builder(
      controller: carouselController.pageController,
      itemCount: carouselController.virtualItemCount,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        int realIndex = carouselController.getRealIndex(index);
        return GestureDetector(
          onTap: () => Get.to(
            () => images[realIndex].page,
            transition: Transition.zoom,
            duration: duration750,
          ),
          child: Obx(() {
            return Transform(
              alignment: Alignment.center,
              transform: carouselController.build3DTransform(index),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        images[realIndex].image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: Text(
                          images[realIndex].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Text(
                      images[realIndex].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class CarouselController extends GetxController {
  final int realItemCount = images.length;
  late final int virtualItemCount;
  late PageController pageController;
  late var currentPage = (realItemCount * 500).toDouble().obs;

  @override
  void onInit() {
    super.onInit();
    virtualItemCount = realItemCount * 1000;
    _initializePageController();
  }

  void _initializePageController() {
    pageController =
        PageController(viewportFraction: 0.4, initialPage: realItemCount * 500);
    pageController.addListener(_pageListener);
  }

  void reinitializePageController() {
    pageController.removeListener(_pageListener);
    _initializePageController();
  }

  void _pageListener() {
    if (pageController.positions.length == 1) {
      currentPage.value = pageController.page!;
    }
  }

  int getRealIndex(int virtualIndex) {
    return virtualIndex % realItemCount;
  }

  Matrix4 build3DTransform(int index) {
    double offsetFromCenter = index - currentPage.value;
    double angle = offsetFromCenter * pi / 5;
    double scale = 1 - (offsetFromCenter.abs() * 0.3);
    double depth = -300 * cos(angle);

    return Matrix4.identity()
      ..rotateY(angle)
      ..translate(200 * sin(angle), 0.0, depth)
      ..scale(scale);
  }

  Color itemColor(int index) {
    double offsetFromCenter = (index - currentPage.value).abs();
    double opacity = 1 - offsetFromCenter * 0.5;
    opacity = opacity.clamp(0.0, 1.0);

    return Colors.red.withOpacity(opacity);
  }

  @override
  void onClose() {
    pageController.removeListener(_pageListener);
    pageController.dispose();
    super.onClose();
  }
}
