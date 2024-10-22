import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/fortune_wheel/fortune_wheel_page.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/daily_gift_page.dart';

class ExpansionSideWidgetLeft extends StatelessWidget {
  const ExpansionSideWidgetLeft({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isExpanded = false.obs;
    return Obx(
      () => Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isExpanded.value ? 1.0 : 0.0, // Thay đổi độ mờ dần
              duration: const Duration(milliseconds: 500),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: isExpanded.value ? 80 : 0, // Mở rộng/thu gọn
                height: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50)),
                ),
                child: isExpanded.value
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.dialog(
                                    const Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: DailyRewardPage()),
                                    barrierDismissible: true,
                                  );
                                },
                                child: Image.asset(
                                  Jajas.banner,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Text(
                                "Daily",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Image.asset(
                                Jajas.event,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Event",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.dialog(
                                    const Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: FortuneWheelMain(),
                                    ),
                                    barrierDismissible: false,
                                  );
                                },
                                child: Image.asset(
                                  Jajas.spinner,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Text(
                                "Spinner",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Image.asset(
                                Jajas.worldNews,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Explore",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Image.asset(
                                Jajas.clans,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Clans",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Image.asset(
                                Jajas.mission,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              const Text(
                                "Pass",
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
            GestureDetector(
              onTap: () {
                isExpanded.value = !isExpanded.value;
              },
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(20, 100),
                    painter: TrapezoidPainterLeft(),
                  ),
                  Positioned(
                    left: isExpanded.value ? 0 : -3,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Icon(
                      !isExpanded.value
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrapezoidPainterLeft extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.redAccent;

    var path = Path();
    path.moveTo(0, 0); // Góc trên bên trái
    path.lineTo(size.width, 20); // Góc trên bên phải
    path.lineTo(size.width, size.height - 20); // Góc dưới bên phải
    path.lineTo(0, size.height); // Góc dưới bên trái
    path.close(); // Đóng path lại

    canvas.drawPath(path, paint); // Vẽ hình thang
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
