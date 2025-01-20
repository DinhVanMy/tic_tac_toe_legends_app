import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/General_Widgets/gaming_button_custom.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/sodoku_game/dynamic_sodoku_controller.dart';

class SudokuGamePlayPage extends StatelessWidget {
  final Levels selectedLevel;
  final int size;
  final String map;

  const SudokuGamePlayPage({
    super.key,
    required this.selectedLevel,
    required this.size,
    required this.map,
  });

  @override
  Widget build(BuildContext context) {
    // final SudokuController controller =
    //     Get.put(SudokuController(selectedLevel: selectedLevel));
    final SudokuGamePlayController controller = Get.put(
        SudokuGamePlayController(selectedLevel: selectedLevel, size: size));
    final width = MediaQuery.of(context).size.width;
    const TextStyle textStyleBig = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
    const TextStyle textStyleMedium = TextStyle(
      color: Colors.white,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w400,
      fontSize: 16,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Game Heroes', style: textStyleBig),
        actions: const [
          Icon(
            Icons.menu_rounded,
            size: 30,
          )
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.puzzle.isEmpty || controller.solution.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(map), fit: BoxFit.fitWidth)),
                  height: width,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    color: Colors.blueAccent,
                    strokeWidth: 5,
                    dashPattern: const [10, 5],
                    child: InteractiveViewer(
                      panEnabled: true, // Cho phép kéo thả
                      scaleEnabled: true, // Cho phép phóng to, thu nhỏ
                      minScale: 0.0000000000001, // Tỷ lệ thu nhỏ tối thiểu
                      maxScale: 4.0, // Tỷ lệ phóng to tối đa
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: size,
                          childAspectRatio: 1,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: size * size,
                        itemBuilder: (context, index) {
                          final value = controller.puzzle[index];
                          final isEditable = controller.puzzle[index] == -1;

                          // Hero được ánh xạ từ số
                          final hero = value == -1
                              ? null
                              : controller.selectedHeroes[value - 1];

                          return GestureDetector(
                            onTap: isEditable
                                ? () {
                                    if (controller.selectedHeroIndex.value !=
                                        -1) {
                                      controller.updateCell(
                                          index,
                                          controller.selectedHeroIndex.value +
                                              1);
                                      controller.selectedHeroIndex.value = -1;
                                    } else {
                                      Get.defaultDialog(
                                        title: "Tip",
                                        titleStyle: textStyleBig,
                                        content: const Text(
                                          "Do you want to tip this tile?",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: "Orbitron",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17),
                                        ),
                                        confirm: CyberButton(
                                          onTap: () =>
                                              controller.hintForSpecify(index),
                                          primaryColorBigContainer:
                                              Colors.green,
                                          secondaryColorBigContainer:
                                              Colors.blue,
                                          child: const Text(
                                            'Confirm',
                                            style: textStyleMedium,
                                          ),
                                        ),
                                        cancel: CyberButton(
                                          onTap: () {
                                            Get.back();
                                          },
                                          primaryColorBigContainer: Colors.red,
                                          secondaryColorBigContainer:
                                              Colors.redAccent,
                                          child: const Text(
                                            'Cancel',
                                            style: textStyleMedium,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: isEditable
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey.shade300,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.6)),
                              ),
                              alignment: Alignment.center,
                              child: hero == null
                                  ? const SizedBox.shrink()
                                  : Image.asset(
                                      hero,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          )
                              .animate()
                              .scale(duration: duration750)
                              .fadeIn(duration: duration750);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.selectedHeroes.length,
                      itemBuilder: (context, index) {
                        final hero = controller.selectedHeroes[index];
                        return GestureDetector(
                          onTap: () =>
                              controller.selectedHeroIndex.value = index,
                          child: Obx(() {
                            bool isSelected =
                                controller.selectedHeroIndex.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blueAccent
                                      : Colors.transparent,
                                  width: 5,
                                ),
                              ),
                              child: Image.asset(hero),
                            );
                          }),
                        );
                      }),
                )
              ],
            );
          }),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularGamingButton(
                          icon: Icons.undo_rounded,
                          onPressed: controller.undo,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        CircularGamingButton(
                          icon: Icons.tips_and_updates_rounded,
                          onPressed: controller.hintForRandom,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        CircularGamingButton(
                          icon: Icons.redo_rounded,
                          onPressed: controller.redo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CyberButton(
                        onTap: controller.generateNewGame,
                        width: 200,
                        height: 50,
                        primaryColorBigContainer: Colors.orange,
                        secondaryColorBigContainer: Colors.purple,
                        child: const Text(
                          'New Game',
                          style: textStyleMedium,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CyberButton(
                              onTap: controller.solveSudoku,
                              width: 200,
                              height: 50,
                              primaryColorBigContainer: Colors.greenAccent,
                              secondaryColorBigContainer: Colors.blueAccent,
                              child: const Text(
                                'Solve',
                                style: textStyleMedium,
                              ),
                            ),
                            CyberButton(
                              onTap: () {
                                controller.checkCompletion();
                                if (controller.isSolved.value) {
                                  Get.snackbar(
                                      'Success', 'You solved the Sudoku!');
                                } else {
                                  Get.snackbar('Incomplete',
                                      'The Sudoku is not solved yet.');
                                }
                              },
                              width: 200,
                              height: 50,
                              primaryColorBigContainer: Colors.redAccent,
                              secondaryColorBigContainer: Colors.yellowAccent,
                              child: const Text(
                                'Check',
                                style: textStyleMedium,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
