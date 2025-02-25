import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tictactoe_gameapp/Test/Reels/whitecodel/whitecodel_reels_controller.dart';
import 'package:video_player/video_player.dart';

/// VideoFullScreenPage nhận controller từ cha để tránh lỗi Get.find()
class VideoFullScreenWidget extends StatelessWidget {
  final VideoPlayerController videoPlayerController;
  final WhiteCodelReelsController controller;

  const VideoFullScreenWidget({
    super.key,
    required this.videoPlayerController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hiển thị video với FittedBox để cover toàn màn hình
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: MediaQuery.of(context).size.height *
                  videoPlayerController.value.aspectRatio,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayer(videoPlayerController),
            ),
          ),
        ),
        // Nút Play/Pause với AnimatedOpacity dựa trên observable visible
        Positioned.fill(
          child: Center(
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.visible.value ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: !videoPlayerController.value.isPlaying
                      ? const Icon(Icons.play_arrow,
                          color: Colors.white, size: 40)
                      : const Icon(Icons.pause, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
