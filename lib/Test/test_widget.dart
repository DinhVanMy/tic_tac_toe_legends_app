import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Slider Example')),
      body: CallSlider(
        onAccept: () {
          print('Call Accepted');
        },
        onDecline: () {
          print('Call Declined');
        },
      ),
    );
  }
}

class CallSliderController extends GetxController {
  var dragPosition = 0.0.obs; // Vị trí kéo
  var isShrinking = false.obs; // Trạng thái thu nhỏ
  var targetSide = 0.obs; // Hướng thu nhỏ (-1: Decline, 1: Accept)

  // Cập nhật vị trí kéo
  void updateDragPosition(double delta) {
    if (isShrinking.value) return;

    dragPosition.value += delta;
    dragPosition.value = dragPosition.value.clamp(-120.0, 120.0);
  }

  // Kết thúc kéo
  void onDragEnd({
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    if (dragPosition.value > 100) {
      startShrinkEffect(1, onAccept); // Shrink về Accept
    } else if (dragPosition.value < -100) {
      startShrinkEffect(-1, onDecline); // Shrink về Decline
    } else {
      resetDragPosition();
    }
  }

  // Bắt đầu hiệu ứng thu nhỏ
  void startShrinkEffect(int side, VoidCallback callback) {
    isShrinking.value = true;
    targetSide.value = side;

    Future.delayed(const Duration(milliseconds: 500), () {
      callback();
      resetDragPosition();
    });
  }

  // Reset trạng thái kéo
  void resetDragPosition() {
    dragPosition.value = 0.0;
    isShrinking.value = false;
    targetSide.value = 0;
  }
}

class CallSlider extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const CallSlider({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final CallSliderController controller = Get.put(CallSliderController());

    return Center(
      child: Obx(() {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: controller.isShrinking.value ? 70 : 300,
          height: 80,
          alignment: controller.isShrinking.value
              ? (controller.targetSide.value > 0
                  ? Alignment.centerRight
                  : Alignment.centerLeft)
              : Alignment.center,
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
              // Text Decline và Accept
              if (!controller.isShrinking.value)
                const Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 40), // Giới hạn khoảng cách
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Decline",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Đảm bảo không overflow
                          ),
                        ),
                        Flexible(
                          child: Text(
                            "Accept",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Đảm bảo không overflow
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Nút trượt
              Obx(() {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: controller.isShrinking.value
                      ? (controller.targetSide.value > 0 ? 230 : -90)
                      : 115 + controller.dragPosition.value,
                  curve: Curves.easeOut,
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
                        child: Icon(
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
        );
      }),
    );
  }
}
