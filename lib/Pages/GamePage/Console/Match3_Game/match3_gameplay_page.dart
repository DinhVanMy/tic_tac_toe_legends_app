import 'package:confetti/confetti.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/paint_draws/star_confetti_draws.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Match3_Game/match3_gameplay_controller.dart';

class Match3GamePlayPage extends StatelessWidget {
  final String selectedLevel;
  final int size;
  final String map;
  const Match3GamePlayPage(
      {super.key,
      required this.selectedLevel,
      required this.size,
      required this.map});

  @override
  Widget build(BuildContext context) {
    final Match3Controller controller = Get.put(
        Match3Controller(
          gridSize: size,
          difficultyLevel: selectedLevel,
          durationPlay: 1200,
        ),
        tag: "match3_gameplay_controller");
    final width = MediaQuery.of(context).size.width;
    const TextStyle textStyleBig = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
    const TextStyle textStyleMedium = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w400,
      fontSize: 16,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Heroes Game', style: textStyleBig),
        actions: [
          IconButton(
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Reset"),
                    content:
                        const Text("Are you sure you want to reset the game?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  controller.resetGame();
                }
              },
              icon: const Icon(
                Icons.watch_later_outlined,
                size: 30,
              )),
          IconButton(
              onPressed: () async {
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Reset"),
                    content:
                        const Text("Are you sure you want to refresh  heroes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  controller.refreshHeroes();
                }
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: controller.isAnimating.value
                          ? Colors.lightBlueAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Obx(
                    () => Text('Score: ${controller.score.value}',
                        style: textStyleMedium),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Obx(() {
                  double progress = controller.animationController.value;
                  Color progressColor = controller.progressColor.value;
                  return Padding(
                    padding: const EdgeInsets.all(7),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Vòng tròn hiển thị trạng thái đếm ngược
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10, // Độ dày của đường viền
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progressColor), // Màu của viền
                            backgroundColor:
                                Colors.grey.shade300, // Màu nền của viền
                          ),
                        ),
                        // Text hiển thị thời gian còn lại
                        Text(
                          TimeFunctions.getFormattedTime(controller.timeLeft),
                          style: textStyleBig,
                        ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: Container(
                      width: double.maxFinite,
                      height: 100,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 5)),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.activeHeroes.length,
                          itemBuilder: (context, index) {
                            String heroImage = controller.activeHeroes[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  heroImage,
                                  width: 50,
                                ),
                              ),
                            );
                          })).animate().scaleXY(
                      duration: const Duration(seconds: 1)),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(map), fit: BoxFit.fitWidth)),
              height: width,
              child: DottedBorder(
                borderType: BorderType.RRect,
                color: Colors.lightBlue,
                strokeWidth: 5,
                dashPattern: const [10, 5],
                child: InteractiveViewer(
                    panEnabled: false, // Cho phép kéo thả
                    scaleEnabled: true, // Cho phép phóng to, thu nhỏ
                    minScale: 0.0000000000001, // Tỷ lệ thu nhỏ tối thiểu
                    maxScale: 4.0, // Tỷ lệ phóng to tối đa
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: controller.gridSize,
                      ),
                      itemCount: controller.gridSize * controller.gridSize,
                      itemBuilder: (context, index) {
                        int x = index ~/ controller.gridSize;
                        int y = index % controller.gridSize;
                        return Obx(() {
                          int value = controller.grid[x][y].value;
                          String heroImage = controller.activeHeroes[value];
                          bool isDestroyed = controller.destroyedCells
                              .any((cell) => cell[0] == x && cell[1] == y);

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              DragTarget<Map<String, int>>(
                                onWillAcceptWithDetails: (details) {
                                  int x1 = details.data['x'] ?? -1;
                                  int y1 = details.data['y'] ?? -1;
                                  return (x1 == x && (y1 - y).abs() == 1) ||
                                      (y1 == y && (x1 - x).abs() == 1);
                                },
                                onAcceptWithDetails: (data) {
                                  controller.handleDrop(x, y);
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Draggable<Map<String, int>>(
                                    data: {'x': x, 'y': y},
                                    onDragStarted: () {
                                      controller.setSelectedItem(x, y);
                                    },
                                    feedback: Material(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(heroImage,
                                            width: 50, height: 50),
                                      ),
                                    ),
                                    childWhenDragging: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            width: 2.5,
                                          )),
                                    ),
                                    child:
                                        Obx(() => controller.timeLeft.value != 0
                                            ? Container(
                                                margin: const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      width: 2.5,
                                                    )),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    heroImage,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                margin: const EdgeInsets.all(1),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                                child: const SizedBox.expand(),
                                              )),
                                  );
                                },
                              ),
                              controller.isAnimating.value && isDestroyed
                                  ? Align(
                                      key: Key("$x-$y"),
                                      alignment: Alignment.center,
                                      child: ConfettiWidget(
                                        confettiController:
                                            controller.confettiController,
                                        blastDirectionality:
                                            BlastDirectionality.explosive,
                                        shouldLoop: false,
                                        colors: const [
                                          Colors.green,
                                          Colors.blue,
                                          Colors.pink,
                                          Colors.orange,
                                          Colors.purple
                                        ], // manually specify the colors to be used
                                        numberOfParticles: 10,
                                        createParticlePath: (size) {
                                          // Tạo hạt với các hình dạng khác nhau
                                          return DrawPath.drawStarOfficial(
                                              size);
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          );
                        })
                            .animate()
                            .scale(duration: duration750)
                            .fadeIn(duration: duration750);
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
