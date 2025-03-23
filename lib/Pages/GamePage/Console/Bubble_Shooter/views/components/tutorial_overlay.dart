
// Tutorial overlay
import 'package:flutter/material.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onComplete;
  final int step;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    this.step = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Tutorial steps
    final steps = [
      {
        'title': 'Welcome to Bubble Shooter!',
        'content': 'Match 3 or more same-colored bubbles to clear them.',
        'position': const Offset(0.5, 0.5), // Center
      },
      {
        'title': 'Aiming',
        'content': 'Drag to aim and release to shoot',
        'position': const Offset(0.5, 0.9), // Bottom center
      },
      {
        'title': 'Clear Bubbles',
        'content': 'Clear all bubbles to win the level',
        'position': const Offset(0.5, 0.3), // Top center
      },
      {
        'title': 'Watch Out!',
        'content': 'New rows will appear periodically',
        'position': const Offset(0.5, 0.1), // Top
      },
    ];

    if (step >= steps.length) {
      return const SizedBox.shrink();
    }

    final currentStep = steps[step];
    final position = currentStep['position'] as Offset;

    return GestureDetector(
      onTap: () {
        onComplete();
      },
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Stack(
          children: [
            Positioned(
              left: position.dx * MediaQuery.of(context).size.width - 150,
              top: position.dy * MediaQuery.of(context).size.height - 100,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentStep['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentStep['content'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < steps.length; i++)
                          Container(
                            width: i == step ? 12 : 8,
                            height: i == step ? 12 : 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: i == step ? Colors.blue : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to continue',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
