import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';

class TictactoeHistoryWidget extends StatelessWidget {
  const TictactoeHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "BLUE TEAM",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: "Orbitron",
              ),
            ),
            Text(
              "RED TEAM",
              style: TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: "Orbitron",
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: listChamA.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                height: 100,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            listChamA[index],
                            width: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              TrimRanking.diamondTrim,
                              width: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              "You",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Orbitron",
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _showBoardHistory,
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                            child: const Icon(
                              Icons.tv_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Orbitron",
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            listChamA[index],
                            width: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Enemy",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Orbitron",
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              TrimRanking.diamondTrim,
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showBoardHistory() {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        height: 400,
        child: DottedBorder(
          borderType: BorderType.RRect,
          color: Colors.blueAccent,
          padding: const EdgeInsets.all(3),
          strokeWidth: 5,
          dashPattern: const [10, 5],
          radius: const Radius.circular(20),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                    image: AssetImage(ImagePath.background1),
                    fit: BoxFit.fill)),
            child: InteractiveViewer(
              panEnabled: true, // Cho phép kéo thả
              scaleEnabled: true, // Cho phép phóng to, thu nhỏ
              minScale: 0.0000000000001, // Tỷ lệ thu nhỏ tối thiểu
              maxScale: 4.0, // Tỷ lệ phóng to tối đa
              boundaryMargin: const EdgeInsets.all(
                  double.infinity), // Cho phép kéo ra ngoài biên
              child: SizedBox(
                width: 100, // Adjust width based on grid size
                height: 100, // Adjust height based on grid size
                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(0.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Image.asset(ChampionsPathA.aatrox)
                            .animate()
                            .fadeIn(
                                duration: const Duration(milliseconds: 750)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().scale(duration: const Duration(milliseconds: 750)));
  }
}
