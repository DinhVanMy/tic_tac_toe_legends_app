import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Minesweeper_Game/minesweeper_game_page.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Breakout_Game/breakout_gameplay_controller.dart';

class BreakoutGame extends StatelessWidget {
  final Level level;
  final String backgroundUrl;

  const BreakoutGame(
      {super.key, required this.level, required this.backgroundUrl});

  @override
  Widget build(BuildContext context) {
    final BallController ballController = Get.put(BallController());
    final PaddleController paddleController = Get.put(PaddleController());
    final BrickController brickController = Get.put(BrickController());
    final GameController gameController = Get.put(GameController(level: level));

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    const TextStyle textStyleBig = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('BreakOut Game Heroes', style: textStyleBig),
        actions: [
          IconButton(
              onPressed: gameController.resetGame,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 30,
              )),
          Obx(
            () => IconButton(
                onPressed: () => gameController.isPaused.toggle(),
                icon: !gameController.isPaused.value
                    ? const Icon(
                        Icons.pause_rounded,
                        size: 30,
                      )
                    : const Icon(
                        Icons.play_arrow_rounded,
                        size: 30,
                      )),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          paddleController.movePaddle(details.delta.dx, width);
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(() => Text(
                          "Lives: ${gameController.lives.value}",
                          style: textStyleBig.copyWith(color: Colors.white),
                        )),
                    Obx(() => Text(
                          "Score: ${gameController.score.value}",
                          style: textStyleBig.copyWith(color: Colors.white),
                        )),
                    Obx(() => Text(
                          "Level: ${gameController.currentLevel.value}",
                          style: textStyleBig.copyWith(color: Colors.white),
                        )),
                  ],
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Bóng
                      Obx(() => Positioned(
                            left: ballController.ballX.value * width,
                            top: ballController.ballY.value * height,
                            child: const Ball(),
                          )),

                      // Paddle
                      Obx(() => Positioned(
                            left: paddleController.paddleX.value * width,
                            bottom: 0,
                            child: Paddle(
                                width: paddleController.paddleWidth * width),
                          )),

                      // Gạch
                      Obx(() => Stack(
                            children: brickController.bricks
                                .where((brick) => !brick.isDestroyed.value)
                                .map((brick) => Positioned(
                                      left: brick.x * width,
                                      top: brick.y * height,
                                      child: BrickWidget(
                                        width: brick.width * width,
                                        height: brick.height * height,
                                        hero: brick.hero,
                                      ),
                                    ))
                                .toList(),
                          )),

                      // Điểm số và trạng thái game

                      // Thông báo thắng/thua
                      Obx(() => gameController.gameOver.value
                          ? Center(
                              child: Text(
                                gameController.gameWon.value
                                    ? "You Win!"
                                    : "Game Over!",
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Ball extends StatelessWidget {
  const Ball({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blue, Colors.lightBlue],
        ),
      ),
    );
  }
}

class Paddle extends StatelessWidget {
  final double width;

  const Paddle({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50),
          bottomLeft: Radius.circular(50),
        ),
      ),
    );
  }
}

class BrickWidget extends StatelessWidget {
  final double width;
  final double height;
  final String hero;

  const BrickWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.hero});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: HexagonClipper(),
        child: Image.asset(hero),
      ),
    );
  }

  
}
