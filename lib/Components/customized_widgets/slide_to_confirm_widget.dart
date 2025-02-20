import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallSliderController extends GetxController {
  // Vị trí kéo (từ -120 đến 120)
  var dragPosition = 0.0.obs;

  // Hàm xử lý cập nhật vị trí kéo
  void updateDragPosition(double delta) {
    dragPosition.value += delta;

    // Giới hạn vị trí kéo
    if (dragPosition.value > 120) {
      dragPosition.value = 120;
    } else if (dragPosition.value < -120) {
      dragPosition.value = -120;
    }
  }

  // Hàm xử lý khi người dùng kết thúc kéo
  void onDragEnd({
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    if (dragPosition.value > 100) {
      onAccept();
    } else if (dragPosition.value < -100) {
      onDecline();
    } else {
      resetDragPosition();
    }
  }

  // Hàm reset vị trí kéo
  void resetDragPosition() {
    dragPosition.value = 0.0;
  }
}

class CallSlider extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isVideoCall;

  const CallSlider({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final CallSliderController controller = Get.put(CallSliderController());

    return Center(
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[400]!, Colors.grey[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Text for Decline and Accept
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    "Decline",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Text(
                    "Accept",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Sliding Ball with Animation
            Obx(() {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: 115 + controller.dragPosition.value,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    controller.updateDragPosition(details.delta.dx);
                  },
                  onHorizontalDragEnd: (details) {
                    controller.onDragEnd(
                      onAccept: onAccept,
                      onDecline: onDecline,
                    );
                  },
                  child: Transform.rotate(
                    angle: controller.dragPosition.value / 120,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isVideoCall
                          ? Icon(
                              Icons.video_call_rounded,
                              color: controller.dragPosition.value != 0
                                  ? controller.dragPosition.value > 0
                                      ? Colors.blue
                                      : Colors.red
                                  : Colors.black,
                              size: 36,
                            )
                          : Icon(
                              Icons.phone,
                              color: controller.dragPosition.value != 0
                                  ? controller.dragPosition.value > 0
                                      ? Colors.green
                                      : Colors.red
                                  : Colors.black,
                              size: 36,
                            ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
