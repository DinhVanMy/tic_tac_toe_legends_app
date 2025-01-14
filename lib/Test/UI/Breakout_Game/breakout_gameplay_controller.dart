import 'dart:async';

import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Music/effective_music_controller.dart';

enum Level { easy, medium, hard, expert }

class BallController extends GetxController {
  RxDouble ballX = 0.0.obs;
  RxDouble ballY = 0.0.obs;
  RxDouble ballSpeedX = 0.01.obs;
  RxDouble ballSpeedY = 0.01.obs;
  RxDouble ballSpeedMultiplier = 1.1.obs; // Tăng tốc độ theo level

  void updatePosition() {
    ballX.value += ballSpeedX.value * ballSpeedMultiplier.value;
    ballY.value += ballSpeedY.value * ballSpeedMultiplier.value;

    // Va chạm với tường
    if (ballX.value <= 0 || ballX.value >= 1) {
      reverseXDirection();
    }
    if (ballY.value <= 0) {
      reverseYDirection();
    }
  }

  void reverseXDirection() {
    ballSpeedX.value = -ballSpeedX.value;
  }

  void reverseYDirection() {
    ballSpeedY.value = -ballSpeedY.value;
  }

  void adjustBallDirectionOnPaddle(double hitPosition, double paddleWidth) {
    double offsetFromCenter = (hitPosition - 0.5) * 2; // -1 đến 1
    ballSpeedX.value += offsetFromCenter * 0.02; // Tăng góc xiên
    ballSpeedY.value = -ballSpeedY.value; // Đảo hướng trục Y
  }

  void resetBallPosition(double initialSpeed) {
    ballX.value = 0.0; // Giữa màn hình
    ballY.value = 0.0; // Giữa màn hình
    ballSpeedX.value = initialSpeed; // Tốc độ ban đầu
    ballSpeedY.value = -initialSpeed; // Hướng bóng đi lên
    ballSpeedMultiplier.value = 1.0;
  }
}

class PaddleController extends GetxController {
  RxDouble paddleX = 0.5.obs;
  double paddleWidth = 0.25; // Điều chỉnh kích thước paddle theo level

  void movePaddle(double dx, double screenWidth) {
    paddleX.value += dx / screenWidth;
    if (paddleX.value < 0) paddleX.value = 0;
    if (paddleX.value > 1 - paddleWidth) paddleX.value = 1 - paddleWidth;
  }

  void resetPaddlePosition() {
    paddleX.value = 0.5;
  }
}

class BrickController extends GetxController {
  RxList<Brick> bricks = <Brick>[].obs;

  void createBricks(int rows, int columns) {
    bricks.clear();
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        bricks.add(Brick(
          x: j * 0.1,
          y: i * 0.05,
        ));
      }
    }
  }

  void setupLevel(int level) {
    int rows = 3 + level; // Tăng hàng theo level
    int columns = 5 + level; // Tăng cột theo level
    createBricks(rows, columns);
  }

  // Kiểm tra va chạm
  bool checkCollision(double ballX, double ballY) {
    for (var brick in bricks) {
      if (!brick.isDestroyed.value) {
        // Xác định tọa độ của viên gạch
        final brickLeft = brick.x;
        final brickRight = brick.x + brick.width;
        final brickTop = brick.y;
        final brickBottom = brick.y + brick.height;

        // Xác định va chạm với bóng
        if (ballX >= brickLeft &&
            ballX <= brickRight &&
            ballY >= brickTop &&
            ballY <= brickBottom) {
          brick.isDestroyed.value = true; // Đánh dấu gạch bị phá
          return true; // Có va chạm
        }
      }
    }
    return false; // Không có va chạm
  }
}

class GameController extends GetxController {
  RxInt score = 0.obs;
  RxBool gameOver = false.obs;
  RxBool gameWon = false.obs;
  RxInt currentLevel = 1.obs;
  RxBool isPaused = false.obs;
  RxInt lives = 3.obs;

  late BallController ballController;
  late PaddleController paddleController;
  late BrickController brickController;
  late EffectiveMusicController effectiveMusicController;

  final Level level;
  GameController({required this.level});

  @override
  void onInit() {
    super.onInit();
    ballController = Get.find();
    paddleController = Get.find();
    brickController = Get.find();
    effectiveMusicController = Get.put(EffectiveMusicController());
    startGame();
  }

  Future<void> startGame() async {
    gameOver.value = false; // Đặt lại trạng thái game over
    gameWon.value = false; // Đặt lại trạng thái thắng game

    ballController
        .resetBallPosition(0.01 * currentLevel.value); // Tăng tốc bóng
    paddleController.resetPaddlePosition(); // Đặt lại vị trí paddle
    _configureGame(level: level);

    Timer.periodic(const Duration(milliseconds: 16), (timer) async {
      if (gameOver.value || gameWon.value) {
        timer.cancel(); // Dừng timer nếu game over
        return;
      }
      if (isPaused.value || gameOver.value) {
        return;
      }
      await _updateGame(timer);
    });
  }

  Future<void> _updateGame(Timer timer) async {
    ballController.updatePosition();

    // Va chạm paddle
    if (ballController.ballY.value +
                ballController.ballSpeedY.value *
                    ballController.ballSpeedMultiplier.value >=
            0.95 &&
        ballController.ballX.value >= paddleController.paddleX.value &&
        ballController.ballX.value <=
            paddleController.paddleX.value + paddleController.paddleWidth) {
      double hitPosition =
          (ballController.ballX.value - paddleController.paddleX.value) /
              paddleController.paddleWidth;
      ballController.adjustBallDirectionOnPaddle(
          hitPosition, paddleController.paddleWidth);

      // Đặt lại vị trí bóng để tránh xuyên qua paddle
      ballController.ballY.value = 0.95;
      // play effective music
      await effectiveMusicController.playSoundPlayer2();
    }

    // Va chạm gạch
    if (brickController.checkCollision(
        ballController.ballX.value, ballController.ballY.value)) {
      ballController.reverseYDirection();
      await effectiveMusicController.playSoundPlayer1();
      score.value++;
      if (brickController.bricks.every((brick) => brick.isDestroyed.value)) {
        gameWon.value = true;
        currentLevel.value++;
        timer.cancel();
        startGame(); // Tăng level
      }
    }

    // Game over
    _onGameOver();
  }

  void _configureGame({
    required Level level,
  }) {
    switch (level) {
      case Level.easy:
        ballController.ballSpeedMultiplier.value = 1.0;
        paddleController.paddleWidth = 0.35; // Paddle lớn hơn
        brickController.setupLevel(1); // Ít gạch
        break;
      case Level.medium:
        ballController.ballSpeedMultiplier.value = 1.2;
        paddleController.paddleWidth = 0.25;
        brickController.setupLevel(2);
        break;
      case Level.hard:
        ballController.ballSpeedMultiplier.value = 1.5;
        paddleController.paddleWidth = 0.2;
        brickController.setupLevel(3);
        break;
      case Level.expert:
        ballController.ballSpeedMultiplier.value = 2.0;
        paddleController.paddleWidth = 0.15; // Paddle nhỏ nhất
        brickController.setupLevel(4); // Nhiều gạch nhất
        break;
    }
  }

  void _onGameOver() {
    if (ballController.ballY.value >= 1) {
      if (lives.value > 0) {
        lives.value--;
        // ballController.resetBallPosition(0.01 * currentLevel.value);
        startGame();
      } else {
        gameOver.value = true;
      }
    }
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
  }

  void resetGame() {
    score.value = 0;
    currentLevel.value = 1;
    startGame();
  }
}

class Brick {
  RxBool isDestroyed = false.obs;
  final double x, y;
  final double width, height;

  Brick(
      {required this.x, required this.y, this.width = 0.1, this.height = 0.05});
}
