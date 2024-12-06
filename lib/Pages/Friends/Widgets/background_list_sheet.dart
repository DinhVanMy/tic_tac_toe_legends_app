import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';
import 'package:tictactoe_gameapp/Data/chat_friend_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/background_list_controller.dart';

class BackgroundListSheet extends StatelessWidget {
  final ChatFriendController chatFriendController;
  final ScrollController scrollController;
  const BackgroundListSheet(
      {super.key,
      required this.scrollController,
      required this.chatFriendController});

  @override
  Widget build(BuildContext context) {
    final InfiniteGradientGridController controller =
        Get.put(InfiniteGradientGridController());
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 35,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                "Theme",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!controller.isLoading.value &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent * 0.9) {
                  controller.loadMoreGradients();
                }
                return true;
              },
              child: Obx(() => GridView.builder(
                    controller: scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: controller.gradients.length +
                        (controller.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < controller.gradients.length) {
                        final colors = controller.gradients[index]["colors"]
                            as List<Color>;
                        final name =
                            controller.gradients[index]["name"] as String;
                        return index == 0
                            ? Material(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: colors.first,
                                  onTap: () async {
                                    await chatFriendController
                                        .setDefaultThemeForChatRoom();
                                  },
                                  child: Column(
                                    children: [
                                      Ink(
                                          height: 200,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  "Previewing...",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    width: 100,
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.greenAccent,
                                                    ),
                                                    child: const Text("Hello."),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    width: 100,
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    alignment:
                                                        Alignment.topRight,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.blueAccent,
                                                    ),
                                                    child: const Text(
                                                      "What's up?",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Default",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Material(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: colors.first,
                                  onTap: () async {
                                    await chatFriendController
                                        .setThemeForChatRoom(
                                      colors: colors
                                          .map((color) =>
                                              ColorStringReverseFunction
                                                  .colorToHex(color))
                                          .toList(),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Ink(
                                          height: 200,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: colors,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                const Text("Previewing..."),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    width: 100,
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.white,
                                                    ),
                                                    child: const Text("Hello."),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    width: 100,
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    alignment:
                                                        Alignment.topRight,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: colors.first,
                                                    ),
                                                    child: const Text(
                                                      "What's up?",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colors.first,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                      } else {
                        return const SizedBox();
                      }
                    },
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
