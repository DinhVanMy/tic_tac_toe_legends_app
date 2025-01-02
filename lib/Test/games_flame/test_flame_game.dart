import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TestFlameGame extends StatelessWidget {
  const TestFlameGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Game Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GamePage()),
            );
          },
          child: const Text('Start Game'),
        ),
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  final CardGame game = CardGame();

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Game'),
      ),
      body: Stack(
        children: [
          GameWidget(game: game),
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
                      game.playRandomCard();
                    },
                    child: const Text('Play Card'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      game.pauseEngine();
                    },
                    child: const Text('Pause'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      game.resumeEngine();
                    },
                    child: const Text('Resume'),
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

class CardGame extends FlameGame {
  late Player player;
  late Player opponent;
  late Random random;

  @override
  Future<void> onLoad() async {
    random = Random();

    // Initialize players
    player = Player(name: 'Player', health: 100, deck: _generateDeck());
    opponent = Player(name: 'Opponent', health: 100, deck: _generateDeck());

    // Thêm TextComponent hiển thị máu
    add(TextComponent(
      text: 'Player Health: ${player.health}',
      position: Vector2(10, size.y - 60),
      anchor: Anchor.topLeft,
    ));

    add(TextComponent(
      text: 'Opponent Health: ${opponent.health}',
      position: Vector2(10, size.y - 30),
      anchor: Anchor.topLeft,
    ));

    // Thêm CardComponent lên màn hình
    for (var i = 0; i < player.deck.length; i++) {
      add(player.deck[i]
        ..position = Vector2(50.0 + i * 60, size.y - 150)
        ..size = Vector2(50, 80));
    }
  }

  List<CardComponent> _generateDeck() {
    return List.generate(5, (index) {
      return CardComponent(
        card: Card(
          name: 'Card $index',
          attack: random.nextInt(20) + 10,
          defense: random.nextInt(10) + 5,
        ),
      );
    });
  }

  void playRandomCard() {
    if (player.deck.isEmpty || opponent.deck.isEmpty) return;

    final playerCard = player.deck.removeAt(0);
    final opponentCard = opponent.deck.removeAt(0);

    int damageToOpponent =
        max(0, playerCard.card.attack - opponentCard.card.defense);
    int damageToPlayer =
        max(0, opponentCard.card.attack - playerCard.card.defense);

    opponent.health -= damageToOpponent;
    player.health -= damageToPlayer;

    print(
        '${player.name} played ${playerCard.card.name} for $damageToOpponent damage!');
    print(
        '${opponent.name} played ${opponentCard.card.name} for $damageToPlayer damage!');

    if (player.health <= 0 || opponent.health <= 0) {
      print(player.health <= 0 ? 'Opponent Wins!' : 'Player Wins!');
      pauseEngine();
    }
  }
}

class Player {
  String name;
  int health;
  List<CardComponent> deck;

  Player({required this.name, required this.health, required this.deck});
}

class Card {
  final String name;
  final int attack;
  final int defense;

  Card({required this.name, required this.attack, required this.defense});
}

class CardComponent extends PositionComponent {
  final Card card;

  CardComponent({required this.card});

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(rect, paint);

    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '${card.name}\nAttack: ${card.attack}\nDefense: ${card.defense}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.x);
    textPainter.paint(canvas, const Offset(10, 10));
  }
}
