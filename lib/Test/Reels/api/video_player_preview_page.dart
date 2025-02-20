import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPreviewController extends GetxController {
  late VideoPlayerController _controller;
  var isInitialized = false.obs;
  var isError = false.obs;
  var isPlaying = false.obs;

  void initializeVideo(String videoUrl) {
    if (videoUrl.isEmpty || !Uri.parse(videoUrl).isAbsolute) {
      isError.value = true;
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          isInitialized.value = true;
          update();
        }).catchError((error) {
          isError.value = true;
          errorMessage("Error initializing video: $error");
        });
    } catch (e) {
      isError.value = true;
      errorMessage("Exception caught: $e");
    }
  }

  VideoPlayerController get controller => _controller;

  void togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      isPlaying.value = false;
    } else {
      _controller.play();
      isPlaying.value = true;
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    super.onClose();
  }
}

class VideoPlayerPreviewPage extends StatelessWidget {
  final String videoUrl;
  VideoPlayerPreviewPage({super.key, required this.videoUrl});

  final VideoPlayerPreviewController videoController =
      Get.put(VideoPlayerPreviewController());

  @override
  Widget build(BuildContext context) {
    videoController.initializeVideo(videoUrl);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 30,
            )),
        title: const Text(
          "Preview Video",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.back(result: videoUrl);
              },
              icon: const Icon(
                Icons.done_outline_rounded,
                size: 30,
              ))
        ],
      ),
      body: Center(
        child: Obx(() {
          if (videoController.isError.value) {
            return const Text(
              "Error loading video. Please try another video.",
              style: TextStyle(color: Colors.red, fontSize: 16),
            );
          }
          if (!videoController.isInitialized.value) {
            return const CircularProgressIndicator();
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: videoController.controller.value.aspectRatio,
              child: VideoPlayer(videoController.controller),
            ),
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (videoController.isError.value ||
            !videoController.isInitialized.value) {
          return const SizedBox.shrink(); // Ẩn nút nếu có lỗi
        }
        return FloatingActionButton(
          onPressed: videoController.togglePlayPause,
          child: Icon(
              videoController.isPlaying.value ? Icons.pause : Icons.play_arrow),
        );
      }),
    );
  }
}
