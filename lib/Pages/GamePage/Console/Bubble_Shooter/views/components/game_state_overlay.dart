
// Widget hiển thị overlay trạng thái game (pause, win, lose)
import 'package:flutter/material.dart';

class GameStateOverlay extends StatelessWidget {
  final String message;
  final Color color;

  const GameStateOverlay({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Container(
          color: Colors.black.withOpacity(0.6 * value),
          child: Center(
            child: Transform.scale(
              scale: value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: "Orbitron",
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    if (message == 'PAUSED')
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Tap to continue',
                          style: TextStyle(
                            fontFamily: "Orbitron",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}