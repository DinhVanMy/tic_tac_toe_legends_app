import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/model/bubble_models.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/controllers/bubble_shooter_gameplay_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/animated_bubble_scale.dart';

class ShooterArea extends StatelessWidget {
  final BubbleShooterController controller;

  const ShooterArea({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!controller.isGamePaused.value &&
            !controller.gameOver.value &&
            !controller.victory.value &&
            !controller.isBusy.value) {
          final target = Offset(
            details.localPosition.dx / MediaQuery.of(context).size.width,
            details.localPosition.dy / MediaQuery.of(context).size.height,
          );
          controller.calculateShootingPath(target);
        }
      },
      onPanEnd: (_) {
        if (!controller.isGamePaused.value &&
            !controller.gameOver.value &&
            !controller.victory.value &&
            controller.isShowingPath.value &&
            !controller.isBusy.value) {
          controller.shootBubble();
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Shooter base
            Positioned(
              bottom: 0,
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            
            // Current bubble
            Positioned(
              bottom: 30,
              child: Obx(() => 
                AnimatedBubbleScale2(
                  isActive: controller.isShowingPath.value,
                  child: CurrentBubbleWidget(bubble: controller.activeBubble.value),
                ),
              ),
            ),
            
            // Next bubble indicator
            Positioned(
              bottom: 10,
              right: 20,
              child: Row(
                children: [
                  const Text(
                    'Next:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => NextBubbleWidget(bubble: controller.nextBubble.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrentBubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const CurrentBubbleWidget({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(bubble.heroAsset),
      ),
    );
  }
}

class NextBubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const NextBubbleWidget({super.key, required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(bubble.heroAsset),
      ),
    );
  }
}