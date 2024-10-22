import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Test/carousel_3d/rotation_animation_controller.dart';

class RotationScene extends StatelessWidget {
  const RotationScene({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng Get.put() để khởi tạo controller
    final rotationController = Get.put(RotationController());

    return Scaffold(
      bottomNavigationBar: SceneCardSelector(
        rotationController: rotationController,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff74ABE4), Color(0xffA892ED)],
            stops: [0, 1],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) => rotationController.onPanStart(),
          onPanUpdate: rotationController.onPanUpdate,
          onPanEnd: (_) => rotationController.onPanEnd(),
          child: Center(
            child: Obx(() {
              rotationController.processPositions();
              return Stack(
                alignment: Alignment.center,
                children: rotationController.cardData
                    .map((vo) =>
                        addCard(vo, rotationController.scaleController!.value))
                    .toList(),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget addCard(CardData vo, double scaleValue) {
    const List<String> images = [
      ImagePath.board_11x11,
      ImagePath.board_9x9,
      ImagePath.board_6x6,
      ImagePath.board_3x3,
      ImagePath.board_11x11,
      ImagePath.board_9x9,
      ImagePath.board_6x6,
      ImagePath.board_3x3,
      ImagePath.board_11x11,
      ImagePath.board_9x9,
    ];
    var alpha = ((1 - vo.z! / 200.0) / 2) * .6;
    return Transform(
      alignment: Alignment.center,
      origin: Offset(0.0, -100 - scaleValue * 200.0),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(vo.x, vo.y!, -vo.z!)
        ..rotateY(vo.angle! + pi),
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 120,
        height: 80,
        alignment: Alignment.center,
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(alpha),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, .9],
            colors: [vo.lightColor, vo.color!],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2 + alpha * .2),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Image.asset(images[vo.idx!]),
          ],
        ),
      ),
    );
  }
}

class SceneCardSelector extends StatelessWidget {
  final RotationController rotationController;
  const SceneCardSelector({super.key, required this.rotationController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 80,
      child: Row(
        children: List.generate(
          10,
          (index) => Expanded(
            child: SizedBox(
              height: 80,
              child: TextButton(
                child: Text(index.toString()),
                onPressed: () {
                  rotationController.onSelectCard.value = index;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
