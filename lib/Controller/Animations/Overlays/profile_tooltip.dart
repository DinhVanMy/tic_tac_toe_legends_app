import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/profile_tooltip_widget.dart';
import 'package:tictactoe_gameapp/Controller/Animations/Overlays/draw_tria.dart';
import 'package:tictactoe_gameapp/Enums/popup_position.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';

class ProfileTooltip extends GetxController
    with GetSingleTickerProviderStateMixin {
  final Rx<OverlayEntry?> _popupEntry = Rx<OverlayEntry?>(null);
  RxBool isPopupVisible = false.obs; // Để kiểm soát trạng thái của popup

  late AnimationController animationController;
  late Animation<Offset> slideAnimation; // Animation cho hiệu ứng trượt
  late Animation<double> opacityAnimation; // Animation cho độ mờ

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo AnimationController cho các hiệu ứng
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Thời gian cho animation
      vsync: this,
    );

    // Khởi tạo các hiệu ứng cho slide và fade
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1), // Điểm bắt đầu (dưới ra trên)
      end: Offset.zero, // Điểm kết thúc
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut, // Đường cong animation
    ));

    opacityAnimation = Tween<double>(
      begin: 0.0, // Bắt đầu từ độ mờ 0
      end: 1.0, // Đến độ mờ 1
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn, // Đường cong animation mờ dần
    ));
  }

  // Hiển thị popup
  void showProfileTooltip(
    BuildContext context,
    GlobalKey itemKey,
    UserModel user,
    PopupPosition position,
    double? width, // Chiều rộng của popup
    double? height, // Chiều cao của popup
    Duration? autoDismissDuration, // Thời gian tự động đóng popup
  ) {
    final renderBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final widgetPosition =
        renderBox.localToGlobal(Offset.zero); // Lấy vị trí của widget bấm
    final widgetSize = renderBox.size; // Lấy kích thước của widget bấm

    if (_popupEntry.value != null) {
      // Xóa popup cũ nếu đã hiển thị
      removePopup();
    }

    // Tính toán vị trí của popup và tam giác
    final popupOffsetAndAlignment = _calculatePopupPositionAndAlignment(
      widgetPosition,
      widgetSize,
      position,
      width: width ?? 200, // Chiều rộng của popup
      height: height ?? 200, // Chiều cao của popup
    );

    // Tạo OverlayEntry cho popup
    _popupEntry.value = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => removePopup(), // Đóng popup khi bấm ra ngoài
            child: Container(
              color: Colors.transparent, // Vùng overlay trong suốt
            ),
          ),
          Positioned(
            left: popupOffsetAndAlignment.popupOffset.dx,
            top: popupOffsetAndAlignment.popupOffset.dy,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: Column(
                  children: [
                    if (popupOffsetAndAlignment.triangleAlignment ==
                        Alignment.bottomCenter)
                      CustomPaint(
                        size: const Size(20, 20),
                        painter: TrianglePainter(
                          color: Colors.white,
                          alignment: popupOffsetAndAlignment.triangleAlignment,
                        ),
                      ),
                    Row(
                      children: [
                        if (popupOffsetAndAlignment.triangleAlignment ==
                                Alignment.centerRight ||
                            popupOffsetAndAlignment.triangleAlignment ==
                                Alignment.centerLeft)
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: TrianglePainter(
                              color: Colors.white,
                              alignment:
                                  popupOffsetAndAlignment.triangleAlignment,
                            ),
                          ),
                        Material(
                          elevation: 5.0,
                          textStyle: const TextStyle(
                            color: Colors.blue,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          type: MaterialType.card,
                          child: ProfileTooltipCustom(
                            friend: user,
                            onTapInfo: () {
                              removePopup();
                              Get.to(
                                  UserAboutPage(
                                    unknownableUser: user,
                                  ),
                                  transition: Transition.fadeIn);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (popupOffsetAndAlignment.triangleAlignment ==
                        Alignment.topCenter)
                      CustomPaint(
                        size: const Size(20, 40),
                        painter: TrianglePainter(
                          color: Colors.white,
                          alignment: popupOffsetAndAlignment.triangleAlignment,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Hiển thị popup
    Overlay.of(context).insert(_popupEntry.value!);
    animationController.forward();
    isPopupVisible.value = true; // Bật trạng thái popup đang hiển thị

    if (autoDismissDuration != null) {
      Future.delayed(autoDismissDuration, removePopup);
    }
  }

  // Xóa popup
  void removePopup() {
    if (_popupEntry.value != null) {
      animationController.reverse().then((_) {
        // Đảo ngược animation khi xóa
        _popupEntry.value?.remove();
        _popupEntry.value = null;
        isPopupVisible.value = false; // Cập nhật trạng thái popup
      });
    }
  }

  // Tính toán vị trí và alignment của popup và tam giác
  _PopupOffsetAndAlignment _calculatePopupPositionAndAlignment(
    Offset widgetPosition,
    Size widgetSize,
    PopupPosition position, {
    required double width,
    required double height,
  }) {
    Offset popupOffset;
    Alignment triangleAlignment;
    const double padding = 0.0; // Khoảng cách giữa overlay và widget

    switch (position) {
      case PopupPosition.above:
        // Popup nằm trên CircleAvatar
        popupOffset = Offset(
          widgetPosition.dx - (width / 2) + (widgetSize.width / 2),
          widgetPosition.dy - height - padding,
        );
        triangleAlignment = Alignment.topCenter;
        break;
      case PopupPosition.below:
        // Popup nằm dưới CircleAvatar
        popupOffset = Offset(
          widgetPosition.dx - (width / 2) + (widgetSize.width / 2),
          widgetPosition.dy + widgetSize.height + padding,
        );
        triangleAlignment = Alignment.bottomCenter;
        break;
      case PopupPosition.left:
        // Popup nằm bên trái CircleAvatar
        popupOffset = Offset(
          widgetPosition.dx - width - padding,
          widgetPosition.dy - (height / 2) + (widgetSize.height / 2),
        );
        triangleAlignment = Alignment.centerRight;
        break;
      case PopupPosition.right:
        // Popup nằm bên phải CircleAvatar
        popupOffset = Offset(
          widgetPosition.dx + widgetSize.width + padding,
          widgetPosition.dy - (height / 4),
          //   widgetPosition.dy - (height / 2) + (widgetSize.height / 2),
        );
        triangleAlignment = Alignment.centerLeft;
        break;
    }

    return _PopupOffsetAndAlignment(popupOffset, triangleAlignment);
  }

  @override
  void onClose() {
    animationController.dispose();
    removePopup();
    super.onClose();
  }
}

class _PopupOffsetAndAlignment {
  final Offset popupOffset;
  final Alignment triangleAlignment;

  _PopupOffsetAndAlignment(this.popupOffset, this.triangleAlignment);
}
