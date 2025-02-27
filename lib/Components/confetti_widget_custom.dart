import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/paint_draws/star_confetti_draws.dart';
import 'package:tictactoe_gameapp/Controller/Animations/confetti_controller.dart';

class ConfettiWidgetCustom extends StatelessWidget {
  final int quantity;
  const ConfettiWidgetCustom({super.key,  this.quantity = 100});

  @override
  Widget build(BuildContext context) {
    final ConfettiToController confettiToController =
        Get.put(ConfettiToController());
    return ConfettiWidget(
      confettiController: confettiToController.confettiController,
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
      numberOfParticles: quantity, // Số lượng hạt nổ ra
      emissionFrequency: 0.05, // Tần suất nổ
      gravity: 1, // Lực hấp dẫn, tốc độ rơi của các hạt
      minBlastForce: 10, // Lực nổ nhỏ nhất
      maxBlastForce: 100, // Lực nổ lớn nhất
      particleDrag: 0.05, // Lực cản khi các hạt rơi xuống
    );
  }
}


class ConfettiLikeWidgetCustom extends StatelessWidget {
  final int quantity;
  const ConfettiLikeWidgetCustom({super.key, this.quantity = 20}); // Giảm số lượng hạt xuống 20

  @override
  Widget build(BuildContext context) {
    final ConfettiToController confettiToController = Get.put(ConfettiToController());
    return ConfettiWidget(
      confettiController: confettiToController.confettiController,
      blastDirectionality: BlastDirectionality.explosive, // Nổ từ trung tâm ra mọi hướng
      shouldLoop: false, // Chỉ chạy một lần
      colors: const [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.pink,
      ],
      createParticlePath: (size) => DrawPath.drawStarOfficial(size), // Hạt hình ngôi sao
      numberOfParticles: quantity, // Số lượng hạt tối ưu
      emissionFrequency: 0.01, // Tần suất nổ thấp để tránh dày đặc
      gravity: 0.3, // Lực hấp dẫn nhẹ để hạt rơi chậm tự nhiên
      minBlastForce: 5, // Lực nổ nhỏ nhất
      maxBlastForce: 15, // Lực nổ lớn nhất, giảm để nhẹ nhàng hơn
      particleDrag: 0.1, // Lực cản lớn hơn để hạt rơi nhanh và biến mất sớm
    );
  }
}