import 'dart:math';
import 'dart:ui';

class Bubble {
  late String heroAsset;
  late Offset position;
  late double angle;
  late double speed;
  late String color;
  int row = -1;
  int col = -1;

  // GridPosition for snapping calculations
  GridPosition? gridPosition;

  // Animation properties
  double scale = 1.0;
  double opacity = 1.0;
  bool isAnimating = false;
  AnimationType animationType = AnimationType.none;

  Bubble({
    required this.heroAsset,
    this.position = const Offset(0.5, 0.9),
    this.angle = -pi / 2, // Mặc định hướng lên trên
    this.speed = 0.5,
    required this.color,
    this.scale = 1.0,
    this.opacity = 1.0,
  });

  factory Bubble.random(List<String> availableChampions) {
    final random = Random();
    final champIndex = random.nextInt(availableChampions.length);
    final champion = availableChampions[champIndex];

    return Bubble(
      heroAsset: champion,
      color: champion,
    );
  }

  void updatePosition(double deltaTime) {
    final dx = cos(angle) * speed * deltaTime;
    final dy = sin(angle) * speed * deltaTime;

    // Kiểm tra va chạm với biên trái/phải
    final newX = position.dx + dx;
    if (newX <= 0.05 || newX >= 0.95) {
      // Đổi hướng ngang khi va chạm
      angle = pi - angle;
      position = Offset(
        position.dx + cos(angle) * speed * deltaTime,
        position.dy + sin(angle) * speed * deltaTime,
      );
    } else {
      position = Offset(position.dx + dx, position.dy + dy);
    }
  }

  // Phương thức copy với thuộc tính mới
  Bubble copyWith({
    String? heroAsset,
    Offset? position,
    double? angle,
    double? speed,
    String? color,
    int? row,
    int? col,
    GridPosition? gridPosition,
    double? scale,
    double? opacity,
    bool? isAnimating,
    AnimationType? animationType,
  }) {
    final bubble = Bubble(
      heroAsset: heroAsset ?? this.heroAsset,
      position: position ?? this.position,
      angle: angle ?? this.angle,
      speed: speed ?? this.speed,
      color: color ?? this.color,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
    );

    bubble.row = row ?? this.row;
    bubble.col = col ?? this.col;
    bubble.gridPosition = gridPosition ?? this.gridPosition;
    bubble.isAnimating = isAnimating ?? this.isAnimating;
    bubble.animationType = animationType ?? this.animationType;

    return bubble;
  }

  @override
  String toString() {
    return 'Bubble(color: $color, position: $position)';
  }
}

// Enum để theo dõi loại animation của bóng
enum AnimationType {
  none,
  shoot,
  match,
  detach,
  appear,
}

class GridPosition {
  int row;
  int col;

  GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition($row, $col)';
}

class BubbleGrid {
  late List<List<Bubble?>> grid;
  final int rows;
  final int columns;
  final double bubbleRadius = 0.05; // Bán kính tương đối của bóng

  BubbleGrid({this.rows = 10, this.columns = 10}) {
    grid = List.generate(rows, (_) => List.filled(columns, null));
  }

  void initializeGrid(List<String> availableChampions) {
    final random = Random();

    // Chỉ điền đầy 3 hàng đầu tiên
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < columns; col++) {
        final champIndex = random.nextInt(availableChampions.length);
        final champion = availableChampions[champIndex];

        final bubble = Bubble(
          heroAsset: champion,
          color: champion,
        );

        bubble.row = row;
        bubble.col = col;
        bubble.gridPosition = GridPosition(row, col);
        bubble.animationType = AnimationType.appear;

        grid[row][col] = bubble;
      }
    }
  }

  // Lấy tất cả bóng từ lưới
  List<Bubble> getAllBubbles() {
    final result = <Bubble>[];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (grid[row][col] != null) {
          result.add(grid[row][col]!);
        }
      }
    }
    return result;
  }

  GridPosition? checkCollision(Bubble bubble) {
    // Chuyển đổi vị trí tương đối thành vị trí lưới
    final row = (bubble.position.dy / (bubbleRadius * 2)).floor();
    final col = (bubble.position.dx / (bubbleRadius * 2)).floor();

    // Kiểm tra nếu bóng đã ở trên cùng (va chạm với đỉnh lưới)
    if (bubble.position.dy <= bubbleRadius) {
      final col = min(columns - 1,
          max(0, (bubble.position.dx / (bubbleRadius * 2)).floor()));
      return _findNearestEmptyCell(0, col);
    }

    // Kiểm tra các vị trí lân cận
    for (int r = max(0, row - 1); r <= min(rows - 1, row + 1); r++) {
      for (int c = max(0, col - 1); c <= min(columns - 1, col + 1); c++) {
        if (grid[r][c] != null) {
          // Tính khoảng cách giữa hai tâm bóng
          final isEvenRow = r % 2 == 0;
          final offsetX = isEvenRow ? 0.0 : bubbleRadius;

          final gridBubblePos = Offset(
            offsetX + c * (bubbleRadius * 2) + bubbleRadius,
            r * (bubbleRadius * 2) + bubbleRadius,
          );

          final distance = (gridBubblePos - bubble.position).distance;

          // Nếu khoảng cách nhỏ hơn 2 lần bán kính, có va chạm
          if (distance < (bubbleRadius * 1.8)) {
            // Tìm ô trống gần nhất để đặt bóng
            return _findNearestEmptyCell(r, c);
          }
        }
      }
    }

    return null;
  }

  GridPosition? _findNearestEmptyCell(int row, int col) {
    // Nếu ô hiện tại trống, dùng nó
    if (row >= 0 &&
        row < rows &&
        col >= 0 &&
        col < columns &&
        grid[row][col] == null) {
      return GridPosition(row, col);
    }

    // Kiểm tra các ô lân cận
    final directions = [
      [-1, 0], [1, 0], [0, -1], [0, 1], // Trên, dưới, trái, phải
      [-1, -1], [-1, 1], [1, -1], [1, 1], // Các góc
    ];

    for (final dir in directions) {
      final newRow = row + dir[0];
      final newCol = col + dir[1];

      if (newRow >= 0 &&
          newRow < rows &&
          newCol >= 0 &&
          newCol < columns &&
          grid[newRow][newCol] == null) {
        return GridPosition(newRow, newCol);
      }
    }

    return null;
  }

  void addBubble(Bubble bubble) {
    final collisionCell = checkCollision(bubble);
    if (collisionCell != null) {
      final row = collisionCell.row;
      final col = collisionCell.col;

      if (row >= 0 && row < rows && col >= 0 && col < columns) {
        bubble.row = row;
        bubble.col = col;
        bubble.gridPosition = GridPosition(row, col);
        grid[row][col] = bubble;
      }
    }
  }

  // Tìm các bóng cùng màu kết nối với nhau
  List<Bubble> findMatches(Bubble bubble) {
    if (bubble.gridPosition == null) return [];

    final row = bubble.gridPosition!.row;
    final col = bubble.gridPosition!.col;
    final color = bubble.color;

    final visited = <GridPosition>{};
    final matches = <Bubble>[];

    // Thuật toán DFS để tìm các bóng cùng màu
    _exploreMatches(row, col, color, visited, matches);

    // Trả về kết quả nếu có ít nhất 3 bóng
    return matches.length >= 3 ? matches : [];
  }

  void _exploreMatches(int row, int col, String color,
      Set<GridPosition> visited, List<Bubble> matches) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return;

    final pos = GridPosition(row, col);
    if (visited.contains(pos)) return;

    final bubble = grid[row][col];
    if (bubble == null || bubble.color != color) return;

    visited.add(pos);
    matches.add(bubble);

    // Kiểm tra 6 hướng trong lưới hexagonal
    final directions = isEvenRow(row)
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
      _exploreMatches(row + dir[0], col + dir[1], color, visited, matches);
    }
  }

  // Kiểm tra xem một hàng có phải là hàng chẵn không
  bool isEvenRow(int row) {
    return row % 2 == 0;
  }

  // Tìm các bóng không kết nối với đỉnh lưới
  List<Bubble> findDetachedBubbles() {
    final connectedToTop = <GridPosition>{};

    // Thêm tất cả các bóng ở hàng đầu tiên
    for (int col = 0; col < columns; col++) {
      if (grid[0][col] != null) {
        _exploreBubbleConnection(0, col, connectedToTop);
      }
    }

    // Tìm tất cả các bóng không kết nối
    final detachedBubbles = <Bubble>[];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (grid[row][col] != null) {
          final pos = GridPosition(row, col);
          if (!connectedToTop.contains(pos)) {
            final bubble = grid[row][col]!;
            bubble.animationType = AnimationType.detach;
            detachedBubbles.add(bubble);
          }
        }
      }
    }

    return detachedBubbles;
  }

  void _exploreBubbleConnection(int row, int col, Set<GridPosition> visited) {
    if (row < 0 || row >= rows || col < 0 || col >= columns) return;

    final pos = GridPosition(row, col);
    if (visited.contains(pos)) return;

    final bubble = grid[row][col];
    if (bubble == null) return;

    visited.add(pos);

    // Kiểm tra 6 hướng trong lưới hexagonal
    final directions = isEvenRow(row)
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
      _exploreBubbleConnection(row + dir[0], col + dir[1], visited);
    }
  }

  // Xóa các bóng được chỉ định khỏi lưới
  void removeBubbles(List<Bubble> bubblesToRemove) {
    for (final bubble in bubblesToRemove) {
      if (bubble.gridPosition != null) {
        final row = bubble.gridPosition!.row;
        final col = bubble.gridPosition!.col;

        if (row >= 0 && row < rows && col >= 0 && col < columns) {
          grid[row][col] = null;
        }
      }
    }
  }

  // Kiểm tra xem game đã kết thúc chưa
  bool isGameOver() {
    // Kiểm tra xem có bóng nào ở hàng cuối cùng hay không
    for (int col = 0; col < columns; col++) {
      if (grid[rows - 1][col] != null) {
        return true;
      }
    }
    return false;
  }

  // Kiểm tra xem người chơi đã thắng chưa
  bool isVictory() {
    // Kiểm tra xem còn bóng nào trên lưới hay không
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        if (grid[row][col] != null) {
          return false;
        }
      }
    }
    return true;
  }

  // Thêm một hàng bóng mới vào đầu lưới
  void addNewRow(List<String> availableChampions) {
    // Dịch chuyển tất cả các hàng xuống dưới
    for (int row = rows - 1; row > 0; row--) {
      grid[row] = List.from(grid[row - 1]);

      // Cập nhật vị trí hàng cho các bóng
      for (int col = 0; col < columns; col++) {
        if (grid[row][col] != null) {
          grid[row][col]!.row = row;
          grid[row][col]!.gridPosition = GridPosition(row, col);
        }
      }
    }

    // Thêm hàng mới vào đầu
    final random = Random();
    for (int col = 0; col < columns; col++) {
      final champIndex = random.nextInt(availableChampions.length);
      final champion = availableChampions[champIndex];

      final bubble = Bubble(
        heroAsset: champion,
        color: champion,
      );

      bubble.row = 0;
      bubble.col = col;
      bubble.gridPosition = GridPosition(0, col);
      bubble.animationType = AnimationType.appear;

      grid[0][col] = bubble;
    }
  }
}
