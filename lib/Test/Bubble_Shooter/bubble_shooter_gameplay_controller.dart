// Main game controller
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Test/Bubble_Shooter/bubble_models.dart';

class BubbleShooterController extends GetxController {
  late final List<String> selectedChamp; // Danh sách hero được chọn ngẫu nhiên
  var shooterPosition = const Offset(0.5, 1.0).obs;
  var bubbles = <Bubble>[].obs;
  var activeBubble = Bubble.random(listChampions).obs; // Bóng sẵn sàng để bắn
  var grid = Rx<BubbleGrid>(BubbleGrid());
  var score = 0.obs;
  var comboMessage = ''.obs;

  late Timer _bubbleFallTimer;

  final String level;

  BubbleShooterController({required this.level});

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  void _initializeGame() {
    final numOfHeroes = _getNumberOfHeroesForLevel(level);
    selectedChamp = _getRandomChampions(numOfHeroes);

    int rows, columns;
    switch (level) {
      case 'Medium':
        rows = 12;
        columns = 12;
        break;
      case 'Hard':
        rows = 15;
        columns = 15;
        break;
      case 'Expert':
        rows = 18;
        columns = 18;
        break;
      default:
        rows = 10;
        columns = 10;
    }

    grid.value = BubbleGrid(rows: rows, columns: columns);
    grid.value.initializeGrid(selectedChamp);
    bubbles.assignAll(grid.value.getAllBubbles());

    activeBubble.value = Bubble.random(selectedChamp);

    _bubbleFallTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      grid.update((g) {
        g?.grid.insert(0, List.filled(g.grid[0].length, null));
        g?.grid.removeLast();
      });
      bubbles.assignAll(grid.value.getAllBubbles());
    });
  }

  int _getNumberOfHeroesForLevel(String level) {
    switch (level) {
      case 'Medium':
        return 5; // Số hero cho level Medium
      case 'Hard':
        return 8; // Số hero cho level Hard
      case 'Expert':
        return 10; // Số hero cho level Expert
      default:
        return 3; // Số hero cho level Easy
    }
  }

  List<String> _getRandomChampions(int numOfHeroes) {
    final random = Random();
    final shuffled = List.of(listChampions)..shuffle(random);
    return shuffled.take(numOfHeroes).toList();
  }

  var targetPosition = const Offset(0.5, 0.5).obs; // Vị trí mục tiêu được chọn

  void aimAt(Offset target) {
    targetPosition.value = target;

    final dx = target.dx - shooterPosition.value.dx;
    final dy = shooterPosition.value.dy - target.dy;
    final angle = atan2(dy, dx);

    activeBubble.update((bubble) {
      if (bubble != null) {
        bubble.angle = angle;
      }
    });

    update(); // Cập nhật giao diện đường bay
  }

  void shootBubble() {
    final bubble = activeBubble.value;

    // Đặt vị trí khởi đầu
    bubble.position =
        Offset(shooterPosition.value.dx, shooterPosition.value.dy);
    bubbles.add(bubble);

    final dx = targetPosition.value.dx - shooterPosition.value.dx;
    final dy = shooterPosition.value.dy - targetPosition.value.dy;
    final angle = atan2(dy, dx);

    bubble.angle = angle;

    // Cập nhật vị trí bóng và kiểm tra va chạm
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      bubble.updatePosition(0.016);

      final collisionCell = grid.value.checkCollision(bubble);
      if (collisionCell != null) {
        grid.update((g) {
          g?.addBubble(bubble);
        });
        bubbles.remove(bubble);
        checkForMatches(bubble);

        timer.cancel();
      }

      if (bubble.position.dy <= 0) {
        bubbles.remove(bubble);
        timer.cancel();
      }

      update();
    });

    // Tạo bóng mới cho lần bắn tiếp theo
    activeBubble.value = Bubble.random(selectedChamp);
  }

  void updateBubbles(double dt) {
    final toRemove = <Bubble>[];

    for (final bubble in bubbles) {
      bubble.updatePosition(dt);

      final collisionCell = grid.value.checkCollision(bubble);
      if (collisionCell != null) {
        grid.update((g) {
          g?.addBubble(bubble);
        });
        toRemove.add(bubble);
        checkForMatches(bubble);
      }

      // Xóa bóng nếu nó ra khỏi màn hình
      if (bubble.position.dy <= 0) {
        toRemove.add(bubble);
      }
    }

    bubbles.removeWhere((bubble) => toRemove.contains(bubble));

    // Cập nhật danh sách bóng trong giao diện
    bubbles.assignAll(grid.value.getAllBubbles());
  }

  void checkForMatches(Bubble bubble) {
    final matches = grid.value.findMatches(bubble);
    if (matches.isNotEmpty) {
      score.value += matches.length * 10;

      comboMessage.value = _getComboMessage(matches.length);
      Future.delayed(const Duration(seconds: 2), () {
        comboMessage.value = '';
      });

      grid.update((g) => g?.removeBubbles(matches));

      // Kiểm tra và xóa bóng không kết nối
      final detachedBubbles = grid.value.findDetachedBubbles();
      grid.update((g) => g?.removeBubbles(detachedBubbles));
    }
  }

  String _getComboMessage(int length) {
    if (length > 3 && length <= 5) return 'Great!';
    if (length > 5 && length <= 8) return 'Awesome!';
    if (length > 8) return 'Incredible!';
    return '';
  }

  @override
  void onClose() {
    _bubbleFallTimer.cancel();
    super.onClose();
  }
}
