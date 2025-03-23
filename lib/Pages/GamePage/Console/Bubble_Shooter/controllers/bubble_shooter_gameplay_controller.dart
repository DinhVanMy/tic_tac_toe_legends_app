import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/model/bubble_models.dart';

class BubbleShooterController extends GetxController {
  // Game variables
  late final List<String> selectedChamp; // Danh sách hero được chọn ngẫu nhiên
  var shooterPosition = const Offset(0.5, 0.9).obs; // Vị trí trụ bắn
  var bubbles = <Bubble>[].obs; // Bóng đang bay
  var activeBubble = Bubble.random(listChampions).obs; // Bóng sẵn sàng để bắn
  var nextBubble = Bubble.random(listChampions).obs; // Bóng tiếp theo
  var grid = Rx<BubbleGrid>(BubbleGrid());
  var score = 0.obs;
  var comboMessage = ''.obs;
  var gameOver = false.obs;
  var victory = false.obs;
  var isGamePaused = false.obs;
  var shootCount = 0.obs; // Số lần bắn
  var currentLevel = 1.obs;
  var shotBubble = Rx<Bubble?>(null); // Bóng đang được bắn

  // Hiệu ứng
  var showAnimation = false.obs;
  var animatingBubbles = <Bubble>[].obs;
  var bubbleAnimation = false.obs; // Trạng thái hiệu ứng bóng di chuyển
  var animationProgress = 0.0.obs; // Tiến trình animation (0.0 - 1.0)

  // Game settings
  final int newRowInterval; // Số lần bắn để thêm hàng mới
  final String level;
  var isBusy = false.obs; // Tránh bắn nhiều lần liên tiếp
  var lastTarget = Offset(0.5, 0.5).obs; // Lưu vị trí nhắm cuối cùng

  Timer? _gameLoopTimer;
  Timer? _bubbleFallTimer;
  Timer? _animationTimer;

  // Path drawing
  var targetPosition = const Offset(0.5, 0.5).obs; // Vị trí mục tiêu được chọn
  var pathPoints = <Offset>[].obs; // Các điểm trên đường bắn
  var isShowingPath = false.obs; // Có đang hiển thị đường bắn hay không
  var aimingAngle = (-pi / 2).obs; // Góc nhắm hiện tại (mặc định hướng lên)

  // Grid settings
  final double gridHeightFactor = 0.75; // Tỷ lệ chiều cao lưới so với màn hình

  BubbleShooterController({required this.level, this.newRowInterval = 5});

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
    _startGameLoop();
  }

  void _initializeGame() {
    selectedChamp = _getRandomChampions(_getNumberOfHeroesForLevel(level));

    // Thiết lập kích thước lưới dựa trên cấp độ
    int rows, columns;
    switch (level) {
      case 'Medium':
        rows = 12;
        columns = 9;
        break;
      case 'Hard':
        rows = 15;
        columns = 10;
        break;
      case 'Expert':
        rows = 18;
        columns = 11;
        break;
      default:
        rows = 10;
        columns = 8;
    }

    grid.value = BubbleGrid(rows: rows, columns: columns);
    grid.value.initializeGrid(selectedChamp);
    bubbles.clear(); // Đảm bảo danh sách bóng trống trước khi thêm mới
    bubbles.value = grid.value.getAllBubbles();

    activeBubble.value = Bubble.random(selectedChamp);
    nextBubble.value = Bubble.random(selectedChamp);

    gameOver.value = false;
    victory.value = false;
    score.value = 0;
    shootCount.value = 0;
    currentLevel.value = 1;
    shotBubble.value = null;
    isShowingPath.value = false;

    // Reset animation
    bubbleAnimation.value = false;
    animationProgress.value = 0.0;
  }

  void _startGameLoop() {
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGamePaused.value) {
        updateBubbles(0.016);
        _checkGameState();
      }
    });
  }

  int _getNumberOfHeroesForLevel(String level) {
    switch (level) {
      case 'Medium':
        return 5; // Số hero cho level Medium
      case 'Hard':
        return 7; // Số hero cho level Hard
      case 'Expert':
        return 9; // Số hero cho level Expert
      default:
        return 4; // Số hero cho level Easy
    }
  }

  List<String> _getRandomChampions(int numOfHeroes) {
    final random = Random();
    final shuffled = List.of(listChampions)..shuffle(random);
    return shuffled.take(numOfHeroes).toList();
  }

  // Cải tiến tính toán đường đi với phản hồi mượt mà hơn
  void calculateShootingPath(Offset target) {
    if (isBusy.value || bubbleAnimation.value) return;

    isShowingPath.value = true;
    lastTarget.value = target; // Lưu lại vị trí nhắm cuối cùng

    // Chỉ lấy hướng, không quan tâm đến độ dài của vector
    final dx = target.dx - shooterPosition.value.dx;
    final dy = target.dy - shooterPosition.value.dy;

    // Giới hạn góc bắn (không cho bắn xuống dưới)
    // Nếu điểm đích ở dưới shooter, điều chỉnh lại
    if (dy > 0) {
      if (dx > 0) {
        // Bắn sang phải ngang level
        target = Offset(1.0, shooterPosition.value.dy);
      } else if (dx < 0) {
        // Bắn sang trái ngang level
        target = Offset(0.0, shooterPosition.value.dy);
      } else {
        // Nếu ở chính giữa, bắn thẳng lên
        target = Offset(shooterPosition.value.dx, 0.0);
      }
    }

    // Tính toán lại góc dựa trên vị trí đã điều chỉnh
    final adjustedDx = target.dx - shooterPosition.value.dx;
    final adjustedDy = target.dy - shooterPosition.value.dy;

    if (adjustedDx != 0 || adjustedDy != 0) {
      final newAngle = atan2(-adjustedDy, adjustedDx);
      aimingAngle.value = newAngle;
      targetPosition.value = target;

      // Cập nhật góc cho active bubble
      activeBubble.update((bubble) {
        if (bubble != null) {
          bubble.angle = newAngle;
        }
      });

      // Tính toán đường đi
      _calculatePathPoints();
    }
  }

  void _calculatePathPoints() {
    final points = <Offset>[];
    final shooterPos = shooterPosition.value;
    points.add(shooterPos);

    var currentPos = shooterPos;
    var angle = aimingAngle.value;
    final step = 0.01; // Bước nhỏ hơn để đường đi mịn hơn

    // Giả lập đường đi của bóng với tối đa 200 điểm (để tránh quá tải)
    for (int i = 0; i < 200; i++) {
      final dx = cos(angle) * step;
      final dy = sin(angle) * step;

      final newX = currentPos.dx + dx;
      final newY = currentPos.dy + dy;

      // Kiểm tra va chạm với biên trái/phải
      if (newX <= 0.02 || newX >= 0.98) {
        // Đổi hướng ngang khi va chạm
        angle = pi - angle;
        currentPos = Offset(
          currentPos.dx + cos(angle) * step,
          currentPos.dy + sin(angle) * step,
        );
      } else {
        currentPos = Offset(newX, newY);
      }

      points.add(currentPos);

      // Kiểm tra và dừng nếu đến đỉnh màn hình
      if (currentPos.dy <= 0.05) break;

      // Kiểm tra va chạm với bóng hiện có
      final collideWithBubble = _checkPathCollision(currentPos);
      if (collideWithBubble) {
        break;
      }
    }

    pathPoints.assignAll(points);
    update(); // Cập nhật giao diện
  }

  bool _checkPathCollision(Offset position) {
    // Giả lập kiểm tra va chạm đơn giản với các bóng trong lưới
    final bubbleRadius = grid.value.bubbleRadius;

    for (int row = 0; row < grid.value.rows; row++) {
      for (int col = 0; col < grid.value.columns; col++) {
        if (grid.value.grid[row][col] != null) {
          // Tính toán vị trí tương đối của bóng trong lưới
          final isEvenRow = row % 2 == 0;
          final offsetX = isEvenRow ? 0.0 : bubbleRadius;

          final bubbleCenter = Offset(
            offsetX + col * (bubbleRadius * 2) + bubbleRadius,
            row * (bubbleRadius * 2) + bubbleRadius,
          );

          final distance = (bubbleCenter - position).distance;
          if (distance < (bubbleRadius * 1.5)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // Phương thức bắn bóng cải tiến
  void shootBubble() {
    if (isBusy.value ||
        gameOver.value ||
        victory.value ||
        bubbleAnimation.value) return;

    isShowingPath.value = false;
    isBusy.value = true;
    bubbleAnimation.value = true;
    animationProgress.value = 0.0;

    // Bắt đầu animation bắn
    final bubble = Bubble(
      heroAsset: activeBubble.value.heroAsset,
      color: activeBubble.value.color,
      angle: aimingAngle.value,
      position: shooterPosition.value,
    );

    shotBubble.value = bubble;

    // Animation bắn bóng
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (animationProgress.value < 1.0) {
        animationProgress.value += 0.05; // Điều chỉnh tốc độ animation

        // Tính toán vị trí mới của bóng dựa trên đường đi
        final pathIndex =
            (animationProgress.value * (pathPoints.length - 1)).floor();
        if (pathIndex < pathPoints.length) {
          bubble.position = pathPoints[pathIndex];
          update();
        }
      } else {
        // Kết thúc animation và kiểm tra va chạm
        timer.cancel();
        _animationTimer = null;
        bubbleAnimation.value = false;

        // Xử lý va chạm và đặt bóng vào lưới
        final collisionCell = grid.value.checkCollision(bubble);
        if (collisionCell != null) {
          grid.update((g) {
            if (g != null) {
              g.grid[collisionCell.row][collisionCell.col] = bubble;
              bubble.row = collisionCell.row;
              bubble.col = collisionCell.col;
              bubble.gridPosition = collisionCell;
            }
          });

          checkForMatches(bubble);
        }

        // Chuẩn bị bóng mới
        activeBubble.value = nextBubble.value;
        nextBubble.value = Bubble.random(selectedChamp);

        // Tăng số lần bắn
        shootCount.value++;
        if (shootCount.value % newRowInterval == 0) {
          _scheduledAddNewRow();
        }

        shotBubble.value = null;
        isBusy.value = false;

        // Hiển thị lại đường dẫn cho bóng kế tiếp
        calculateShootingPath(lastTarget.value);
      }
    });
  }

  void _scheduledAddNewRow() {
    // Thêm độ trễ trước khi thêm hàng mới
    Future.delayed(const Duration(seconds: 1), () {
      if (!gameOver.value && !victory.value) {
        grid.update((g) {
          g?.addNewRow(selectedChamp);
        });

        // Cập nhật lại danh sách bóng hiển thị
        bubbles.clear();
        bubbles.assignAll(grid.value.getAllBubbles());

        // Hiệu ứng khi thêm hàng mới
        Get.snackbar(
          'Cảnh báo!',
          'Một hàng bong bóng mới đã xuất hiện!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    });
  }

  // Cập nhật vị trí bóng trong game loop
  void updateBubbles(double dt) {
    // Chỉ cập nhật vị trí nếu không đang trong animation tự động
    if (shotBubble.value != null && !bubbleAnimation.value) {
      final bubble = shotBubble.value!;
      bubble.updatePosition(dt);

      final collisionCell = grid.value.checkCollision(bubble);
      if (collisionCell != null) {
        grid.update((g) {
          if (g != null) {
            g.grid[collisionCell.row][collisionCell.col] = bubble;
            bubble.row = collisionCell.row;
            bubble.col = collisionCell.col;
            bubble.gridPosition = collisionCell;
          }
        });

        shotBubble.value = null;
        checkForMatches(bubble);
        isBusy.value = false;
      }

      // Xóa bóng nếu nó ra khỏi màn hình trên cùng
      if (bubble.position.dy <= 0.02) {
        shotBubble.value = null;
        isBusy.value = false;
      }
    }

    update();
  }

  // Cải tiến kiểm tra và xử lý bóng cùng màu
  void checkForMatches(Bubble bubble) {
    final matches = grid.value.findMatches(bubble);

    if (matches.isNotEmpty) {
      // Hiệu ứng trước khi xóa
      animatingBubbles.assignAll(matches);
      showAnimation.value = true;

      // Thêm điểm
      final matchPoints = matches.length * 10;
      score.value += matchPoints;

      // Hiển thị combo message
      comboMessage.value = _getComboMessage(matches.length);
      Future.delayed(const Duration(seconds: 2), () {
        if (comboMessage.value == _getComboMessage(matches.length)) {
          comboMessage.value = '';
        }
      });

      // Xóa bóng sau hiệu ứng
      Future.delayed(const Duration(milliseconds: 600), () {
        showAnimation.value = false;

        grid.update((g) => g?.removeBubbles(matches));

        // Kiểm tra và xóa bóng không kết nối
        final detachedBubbles = grid.value.findDetachedBubbles();
        if (detachedBubbles.isNotEmpty) {
          // Thêm điểm cho bóng rơi
          score.value += detachedBubbles.length * 20;

          // Hiển thị hiệu ứng rơi cho detached bubbles
          animatingBubbles.assignAll(detachedBubbles);
          showAnimation.value = true;

          Future.delayed(const Duration(milliseconds: 600), () {
            showAnimation.value = false;
            grid.update((g) => g?.removeBubbles(detachedBubbles));

            // Cập nhật lại danh sách bóng
            bubbles.clear();
            bubbles.assignAll(grid.value.getAllBubbles());
          });
        } else {
          // Cập nhật danh sách bóng
          bubbles.clear();
          bubbles.assignAll(grid.value.getAllBubbles());
        }
      });
    } else {
      // Cập nhật danh sách bóng nếu không có match
      bubbles.clear();
      bubbles.assignAll(grid.value.getAllBubbles());
    }
  }

  String _getComboMessage(int length) {
    if (length >= 3 && length < 5) return 'Nice!';
    if (length >= 5 && length < 8) return 'Great!';
    if (length >= 8 && length < 12) return 'Awesome!';
    if (length >= 12) return 'Incredible!';
    return '';
  }

  void _checkGameState() {
    // Kiểm tra thắng
    if (grid.value.isVictory()) {
      victory.value = true;
      currentLevel.value++;
      _showGameEndMessage(true);
    }

    // Kiểm tra thua
    if (grid.value.isGameOver()) {
      gameOver.value = true;
      _showGameEndMessage(false);
    }
  }

  void _showGameEndMessage(bool isVictory) {
    if (isVictory) {
      Get.defaultDialog(
          title: 'Victory!',
          middleText: 'You cleared all bubbles! Score: ${score.value}',
          textConfirm: 'Next Level',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            loadNextLevel();
          });
    } else {
      Get.defaultDialog(
          title: 'Game Over',
          middleText: 'The bubbles reached the bottom! Score: ${score.value}',
          textConfirm: 'Restart',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            resetGame();
          });
    }
  }

  void pauseGame() {
    isGamePaused.value = true;
  }

  void resumeGame() {
    isGamePaused.value = false;
  }

  void resetGame() {
    // Hủy timers nếu đang chạy
    _animationTimer?.cancel();
    _animationTimer = null;

    _initializeGame();
    isGamePaused.value = false;
  }

  void loadNextLevel() {
    // Hủy timers nếu đang chạy
    _animationTimer?.cancel();
    _animationTimer = null;

    // Increase difficulty
    grid.value =
        BubbleGrid(rows: grid.value.rows + 1, columns: grid.value.columns);
    grid.value.initializeGrid(selectedChamp);

    // Reset game state but keep score
    gameOver.value = false;
    victory.value = false;
    isGamePaused.value = false;
    shootCount.value = 0;
    shotBubble.value = null;
    isShowingPath.value = false;
    bubbleAnimation.value = false;
    animationProgress.value = 0.0;

    // Get new bubbles
    activeBubble.value = Bubble.random(selectedChamp);
    nextBubble.value = Bubble.random(selectedChamp);

    // Update bubble list
    bubbles.clear();
    bubbles.assignAll(grid.value.getAllBubbles());
  }

  @override
  void onClose() {
    _gameLoopTimer?.cancel();
    _bubbleFallTimer?.cancel();
    _animationTimer?.cancel();
    super.onClose();
  }
}
