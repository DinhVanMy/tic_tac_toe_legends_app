import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Test/Progress/mission_progress_controller.dart';
import 'package:tictactoe_gameapp/Test/Progress/mission_progress_indicator.dart';
import 'package:tictactoe_gameapp/Test/Progress/segmentd_indicator.dart';

class TestTestX2 extends StatelessWidget {
  const TestTestX2({super.key});

  @override
  Widget build(BuildContext context) {
    final ProgressController progressController =
        Get.put(ProgressController(10));
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLinearProgress(
              controller: progressController,
            ), // Gọi widget progress
            const SizedBox(height: 20),
            SegmentedProgressIndicator(
              controller: progressController,
            ),
            const SizedBox(height: 20),
            SegmentedCircularProgress(
              controller: progressController,
            ),
            const SizedBox(height: 20),
            HeartProgressIndicator(
              controller: progressController,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    progressController.incrementProgress(1); // Tăng 10 đơn vị
                  },
                  child: const Text('Tăng 10'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
