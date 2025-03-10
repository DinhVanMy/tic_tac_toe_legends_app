import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DraggableFloatingActionButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;

  // Khởi tạo controller

  const DraggableFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final DraggableFABController controller = Get.put(DraggableFABController());
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;

    return Obx(() {
      // Lấy vị trí từ controller
      double left = controller.posX.value;
      double top = controller.posY.value;

      // Điều chỉnh vị trí khi button bị ẩn một nửa
      if (controller.isHalfHidden.value) {
        if (left < 0) left = -controller.buttonSize / 2; // Cạnh trái
        if (left > maxWidth - controller.buttonSize / 2) {
          left = maxWidth - controller.buttonSize / 2; // Cạnh phải
        }
        if (top < 0) top = -controller.buttonSize / 2; // Cạnh trên
        if (top > maxHeight - controller.buttonSize / 2) {
          top = maxHeight - controller.buttonSize / 2; // Cạnh dưới
        }
      }

      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          // Khi bắt đầu kéo
          onPanStart: (_) {
            controller.isDragging.value = true;
            controller.resetHideTimer();
          },
          // Khi đang kéo
          onPanUpdate: (details) {
            controller.updatePosition(details, maxWidth, maxHeight);
          },
          // Khi kết thúc kéo
          onPanEnd: (_) {
            controller.onPanEnd(maxWidth, maxHeight);
          },
          // Xử lý nhấn button
          onTap: () {
            if (!controller.isDragging.value && onPressed != null) {
              onPressed!();
            }
          },
          child: FloatingActionButton(
            splashColor: Colors.white,
            backgroundColor: controller.isDragging.value
                ? Colors.blueGrey
                : Colors.blueAccent,
            onPressed: null, // Đã xử lý ở onTap của GestureDetector
            child: child,
          ),
        ),
      );
    });
  }
}

class DraggableFABController extends GetxController {
  // Vị trí của button
  final RxDouble posX = 391.0.obs; // Vị trí mặc định ban đầu
  final RxDouble posY = 661.0.obs;

  // Trạng thái kéo và ẩn
  final RxBool isDragging = false.obs;
  final RxBool isHalfHidden = false.obs;

  // Kích thước button (giả sử là 56dp, có thể thay đổi)
  final double buttonSize = 56.0;

  // Timer để đếm thời gian không tương tác
  Timer? _hideTimer;

  // Bắt đầu đếm thời gian để ẩn button sau 5 giây
  void startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      isHalfHidden.value = true;
      // Mặc định ẩn vào cạnh phải
      posX.value = Get.width - buttonSize / 2;
    });
  }

  // Reset timer khi có tương tác
  void resetHideTimer() {
    isHalfHidden.value = false;
    startHideTimer();
  }

  // Cập nhật vị trí khi kéo
  void updatePosition(
      DragUpdateDetails details, double maxWidth, double maxHeight) {
    posX.value =
        (posX.value + details.delta.dx).clamp(0.0, maxWidth - buttonSize);
    posY.value =
        (posY.value + details.delta.dy).clamp(0.0, maxHeight - buttonSize);
    resetHideTimer();
  }

  // Xử lý khi kết thúc kéo
  void onPanEnd(double maxWidth, double maxHeight) {
    isDragging.value = false;
    // Kiểm tra vị trí để ẩn một nửa button nếu gần cạnh
    if (posX.value < buttonSize / 2) {
      posX.value = -buttonSize / 2; // Ẩn vào cạnh trái
      isHalfHidden.value = true;
    } else if (posX.value > maxWidth - buttonSize / 2) {
      posX.value = maxWidth - buttonSize / 2; // Ẩn vào cạnh phải
      isHalfHidden.value = true;
    } else if (posY.value < buttonSize / 2) {
      posY.value = -buttonSize / 2; // Ẩn vào cạnh trên
      isHalfHidden.value = true;
    } else if (posY.value > maxHeight - buttonSize / 2) {
      posY.value = maxHeight - buttonSize / 2; // Ẩn vào cạnh dưới
      isHalfHidden.value = true;
    } else {
      startHideTimer(); // Nếu không gần cạnh, bắt đầu đếm 5 giây
    }
  }

  @override
  void onClose() {
    _hideTimer?.cancel();
    super.onClose();
  }
}
