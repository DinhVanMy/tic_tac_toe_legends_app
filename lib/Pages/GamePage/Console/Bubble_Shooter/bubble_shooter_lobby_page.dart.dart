import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
// ignore: implementation_imports
import 'package:cyber_punk_tool_kit_ui/src/containers/cyber_container_two.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Console/Bubble_Shooter/bubble_shooter_gameplay_page.dart';

class BubbleShooterLobbyPage extends StatelessWidget {
  const BubbleShooterLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    Rxn<String> selectedLevel = Rxn<String>();
    RxnInt selectedMode = RxnInt();
    RxnString selectedImageIndex = RxnString();
    final List<String> imagePaths = [
      GifsPath.chloe1,
      GifsPath.chatbotGif,
      GifsPath.lightGif,
      GifsPath.cyberpunk,
      GifsPath.transitionGif,
    ];
    const TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontFamily: "Orbitron",
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );

    return Scaffold(
      // appBar: AppBar(title: const Text('Sudoku Lobby', style: textStyle)),
      body: Stack(
        children: [
          CyberContainerTwo(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CyberContainerOne(
                    horizontalPadding: 50,
                    bottomPadding: 40,
                    child: Obx(() => DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(selectedImageIndex.value ??
                                  GifsPath.cyberpunk),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Select Difficulty', style: textStyle),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["Easy","Medium","Hard","Expert"].map((level) {
                        return InkWell(
                          splashColor: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => selectedLevel.value = level,
                          child: Obx(() => Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                decoration: selectedLevel.value != null &&
                                        selectedLevel.value == level
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 5),
                                      )
                                    : BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                      ),
                                child: Text(
                                  level,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Orbitron",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              )),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Board Size', style: textStyle),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [4, 9, 16, 25].map((size) {
                        return InkWell(
                          splashColor: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => selectedMode.value = size,
                          child: Obx(() => Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                decoration: selectedMode.value != null &&
                                        selectedMode.value == size
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 5),
                                      )
                                    : BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                      ),
                                child: Text(
                                  '${size}x$size',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Orbitron",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              )),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select A Map', style: textStyle),
                  SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(imagePaths.length, (index) {
                          return GestureDetector(
                            onTap: () =>
                                selectedImageIndex.value = imagePaths[index],
                            child: Obx(() {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedImageIndex.value != null &&
                                            selectedImageIndex.value ==
                                                imagePaths[index]
                                        ? Colors.blue
                                        : Colors.white,
                                    width: 5,
                                  ),
                                ),
                                child: Image.asset(
                                  imagePaths[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() => selectedMode.value != null &&
                          selectedLevel.value != null &&
                          selectedImageIndex.value != null
                      ? InkWell(
                          onTap: () => Get.to(
                              () => BubbleShooterGame(
                                    level: selectedLevel.value!,
                                  ),
                              transition: Transition.zoom),
                          child: Ink(
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "PLAY",
                                style: textStyle,
                              ),
                            ),
                          ),
                        )
                      : Ink(
                          height: 50,
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 12, 5, 5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text("PLAY", style: textStyle),
                          ),
                        ))
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: CyberButton(
              onTap: () {},
              width: 100,
              height: 50,
              primaryColorBigContainer: Colors.redAccent,
              secondaryColorBigContainer: Colors.yellowAccent,
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Orbitron",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: CyberButton(
              onTap: () {
                Get.back();
              },
              width: 100,
              height: 50,
              primaryColorBigContainer: Colors.redAccent,
              secondaryColorBigContainer: Colors.yellowAccent,
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Orbitron",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
