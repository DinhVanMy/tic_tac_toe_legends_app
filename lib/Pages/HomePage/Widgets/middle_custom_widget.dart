import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Controller/Animations/carousel_controller.dart';

// UI
class MiddleCustomWidget extends StatelessWidget {
  const MiddleCustomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CarouselController carouselController = Get.put(CarouselController());
    return PageView.builder(
      controller: carouselController.pageController,
      itemCount: carouselController.virtualItemCount,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        int realIndex = carouselController.getRealIndex(index);
        return Obx(() {
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
        });
      },
    );
  }
}
