import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DraggableFloatingActionButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;

  const DraggableFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    RxDouble posX = 391.0.obs;
    RxDouble posY = 661.0.obs;
    final RxBool isDragging = false.obs;
    return Obx(() => Positioned(
          left: posX.value,
          top: posY.value,
          child: GestureDetector(
            onPanStart: (_) {
              // Bắt đầu kéo
              isDragging.value = true;
            },
            onPanUpdate: (details) {
              posX.value = (posX.value + details.delta.dx)
                  .clamp(0.0, maxWidth - 56); // Trừ đi kích thước của nút
              posY.value =
                  (posY.value + details.delta.dy).clamp(0.0, maxHeight - 56);
            },
            onPanEnd: (_) {
              // Kết thúc kéo
              isDragging.value = false;
            },
            onTap: null,
            child: Obx(() => FloatingActionButton(
                  splashColor: Colors.white,
                  backgroundColor:
                      isDragging.value ? Colors.blueGrey : Colors.blueAccent,
                  onPressed: () {
                    // Chỉ chạy onPressed nếu không phải đang kéo
                    if (!isDragging.value && onPressed != null) {
                      onPressed!();
                    }
                  },
                  child: child,
                )),
          ),
        ));
  }
}

class DraggableFloatingActionButton2 extends StatelessWidget {
  const DraggableFloatingActionButton2({super.key});

  @override
  Widget build(BuildContext context) {
    var position = const Offset(10, 10).obs;
    return Obx(() => Positioned(
          left: position.value.dx,
          top: position.value.dy,
          child: Draggable(
            feedback: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {}, // Hiệu ứng bấm sẽ có trong feedback
            ),
            childWhenDragging: Container(), // Trống khi kéo
            onDragEnd: (details) {
              position.value = details.offset;
            },
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {}, // Hiệu ứng bấm sẽ có trong child
            ),
          ),
        ));
  }
}
