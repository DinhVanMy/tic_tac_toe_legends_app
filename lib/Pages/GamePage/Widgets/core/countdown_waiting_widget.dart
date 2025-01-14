import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/Animations/countdown_animation_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';

class CountdownWaitingWidget extends StatelessWidget {
  const CountdownWaitingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final CountdownController countdownController =
        Get.put(CountdownController());

    return Obx(() {
      double progress = countdownController.animationController.value;
      Color progressColor = countdownController.progressColor.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vòng tròn hiển thị trạng thái đếm ngược
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10, // Độ dày của đường viền
                valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor), // Màu của viền
                backgroundColor: Colors.grey.shade300, // Màu nền của viền
              ),
            ),
            // Text hiển thị thời gian còn lại
            Text(
              TimeFunctions.getFormattedTime(countdownController.timeLeft),
              style: TextStyle(
                fontSize: 30,
                color: countdownController.progressColor.value,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }
}
