import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RotationController extends GetxController
    with GetTickerProviderStateMixin {
  var cardData = <CardData>[].obs; // List chứa thông tin các items
  double radio = 200.0;
  double radioStep = 0;
  bool isMousePressed = false;
  var dragX = 0.0.obs;
  var selectedAngle = 0.0.obs;
  var onSelectCard = 0.obs;
  int numItems = 10;

  AnimationController? scaleController;

  @override
  void onInit() {
    super.onInit();
    cardData.addAll(List.generate(numItems, (index) => CardData(index)));
    radioStep = (pi * 2) / numItems;

    scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    scaleController!.addListener(() {
      update();
    });

    onSelectCard.listen((idx) {
      dragX.value = 0;
      selectedAngle.value = -idx * radioStep;
    });
  }

  void onPanStart() {
    isMousePressed = true;
    scaleController!.animateTo(1,
        duration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn);
    update(); // Thông báo thay đổi trạng thái
  }

  void onPanUpdate(DragUpdateDetails e) {
    dragX.value += e.delta.dx;
    update();
  }

  void onPanEnd() {
    isMousePressed = false;
    scaleController!.animateTo(0,
        duration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn);
    update();
  }

  void processPositions() {
    var initAngleOffset = pi / 2 + (-dragX.value * .006);
    initAngleOffset += selectedAngle.value;

    // Cập nhật vị trí của mỗi item
    for (var c in cardData) {
      double ang = initAngleOffset + c.idx! * radioStep;
      c.angle = ang + pi / 2;
      c.x = cos(ang) * radio;
      c.z = sin(ang) * radio;
    }

    // Sắp xếp theo trục Z để hiển thị đúng chiều sâu
    cardData.sort((a, b) => a.z!.compareTo(b.z!));
    update();
  }

  @override
  void onClose() {
    scaleController!.stop();
    super.onClose();
  }
}

class CardData {
  Color? color;
  double? x, y, z, angle;
  final int? idx;
  double? alpha = 0;

  CardData(this.idx) {
    color = Colors.primaries[idx! % Colors.primaries.length];
    x = 0;
    y = 0;
    z = 0;
  }

  Color get lightColor {
    var val = HSVColor.fromColor(color!);
    return val.withSaturation(.5).withValue(.8).toColor();
  }
}
