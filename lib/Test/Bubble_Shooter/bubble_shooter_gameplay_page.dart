import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/Bubble_Shooter/bubble_models.dart';
import 'package:tictactoe_gameapp/Test/Bubble_Shooter/bubble_shooter_gameplay_controller.dart';

class BubbleShooterGame extends StatelessWidget {
  const BubbleShooterGame({super.key});

  @override
  Widget build(BuildContext context) {
    final BubbleShooterController controller = Get.put(
      BubbleShooterController(
        level: 'Medium',
      ),
    );
    const TextStyle textStyleBig = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble Shooter Game', style: textStyleBig),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
              )),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.play_arrow_rounded,
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: BubbleGridUI(controller: controller),
              ),
              Expanded(
                flex: 1,
                child: CurrentAndNextBubble(controller: controller),
              ),
            ],
          ),
          ShootingPath(controller: controller),
        ],
      ),
    );
  }
}

class BubbleGridUI extends StatelessWidget {
  final BubbleShooterController controller;

  const BubbleGridUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gridBubbles = controller.grid.value.grid;
      final floatingBubbles = controller.bubbles;
      final bubbleSize =
          MediaQuery.of(context).size.width / gridBubbles[0].length;

      return Stack(
        children: [
          // Lưới cố định
          Column(
            children: gridBubbles.map((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((bubble) {
                  if (bubble != null) {
                    return Container(
                      width: bubbleSize,
                      height: bubbleSize,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(bubble.heroAsset),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  } else {
                    return SizedBox(width: bubbleSize, height: bubbleSize);
                  }
                }).toList(),
              );
            }).toList(),
          ),
          // Bóng đang bay
          ...floatingBubbles.map((bubble) {
            return Positioned(
              left: bubble.position.dx * MediaQuery.of(context).size.width,
              top: bubble.position.dy * MediaQuery.of(context).size.height,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bubble.heroAsset),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          Positioned(
            left: controller.targetPosition.value.dx *
                    MediaQuery.of(context).size.width -
                10,
            top: controller.targetPosition.value.dy *
                    MediaQuery.of(context).size.height -
                10,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class CurrentAndNextBubble extends StatelessWidget {
  final BubbleShooterController controller;

  const CurrentAndNextBubble({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bóng hiện tại
          BubbleWidget(bubble: controller.activeBubble.value),
          const SizedBox(width: 20),
          // Bóng tiếp theo
          BubbleWidget(bubble: Bubble.random(controller.selectedChamp)),
        ],
      );
    });
  }
}

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const BubbleWidget({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bubble.heroAsset),
          fit: BoxFit.cover,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

class ShootingPath extends StatelessWidget {
  final BubbleShooterController controller;

  const ShootingPath({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        final target = Offset(
          details.localPosition.dx / MediaQuery.of(context).size.width,
          details.localPosition.dy / MediaQuery.of(context).size.height,
        );
        controller.aimAt(target); // Cập nhật hướng bắn
      },
      onPanEnd: (_) {
        controller.shootBubble(); // Bắn bóng
      },
      child: Obx(() {
        // Lấy dữ liệu từ controller và chuyển cho CustomPainter
        final shooterPos = controller.shooterPosition.value;
        final targetPos = controller.targetPosition.value;

        return CustomPaint(
          size: Size.infinite,
          painter: ShootingPathPainter(
            shooterPos: shooterPos,
            targetPos: targetPos,
          ),
        );
      }),
    );
  }
}

class ShootingPathPainter extends CustomPainter {
  final Offset shooterPos;
  final Offset targetPos;

  ShootingPathPainter({required this.shooterPos, required this.targetPos});

  @override
  void paint(Canvas canvas, Size size) {
    final shooter = Offset(
      shooterPos.dx * size.width,
      shooterPos.dy * size.height,
    );
    final target = Offset(
      targetPos.dx * size.width,
      targetPos.dy * size.height,
    );

    final path = Path();
    path.moveTo(shooter.dx, shooter.dy);
    path.lineTo(target.dx, target.dy);

    final paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
