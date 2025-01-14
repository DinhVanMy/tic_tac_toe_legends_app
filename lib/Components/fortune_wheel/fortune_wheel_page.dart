import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/fortune_wheel.dart';

class FortuneWheelMain extends StatefulWidget {
  const FortuneWheelMain({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FortuneWheelMainState createState() => _FortuneWheelMainState();
}

class _FortuneWheelMainState extends State<FortuneWheelMain> {
  FortuneWheelController<int> fortuneWheelController = FortuneWheelController();
  FortuneWheelChild? currentWheelChild;
  int currentBalance = 0;

  @override
  void initState() {
    super.initState();
    fortuneWheelController.addListener(() {
      if (fortuneWheelController.value == null) {
        return;
      }

      setState(() {
        currentWheelChild = fortuneWheelController.value;
      });

      if (fortuneWheelController.isAnimating) {
        return;
      }

      if (fortuneWheelController.shouldStartAnimation) {
        return;
      }

      setState(() {
        currentBalance += fortuneWheelController.value!.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: currentWheelChild != null
                    ? currentWheelChild!.foreground
                    : Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                child: FortuneWheel<int>(
                  controller: fortuneWheelController,
                  children: [
                    _createFortuneWheelChild(-50),
                    _createFortuneWheelChild(1000),
                    _createFortuneWheelChild(-50),
                    _createFortuneWheelChild(-500),
                    _createFortuneWheelChild(100),
                    _createFortuneWheelChild(-100),
                    _createFortuneWheelChild(200),
                    _createFortuneWheelChild(-100),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => fortuneWheelController.rotateTheWheel(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.black,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'SPIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 180,
          right: 50,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 40,
              color: Colors.yellowAccent,
            ),
          ),
        ),
        Positioned(
          top: 180,
          left: 50,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 40,
              color: Colors.yellowAccent,
            ),
          ),
        ),
      ],
    );
  }

  FortuneWheelChild<int> _createFortuneWheelChild(int value) {
    Color color = value.isNegative ? Colors.red : Colors.green;
    String verb = value.isNegative ? 'Lose' : 'Win';
    int valueString = value.abs();

    return FortuneWheelChild(
      foreground: _getWheelContentCircle(color, '$verb\n$valueString €'),
      value: value,
    );
  }

  Container _getWheelContentCircle(Color backgroundColor, String text) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
