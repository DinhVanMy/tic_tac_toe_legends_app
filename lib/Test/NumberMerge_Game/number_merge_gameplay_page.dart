import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/NumberMerge_Game/number_merge_controller.dart';

class NumberMergeGame extends StatelessWidget {
  const NumberMergeGame({super.key});

  @override
  Widget build(BuildContext context) {
    final NumberMergeController controller = Get.put(NumberMergeController());
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 30,
            color: Colors.blue,
          ),
        ),
        title: Column(
          children: [
            const Text("Number Merge", style: textStyle),
            Obx(() => Text("Score: ${controller.score.value}",
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "Orbitron",
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ))),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              splashColor: Colors.blueAccent,
              icon: const Icon(
                Icons.rotate_left_rounded,
                size: 30,
                color: Colors.white,
              ),
              onPressed: controller.undoMove,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Khối tiếp theo
              const SizedBox(
                height: 10,
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 400,
                    width: double.infinity,
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(controller.columns, (col) {
                        return GestureDetector(
                          onTap: () => controller.dropBlock(col),
                          child: Container(
                            width: MediaQuery.of(context).size.width /
                                    controller.columns -
                                15,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.grey[200],
                            ),
                            child: Obx(() {
                              return Stack(
                                children: List.generate(controller.rows, (row) {
                                  final block =
                                      controller.gameBoard.grid[row][col].value;
                                  return Positioned(
                                    top: row * 50.0,
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width /
                                              controller.columns -
                                          15,
                                      decoration: BoxDecoration(
                                          color: block != null
                                              ? Colors.blueAccent
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.black, width: 3)),
                                      child: Center(
                                        child: Text(
                                          block?.value.toString() ?? "",
                                          style: textStyle.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                  Obx(() {
                    return Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        width: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${controller.nextBlock.value?.value ?? ""}",
                            style: textStyle.copyWith(color: Colors.white),
                          ),
                        ),
                      ).animate(
                        // Reset animation mỗi khi nextBlock thay đổi
                        onPlay: (controllers) {
                          controllers.repeat(reverse: true);
                        },
                      ).slideY(
                        begin: -0.5,
                        end: 6,
                        duration: const Duration(seconds: 10),
                        curve: Curves.easeIn,
                      ),
                    );
                  })
                ],
              ),

              Obx(() => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Next: ${controller.nextBlock.value?.value ?? ""}",
                        style: textStyle),
                  )),
              // Lưới chơi
              SizedBox(
                height: 400,
                child: GridView.builder(
                  itemCount: controller.rows * controller.columns,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: controller.columns),
                  itemBuilder: (context, index) {
                    int row = index ~/ controller.columns;
                    int col = index % controller.columns;

                    return Obx(
                      () {
                        final block = controller.gameBoard.grid[row][col].value;
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: block != null
                                ? Colors.blueAccent
                                : Colors.grey[200],
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              block?.value.toString() ?? "",
                              style: textStyle.copyWith(color: Colors.white),
                            ),
                          ),
                        ).animate().slideY(
                            duration: const Duration(seconds: 10),
                            curve: Curves.easeOut);
                      },
                    );
                  },
                ),
              ),
              // Cột chọn thả khối
              Row(
                children: List.generate(controller.columns, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.isGameOver()) {
                          Get.snackbar("Game Over", "Start a new game!");
                          return;
                        }
                        controller.dropBlock(index);
                      },
                      child: Container(
                        height: 50,
                        color: Colors.blue.withOpacity(0.3),
                        child: const Center(child: Text("Drop")),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
