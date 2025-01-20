// Bubble model
import 'dart:math';

import 'package:flutter/material.dart';
class Bubble {
  Offset position;
  double angle;
  final String heroAsset; // URL của hero
  static const double speed = 300.0;

  Bubble({required this.position, required this.angle, required this.heroAsset});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Bubble) return false;
    return position == other.position;
  }

  @override
  int get hashCode => position.hashCode;

  static Bubble random(List<String> listChamp) {
    final random = Random();
    return Bubble(
      position: const Offset(0.5, 0.9),
      angle: 0.0,
      heroAsset: listChamp[random.nextInt(listChamp.length)],
    );
  }

  void updatePosition(double dt) {
    position = Offset(
      position.dx + cos(angle) * speed * dt,
      position.dy - sin(angle) * speed * dt,
    );
    if (position.dx <= 0 || position.dx >= 1) {
      angle = pi - angle; // Phản xạ khi chạm tường
    }
  }
}


// Bubble grid model
class BubbleGrid {
  final List<List<Bubble?>> grid;

  BubbleGrid({int rows = 10, int columns = 10})
      : grid = List.generate(rows, (_) => List.filled(columns, null));

  // Khởi tạo lưới với các bóng ngẫu nhiên
  void initializeGrid(List<String> listChamp) {
  final random = Random();
  for (int i = 0; i < grid.length; i++) {
    for (int j = 0; j < grid[i].length; j++) {
      if (random.nextBool()) {
        grid[i][j] = Bubble(
          position: Offset(j.toDouble(), i.toDouble()),
          angle: 0,
          heroAsset: listChamp[random.nextInt(listChamp.length)],
        );
      }
    }
  }
}


// Tìm các bóng cùng màu liên kết với bóng đầu vào
  List<Bubble> findMatches(Bubble bubble) {
    final matches = <Bubble>[];
    final queue = <Bubble>[bubble];
    final visited = <Bubble>{};

    while (queue.isNotEmpty) {
      final current = queue.removeLast();

      if (visited.contains(current)) continue;
      visited.add(current);
      matches.add(current);

      for (final neighbor in _getNeighbors(current)) {
        if (neighbor != null &&
            neighbor.heroAsset == bubble.heroAsset &&
            !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    return matches;
  }

  // Tìm các bóng không kết nối với hàng trên cùng
  List<Bubble> findDetachedBubbles() {
    final visited = <Bubble>{};
    final connectedToTop = <Bubble>{};

    // BFS từ các bóng ở hàng trên cùng
    for (int col = 0; col < grid[0].length; col++) {
      final bubble = grid[0][col];
      if (bubble != null && !visited.contains(bubble)) {
        final queue = <Bubble>[bubble];

        while (queue.isNotEmpty) {
          final current = queue.removeLast();

          if (visited.contains(current)) continue;
          visited.add(current);
          connectedToTop.add(current);

          for (final neighbor in _getNeighbors(current)) {
            if (neighbor != null && !visited.contains(neighbor)) {
              queue.add(neighbor);
            }
          }
        }
      }
    }

    // Tìm các bóng không kết nối
    final allBubbles = getAllBubbles();
    return allBubbles
        .where((bubble) => !connectedToTop.contains(bubble))
        .toList();
  }

  // Lấy danh sách các bóng lân cận của một bóng
  List<Bubble?> _getNeighbors(Bubble bubble) {
    final neighbors = <Bubble?>[];
    final x = bubble.position.dx.toInt();
    final y = bubble.position.dy.toInt();

    // Các hướng lân cận (6 hướng cho lưới tổ ong)
    final directions = [
      const Offset(-1, 0), const Offset(1, 0), // Trái, phải
      const Offset(0, -1), const Offset(0, 1), // Trên, dưới
      Offset(y % 2 == 0 ? -1 : 1, -1), // Trên chéo
      Offset(y % 2 == 0 ? -1 : 1, 1), // Dưới chéo
    ];

    for (final dir in directions) {
      final nx = x + dir.dx.toInt();
      final ny = y + dir.dy.toInt();

      if (ny >= 0 && ny < grid.length && nx >= 0 && nx < grid[ny].length) {
        neighbors.add(grid[ny][nx]);
      }
    }

    return neighbors;
  }

  // Hàm lấy tất cả bóng trong lưới
  List<Bubble> getAllBubbles() {
    final bubbles = <Bubble>[];
    for (final row in grid) {
      for (final bubble in row) {
        if (bubble != null) bubbles.add(bubble);
      }
    }
    return bubbles;
  }

  void addBubble(Bubble bubble) {
    final cell = getClosestCell(bubble.position);
    grid[cell.dy.toInt()][cell.dx.toInt()] = bubble;
  }

  dynamic checkCollision(Bubble bubble) {
    return getClosestCell(bubble.position);
  }

  Offset getClosestCell(Offset position) {
    final x = (position.dx * grid[0].length).toInt();
    final y = (position.dy * grid.length).toInt();
    return Offset(x.toDouble(), y.toDouble());
  }

  void removeBubbles(List<Bubble> bubblesToRemove) {
    for (final bubble in bubblesToRemove) {
      grid[bubble.position.dy.toInt()][bubble.position.dx.toInt()] = null;
    }
  }
}
