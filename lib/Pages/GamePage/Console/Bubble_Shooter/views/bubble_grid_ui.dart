import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/model/bubble_models.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/controllers/bubble_shooter_gameplay_controller.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/bubble_widget.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/utils/device_detector.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/particle_system.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/effects/trail_effect.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/falling_bubble_physics.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/glowing_bubble.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/views/components/pulsing_bubble_hint.dart';

class BubbleGridUI extends StatelessWidget {
  final BubbleShooterController controller;

  const BubbleGridUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final gridHeight =
        MediaQuery.of(context).size.height * controller.gridHeightFactor;
    final gridWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final gridBubbles = controller.grid.value.grid;
      final animatingBubbles = controller.animatingBubbles;
      final showAnimation = controller.showAnimation.value;

      // Tính toán kích thước bóng dựa trên số cột và thiết bị
      final bubbleSize =
          DeviceDetector.getBubbleSizeForDevice(context, gridBubbles[0].length);

      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Lưới cố định - Sử dụng RepaintBoundary cho hiệu suất tốt hơn
              RepaintBoundary(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: gridHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        min(gridBubbles.length,
                            (gridHeight / bubbleSize).floor()),
                        (rowIndex) {
                          final row = gridBubbles[rowIndex];
                          // Add offset for even rows (hexagonal grid)
                          final rowOffset =
                              rowIndex % 2 == 0 ? 0.0 : bubbleSize / 2;
                          return SizedBox(
                            height: bubbleSize,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: rowOffset),
                                  ...List.generate(row.length, (colIndex) {
                                    final bubble = row[colIndex];
                                    if (bubble != null) {
                                      // Skip if bubble is animating
                                      if (showAnimation &&
                                          animatingBubbles.any((animBubble) =>
                                              animBubble.row == rowIndex &&
                                              animBubble.col == colIndex)) {
                                        return SizedBox(
                                            width: bubbleSize,
                                            height: bubbleSize);
                                      }
                                      final canMatch =
                                          _canBubbleMatch(bubble, gridBubbles);

                                      return PulsingBubbleHint(
                                        isHinting: canMatch &&
                                            controller.shootCount.value % 5 ==
                                                0, // Gợi ý sau mỗi 5 lần bắn
                                        child: BubbleWidget(
                                          bubble: bubble,
                                          size: bubbleSize,
                                          animationType: bubble.animationType,
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                          width: bubbleSize,
                                          height: bubbleSize);
                                    }
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Bóng đang bay - chỉ hiển thị khi không có animation
              if (!controller.bubbleAnimation.value &&
                  controller.shotBubble.value != null)
                Positioned(
                  left: controller.shotBubble.value!.position.dx * gridWidth -
                      bubbleSize / 2,
                  top: controller.shotBubble.value!.position.dy * gridHeight -
                      bubbleSize / 2,
                  child: Stack(
                    children: [
                      // Trail effect - hiệu ứng vệt sáng khi bóng bay
                      Positioned(
                        left: -gridWidth,
                        top: -gridHeight,
                        child: TrailEffect(
                          trailPoints: [
                            Offset(
                                controller.shotBubble.value!.position.dx *
                                        gridWidth +
                                    bubbleSize / 2,
                                controller.shotBubble.value!.position.dy *
                                        gridHeight +
                                    bubbleSize / 2),
                            Offset(
                                controller.shotBubble.value!.position.dx *
                                        gridWidth -
                                    cos(controller.shotBubble.value!.angle) *
                                        30 +
                                    bubbleSize / 2,
                                controller.shotBubble.value!.position.dy *
                                        gridHeight -
                                    sin(controller.shotBubble.value!.angle) *
                                        30 +
                                    bubbleSize / 2),
                          ],
                          color: Colors.white.withOpacity(0.5),
                          width: 4,
                        ),
                      ),

                      // Bóng
                      BubbleWidget(
                        bubble: controller.shotBubble.value!,
                        size: bubbleSize,
                        animationType: AnimationType.shoot,
                      ),
                    ],
                  ),
                ),

              // Hiệu ứng bóng đang bay với animation
              if (controller.bubbleAnimation.value &&
                  controller.shotBubble.value != null)
                Obx(() {
                  final progress = controller.animationProgress.value;
                  final pathPoints = controller.pathPoints;

                  if (pathPoints.isEmpty) return const SizedBox.shrink();

                  final pathIndex = min(
                    (progress * (pathPoints.length - 1)).floor(),
                    pathPoints.length - 1,
                  );

                  final position = pathPoints[pathIndex];

                  // Tạo các điểm đường đi gần đây để vẽ vệt sáng
                  final recentPoints = pathIndex > 5
                      ? pathPoints.sublist(pathIndex - 5, pathIndex + 1)
                      : pathPoints.sublist(0, pathIndex + 1);

                  final trailPoints = recentPoints
                      .map((point) => Offset(
                            point.dx * gridWidth + bubbleSize / 2,
                            point.dy * gridHeight + bubbleSize / 2,
                          ))
                      .toList();

                  return Stack(
                    children: [
                      // Vệt sáng
                      if (trailPoints.length > 1)
                        TrailEffect(
                          trailPoints: trailPoints,
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),

                      // Bóng với hiệu ứng
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 50),
                        curve: Curves.linear,
                        left: position.dx * gridWidth - bubbleSize / 2,
                        top: position.dy * gridHeight - bubbleSize / 2,
                        child: GlowingBubble(
                          glowColor: Colors.white,
                          child: BubbleWidget(
                            bubble: controller.shotBubble.value!,
                            size: bubbleSize,
                            scale: 1.0 +
                                sin(progress * pi * 3) *
                                    0.1, // Thêm hiệu ứng nhấp nháy khi bóng bay
                            animationType: AnimationType.shoot,
                          ),
                        ),
                      ),
                    ],
                  );
                }),

              // Hiệu ứng bóng nổ hoặc rơi
              if (showAnimation)
                ...animatingBubbles.map((bubble) {
                  // Xác định vị trí của bóng trong lưới
                  final rowIndex = bubble.row;
                  final colIndex = bubble.col;
                  final rowOffset = rowIndex % 2 == 0 ? 0.0 : bubbleSize / 2;

                  // Tính vị trí của bóng trong lưới
                  final initialLeft = rowOffset + colIndex * bubbleSize;
                  final initialTop = rowIndex * bubbleSize;

                  if (bubble.animationType == AnimationType.detach) {
                    // Hiệu ứng rơi với vật lý thực
                    return FallingBubblePhysics(
                      bubble: bubble,
                      size: bubbleSize,
                      onComplete: () {
                        // Animation hoàn tất
                      },
                    );
                  } else if (bubble.animationType == AnimationType.match) {
                    // Hiệu ứng match/pop
                    return Stack(
                      children: [
                        // Bóng nổ
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            return Positioned(
                              left: initialLeft,
                              top: initialTop,
                              child: Opacity(
                                opacity: 1.0 - value,
                                child: Transform.scale(
                                  scale: 1.0 + value * 0.8,
                                  child: BubbleWidget(
                                    bubble: bubble,
                                    size: bubbleSize,
                                    animationType: AnimationType.match,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Hiệu ứng particles
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, value, child) {
                            if (value < 0.1) return const SizedBox.shrink();

                            return Positioned(
                              left: initialLeft + bubbleSize / 2,
                              top: initialTop + bubbleSize / 2,
                              child: ParticleSystem(
                                center: Offset.zero,
                                color: _getBubbleColor(bubble.color),
                                particleCount: 15,
                                size: 4,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    // Hiệu ứng mặc định
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Positioned(
                          left: initialLeft,
                          top: initialTop,
                          child: Opacity(
                            opacity: 1.0 - value,
                            child: Transform.scale(
                              scale: 1.0 + value * 0.5,
                              child: BubbleWidget(
                                bubble: bubble,
                                size: bubbleSize,
                                animationType: bubble.animationType,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
            ],
          );
        },
      );
    });
  }

  // Hàm kiểm tra bóng có thể match hay không
  bool _canBubbleMatch(Bubble bubble, List<List<Bubble?>> grid) {
    // Giả lập, trong thực tế sẽ cần thuật toán phù hợp
    final row = bubble.row;
    final col = bubble.col;
    final color = bubble.color;

    // Kiểm tra xem có ít nhất 2 bóng cùng màu kề nhau không
    int sameColorCount = 0;

    // Directions để kiểm tra các ô lân cận
    final directions = controller.grid.value.isEvenRow(row)
        ? [
            [-1, 0],
            [-1, 1],
            [0, 1],
            [1, 1],
            [1, 0],
            [0, -1]
          ] // Hàng chẵn
        : [
            [-1, -1],
            [-1, 0],
            [0, 1],
            [1, 0],
            [1, -1],
            [0, -1]
          ]; // Hàng lẻ

    for (final dir in directions) {
      final newRow = row + dir[0];
      final newCol = col + dir[1];

      if (newRow >= 0 &&
          newRow < grid.length &&
          newCol >= 0 &&
          newCol < grid[0].length &&
          grid[newRow][newCol] != null) {
        if (grid[newRow][newCol]?.color == color) {
          sameColorCount++;

          // Nếu có ít nhất 2 bóng cùng màu kề nhau, có thể tạo thành match
          if (sameColorCount >= 2) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Chuyển đổi tên màu thành Color
  Color _getBubbleColor(String colorName) {
    // Trong thực tế cần một map giữa tên champion và màu
    switch (colorName.toLowerCase()) {
      case 'aatrox':
        return Colors.red;
      case 'ahri':
        return Colors.orange;
      case 'akali':
        return Colors.green;
      case 'alistar':
        return Colors.purple;
      case 'amumu':
        return Colors.yellow;
      case 'anivia':
        return Colors.blue;
      case 'annie':
        return Colors.red[300]!;
      case 'ashe':
        return Colors.blue[300]!;
      default:
        return Colors.grey;
    }
  }
}
