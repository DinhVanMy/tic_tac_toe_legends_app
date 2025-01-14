import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/paint_draws/star_confetti_draws.dart';

class ConfettiOneforallWidget extends StatelessWidget {
  final ConfettiController confettiController;
  const ConfettiOneforallWidget({super.key, required this.confettiController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConfettiWidget(
        confettiController: confettiController,
        blastDirectionality:
            BlastDirectionality.explosive, // Nổ theo mọi hướng từ trung tâm
        shouldLoop: false, // Không lặp lại
        colors: const [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.teal,
          Colors.cyan,
          Colors.amber
        ],
        createParticlePath: (size) {
          // Tạo hạt với các hình dạng khác nhau
          return DrawPath.drawStarOfficial(size);
        },
        numberOfParticles: 100, // Số lượng hạt nổ ra
        emissionFrequency: 0.05, // Tần suất nổ
        gravity: 1, // Lực hấp dẫn, tốc độ rơi của các hạt
        minBlastForce: 10, // Lực nổ nhỏ nhất
        maxBlastForce: 100, // Lực nổ lớn nhất
        particleDrag: 0.05, // Lực cản khi các hạt rơi xuống
      ),
    );
  }
}
