import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
class Card {
  final String name;
  final int attack;
  final int defense;
  final String effect;

  Card({
    required this.name,
    required this.attack,
    required this.defense,
    this.effect = '',
  });
}
class Player {
  String name;
  int health;
  List<Card> deck;

  Player({
    required this.name,
    this.health = 100,
    required this.deck,
  });

  void takeDamage(int damage) {
    health -= damage;
    if (health < 0) health = 0;
  }
}
class GameLogic {
  final Player player1;
  final Player player2;

  bool isPlayer1Turn = true;

  GameLogic(this.player1, this.player2);

  void playCard(Player currentPlayer, Player opponent, Card card) {
    int damage = card.attack - card.defense;
    if (damage > 0) {
      opponent.takeDamage(damage);
    }

    // Hiệu ứng đặc biệt (nếu có)
    if (card.effect == 'heal') {
      currentPlayer.health += 10; // Ví dụ: tăng 10 máu.
    }

    // Chuyển lượt
    isPlayer1Turn = !isPlayer1Turn;
  }
}


class CardGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Load các tài nguyên (sprite, âm thanh, vv).
  }

  @override
  void update(double dt) {
    // Cập nhật trạng thái game.
  }

  @override
  void render(Canvas canvas) {
    // Render giao diện game.
  }
}
class GamePage extends StatelessWidget {
  final CardGame game = CardGame();

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Game"),
      ),
      body: Stack(
        children: [
          GameWidget(game: game), // Game Flame.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Logic cho nút chơi thẻ bài.
                    },
                    child: const Text("Play Card"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Tạm dừng game.
                      game.pauseEngine();
                    },
                    child: const Text("Pause"),
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
class TestGameWidget extends StatelessWidget {
  const TestGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Media App"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GamePage()),
            );
          },
          child: const Text("Play Card Game"),
        ),
      ),
    );
  }
}

