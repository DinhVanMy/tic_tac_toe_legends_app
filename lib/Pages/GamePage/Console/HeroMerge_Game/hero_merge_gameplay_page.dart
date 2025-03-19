import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/HeroMerge_Game/hero_merge_controller.dart';

class HeroMergeGameplayPage extends StatelessWidget {
  final int rows;
  final int columns;
  final int level;
  final String backgroundUrl;

  const HeroMergeGameplayPage({
    super.key,
    required this.rows,
    required this.columns,
    required this.level,
    required this.backgroundUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        HeroMergeController(rows: rows, columns: columns, level: level));
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 30, color: Colors.blue),
        ),
        title: Column(
          children: [
            const Text("Hero Merge", style: textStyle),
            Obx(() => Text("Score: ${controller.score.value}",
                style: textStyle.copyWith(fontSize: 15))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_left_rounded,
                size: 30, color: Colors.white),
            onPressed: controller.undoMove,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                size: 30, color: Colors.white),
            onPressed: controller.refreshGame,
          ),
          IconButton(
            icon: Obx(() => Icon(
                  controller.isPaused.value
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  size: 30,
                  color: Colors.white,
                )),
            onPressed: controller.togglePause,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Obx(() => Row(
                      children: List.generate(controller.columns, (col) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.tapToDrop(col),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                color: Colors.grey[200],
                              ),
                              child: Stack(
                                children: List.generate(controller.rows, (row) {
                                  final block = controller
                                      .gameBoard.value.grid[row][col].value;
                                  final blockHeight = 500 / controller.rows;
                                  final blockWidth =
                                      MediaQuery.of(context).size.width /
                                          controller.columns;
                                  return Positioned(
                                    top: (controller.rows - 1 - row) *
                                        blockHeight,
                                    child: Container(
                                      height: blockHeight,
                                      width: blockWidth,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: block != null
                                          ? AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              transform: Matrix4.identity()
                                                ..scale(block.mergeCount > 0
                                                    ? 1.1
                                                    : 1.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: block.mergeCount > 0
                                                      ? Colors.yellow
                                                      : Colors.black,
                                                  width: block.mergeCount > 0
                                                      ? 4
                                                      : 2,
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Image.asset(
                                                    block.hero,
                                                    fit: BoxFit.cover,
                                                    width: blockWidth,
                                                    height: blockHeight,
                                                    key: ValueKey(
                                                        "${row}_${col}_${block.value}_${block.mergeCount}"),
                                                  ),
                                                  if (block.mergeCount > 0)
                                                    Positioned(
                                                      top: 2,
                                                      right: 2,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Text(
                                                          "${block.mergeCount}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      }),
                    )),
                Obx(() {
                  final blockHeight = 500 / controller.rows;
                  final blockWidth =
                      MediaQuery.of(context).size.width / controller.columns;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 50),
                    curve: Curves.linear,
                    top: controller.blockPositionY.value,
                    left: blockWidth * controller.currentColumn.value,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        int newColumn =
                            (details.globalPosition.dx / blockWidth).floor();
                        controller.dragBlock(newColumn);
                      },
                      onHorizontalDragEnd: (_) => controller.releaseBlock(),
                      child: Container(
                        height: blockHeight,
                        width: blockWidth,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: controller.nextBlock.value != null
                            ? Image.asset(
                                controller.nextBlock.value!.hero,
                                fit: BoxFit.cover,
                                width: blockWidth,
                                height: blockHeight,
                                key: ValueKey(
                                    "next_${controller.nextBlock.value!.value}_${controller.nextBlock.value!.hero}"),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Next: ", style: textStyle),
                    controller.upcomingBlock.value !=
                            null // Hiển thị upcomingBlock thay vì nextBlock
                        ? Image.asset(
                            controller.upcomingBlock.value!.hero,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            key: ValueKey(
                                "preview_${controller.upcomingBlock.value!.value}_${controller.upcomingBlock.value!.hero}"),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
