import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/controllers/bubble_shooter_gameplay_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/bubble_grid_ui.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/animated_combo_message.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/animated_score_display.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/bubble_background.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/bubble_collision_ripple.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/countdown_widget.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/game_state_overlay.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/powerup_button.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/screen_shake_widget.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/shooter_area.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/shooting_path_overlay.dart';

class BubbleShooterGame extends StatelessWidget {
  final String level;

  const BubbleShooterGame({super.key, this.level = 'Medium'});

  @override
  Widget build(BuildContext context) {
    final BubbleShooterController controller = Get.put(
      BubbleShooterController(
        level: level,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bubble Shooter',
          style: TextStyle(
            fontFamily: "Orbitron",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // Điểm số với hiệu ứng
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: AnimatedScoreDisplay(
                    score: controller.score.value,
                    previousScore:
                        controller.score.value - 10, // Giả định điểm trước đó
                    style: const TextStyle(
                      fontFamily: "Orbitron",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),
          IconButton(
            onPressed: () => controller.resetGame(),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 26,
            ),
          ),
          Obx(() => IconButton(
                onPressed: () {
                  if (controller.isGamePaused.value) {
                    controller.resumeGame();
                  } else {
                    controller.pauseGame();
                  }
                },
                icon: Icon(
                  controller.isGamePaused.value
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  size: 26,
                ),
              )),
        ],
      ),
      body: SafeArea(
        child: ScreenShakeWidget(
          isShaking: false, // Kích hoạt khi có combo lớn
          child: Stack(
            children: [
              // Nền đẹp hơn
              const BubbleBackground(),

              // Game content
              Column(
                children: [
                  // Game information
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Obx(() => Text(
                                  'Level: ${controller.currentLevel.value}',
                                  style: const TextStyle(
                                    fontFamily: "Orbitron",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                )),
                          ],
                        ),
                        Obx(() {
                          final message = controller.comboMessage.value;
                          return message.isNotEmpty
                              ? AnimatedComboMessage(message: message)
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  // Power-up bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PowerupButton(
                          icon: Icons.flash_on,
                          label: 'Bomb',
                          onPressed: () {
                            // Kích hoạt power-up bom
                          },
                        ),
                        PowerupButton(
                          icon: Icons.colorize,
                          label: 'Color',
                          onPressed: () {
                            // Kích hoạt power-up đổi màu
                          },
                        ),
                        PowerupButton(
                          icon: Icons.ac_unit,
                          label: 'Freeze',
                          onPressed: () {
                            // Kích hoạt power-up đóng băng
                          },
                          isActive: false, // Chưa mở khóa
                        ),
                      ],
                    ),
                  ),

                  // Bubble grid area
                  Expanded(
                    flex: 75,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(4.0),
                      child: BubbleGridUI(controller: controller),
                    ),
                  ),

                  // Shooter area
                  Expanded(
                    flex: 25,
                    child: Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      child: ShooterArea(controller: controller),
                    ),
                  ),
                ],
              ),

              // Path overlay
              Obx(() {
                return controller.isShowingPath.value
                    ? ShootingPathOverlay(controller: controller)
                    : const SizedBox.shrink();
              }),

              // Countdown timer khi sắp thêm hàng mới
              Obx(() {
                // Hiển thị đếm ngược khi sắp đến lượt thêm hàng mới
                if (controller.shootCount.value > 0 &&
                    controller.shootCount.value % controller.newRowInterval ==
                        controller.newRowInterval - 1) {
                  return Positioned(
                    top: 100,
                    right: 20,
                    child: CountdownWidget(
                      seconds: 3, // Đếm ngược 3 giây
                      onComplete: () {
                        // Không cần làm gì vì controller đã tự động thêm hàng
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Game state messages
              Obx(() {
                if (controller.gameOver.value) {
                  return const GameStateOverlay(
                    message: 'GAME OVER',
                    color: Colors.red,
                  );
                } else if (controller.victory.value) {
                  return const GameStateOverlay(
                    message: 'VICTORY!',
                    color: Colors.green,
                  );
                } else if (controller.isGamePaused.value) {
                  return const GameStateOverlay(
                    message: 'PAUSED',
                    color: Colors.blue,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),

              // Collision effect - hiệu ứng khi va chạm
              // Được hiển thị khi bóng va chạm với lưới
              Obx(() {
                if (controller.shotBubble.value == null &&
                    controller.isBusy.value) {
                  // Vị trí va chạm (ví dụ)
                  final collisionPosition = Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 3,
                  );

                  return BubbleCollisionRipple(position: collisionPosition);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
