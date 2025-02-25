import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/optional_tile_custom.dart';
import 'package:tictactoe_gameapp/Test/Reels/api/fetch_url_link_api_page.dart';
import 'package:tictactoe_gameapp/Test/Reels/whitecodel/whitecodel_reels_page.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_controller.dart';
import 'package:video_player/video_player.dart';

import 'package:http/http.dart' as http;

class CreateReelPage extends StatelessWidget {
  final UserModel user;
  const CreateReelPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final ReelController reelController = Get.put(ReelController());
    final ThemeData theme = Theme.of(context);
    final TextEditingController videoUrlTextEditingController =
        TextEditingController();
    RxString videoUrl = "".obs;
    RxBool isVideoValid = false.obs;
    RxString description = "".obs;
    RxString imagePath = "".obs;
    XFile? image;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (videoUrl.value.isNotEmpty) {
              videoUrl.value = "";
            }
            Get.offNamed("mainHome");
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 40,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: false,
        title: Text(
          "Create a new reel",
          style: theme.textTheme.headlineMedium,
        ),
        actions: [
          Obx(
            () => isVideoValid.value && description.value.isNotEmpty
                ? InkWell(
                    onTap: () async {
                      await Get.showOverlay(
                        asyncFunction: () async {
                          await reelController.createReel(
                            videoUrl: videoUrl.value,
                            user: user,
                            description: description.value,
                            thumbnailUrl: image,
                          );
                        },
                        loadingWidget: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              GifsPath.loadingGif,
                              width: 200,
                              height: 200,
                            ),
                          ),
                        ),
                      ).then((_) {
                        Get.toNamed("mainHome");
                      });
                    },
                    child: Ink(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Reel",
                          style: theme.textTheme.bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 50,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Reel",
                      style: theme.textTheme.bodyLarge!
                          .copyWith(color: Colors.black45),
                    ),
                  ),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  AvatarUserWidget(radius: 35, imagePath: user.image!),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user.name!,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 100,
                child: TextField(
                  controller: videoUrlTextEditingController,
                  onChanged: (text) async {
                    if (text.isNotEmpty) {
                      videoUrl.value = text.trim();
                      await validateVideo(text, isVideoValid);
                    } else {
                      videoUrl.value = "";
                    }
                  },
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    labelText: 'Video Link ...',
                    alignLabelWithHint: true,
                    labelStyle: theme.textTheme.bodyLarge,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Obx(() => isVideoValid.value
                  ? SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: WhiteCodelReelsPage(
                          // context: context,
                          singleVideoUrl: videoUrl.value,
                          
                          isCaching: false,
                        ),
                      ),
                    )
                  : videoUrl.value.isNotEmpty
                      ? const Column(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 50),
                            Text("Video is not available or invalid!",
                                style: TextStyle(color: Colors.red)),
                          ],
                        )
                      : const SizedBox.shrink()),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 150,
                child: TextField(
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      description.value = text;
                    } else {
                      description.value = "";
                    }
                  },
                  minLines: null,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.left,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    fillColor: Colors.transparent,
                    labelText: 'Description...',
                    alignLabelWithHint: true,
                    labelStyle: theme.textTheme.bodyLarge,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Obx(() {
                if (imagePath.value.isNotEmpty) {
                  return Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          imagePath.value = "";
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.deepPurpleAccent,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 120,
                        child: Image.file(
                          File(
                            imagePath.value,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              }),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () async {
                      image = await reelController.pickImageGallery();
                      if (image != null) {
                        imagePath.value = image!.path;
                      } else {
                        imagePath.value = "";
                      }
                    },
                    title: "Gallery",
                    icon: Icons.image,
                    color: Colors.green,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () async {
                      image = await reelController.pickImageCamera();
                      if (image != null) {
                        imagePath.value = image!.path;
                      } else {
                        imagePath.value = "";
                      }
                    },
                    title: "Camera",
                    icon: Icons.camera_alt,
                    color: Colors.deepPurple,
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  OptionalTileWidget(
                    onTap: () async {
                      final result =
                          await Get.to(() => const VideoSelectionScreen());
                      if (result != null && result is String) {
                        videoUrl.value = result;
                        isVideoValid.value = true;
                        videoUrlTextEditingController.text = result;
                      }
                    },
                    title: "Check in",
                    icon: Icons.add_location_alt,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: double.maxFinite,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "POST",
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Kiểm tra URL có hợp lệ không
  bool isValidVideoUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }

    final List<String> validExtensions = [
      '.mp4',
      '.mkv',
      '.mov',
      '.avi',
      '.flv',
      '.wmv',
      '.webm'
    ];

    return validExtensions.any((ext) {
      final uriWithoutQuery = uri.path.toLowerCase(); // Loại bỏ query params
      return uriWithoutQuery.endsWith(ext);
    });
  }

  // ✅ Kiểm tra video có thể phát được không

  Future<void> validateVideo(String url, RxBool isVideoValid) async {
    if (!isValidVideoUrl(url)) {
      isVideoValid.value = false;
      return;
    }

    // 1️⃣ Kiểm tra HEAD request trước khi tải video
    try {
      final response =
          await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) {
        isVideoValid.value = false;
        return;
      }
    } catch (e) {
      isVideoValid.value = false;
      return;
    }

    // 2️⃣ Kiểm tra xem video có thể phát không
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller
          .initialize()
          .timeout(const Duration(seconds: 10)); // Timeout để tránh treo app

      if (controller.value.hasError) {
        isVideoValid.value = false;
      } else {
        isVideoValid.value = true;
      }
    } catch (e) {
      isVideoValid.value = false;
    } finally {
      controller?.dispose(); // Dọn dẹp tránh memory leak
    }
  }
}
