import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/background_list_controller.dart';

class AgoraBackgroundSheet extends StatelessWidget {
  final ScrollController scrollController;
  final String imageAvatar;
  const AgoraBackgroundSheet(
      {super.key, required this.scrollController, required this.imageAvatar});

  @override
  Widget build(BuildContext context) {
    final InfiniteGradientGridController controller =
        Get.put(InfiniteGradientGridController(isGradient: false));
    RxString imagePath = "".obs;
    XFile? image;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 35,
                ),
              ),
              const Text(
                "Virtual Background",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final ProfileController profileController = Get.find();

                      image =
                          await profileController.pickFileX(ImageSource.camera);
                      if (image != null) {
                        imagePath.value = image!.path;
                      } else {
                        imagePath.value = "";
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ProfileController profileController = Get.find();

                      image = await profileController
                          .pickFileX(ImageSource.gallery);
                      if (image != null) {
                        imagePath.value = image!.path;
                      } else {
                        imagePath.value = "";
                      }
                    },
                    icon: const Icon(
                      Icons.image_rounded,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      imagePath.value = "";
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 30,
                    ),
                  ),
                ],
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
                  controller.loadMoreColors();
                }
                return true;
              },
              child: Obx(() => GridView.builder(
                    controller: scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: controller.colors.length +
                        (controller.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < controller.colors.length) {
                        final color = controller.colors[index];

                        return index == 0
                            ? Material(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.black,
                                  onTap: () async {},
                                  child: Ink(
                                    height: 200,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.black, width: 3)),
                                    child: Obx(() => imagePath.value.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Image.file(
                                              File(
                                                imagePath.value,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const SizedBox()),
                                  ),
                                ),
                              )
                            : Material(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: Colors.white,
                                  onTap: () async {},
                                  child: Column(
                                    children: [
                                      Ink(
                                        height: 200,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
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
