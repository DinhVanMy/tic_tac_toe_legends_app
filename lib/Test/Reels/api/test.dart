import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Test/Reels/whitecodel/video_full_screen_widget.dart';
import 'package:tictactoe_gameapp/Test/Reels/whitecodel/whitecodel_reels_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';


/// Widget sử dụng StatefulWidget để khởi tạo controller chỉ một lần.
class WhiteCodelReelsPage extends StatefulWidget {
  final List<String>? videoList;
  final String? singleVideoUrl;
  final Widget? loader;
  final bool isCaching;
  final int startIndex;
  final Widget Function(
    BuildContext context,
    int index,
    Widget child,
    VideoPlayerController videoPlayerController,
    PageController pageController,
    StreamController<double> videoProgressController,
  )? builder;

  const WhiteCodelReelsPage({
    super.key,
    this.videoList,
    this.singleVideoUrl, // Thêm vào constructor
    this.loader,
    this.isCaching = false,
    this.builder,
    this.startIndex = 0,
  });

  @override
  State<WhiteCodelReelsPage> createState() => _WhiteCodelReelsState();
}

class _WhiteCodelReelsState extends State<WhiteCodelReelsPage> {
  late final WhiteCodelReelsController controller;
  bool _isMounted = true;
  final Map<int, StreamController<double>> _progressControllers = {};

  @override
  void initState() {
    super.initState();
    // Tạo tag duy nhất dựa trên singleVideoUrl hoặc videoList
    final tag = widget.singleVideoUrl != null
        ? 'whitecodel_reels_controller_${widget.singleVideoUrl.hashCode}'
        : 'whitecodel_reels_controller';
    // Xóa controller cũ nếu có
    Get.delete<WhiteCodelReelsController>(tag: tag, force: true);

    // Khởi tạo controller mới với tag duy nhất
    controller = Get.put(
      WhiteCodelReelsController(
        reelsVideoList: widget.videoList ??
            (widget.singleVideoUrl != null ? [widget.singleVideoUrl!] : []),
        isCaching: widget.isCaching,
        startIndex: widget.startIndex,
      ),
      tag: tag,
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _progressControllers.forEach((_, controller) => controller.close());
    //todo: Xóa controller khi widget bị dispose
    final tag = widget.singleVideoUrl != null
        ? 'whitecodel_reels_controller_${widget.singleVideoUrl.hashCode}'
        : 'whitecodel_reels_controller';
    Get.delete<WhiteCodelReelsController>(tag: tag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pageCount.value,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) async {
            // Khi chuyển trang, pause tất cả video ngoại trừ video hiện tại
            for (var i = 0;
                i < controller.videoPlayerControllerList.length;
                i++) {
              if (i != index &&
                  controller.videoPlayerControllerList[i].value.isInitialized) {
                await controller.videoPlayerControllerList[i].pause();
              }
            }
            if (controller
                .videoPlayerControllerList[index].value.isInitialized) {
              await controller.videoPlayerControllerList[index].play();
            }
          },
          itemBuilder: (context, index) {
            return _buildTile(index);
          },
        ),
      ),
    );
  }

  Widget _buildTile(int index) {
    return VisibilityDetector(
      key: Key('reel_tile_$index'),
      onVisibilityChanged: (visibilityInfo) async {
        if (!_isMounted) return;
        // Kiểm tra index hợp lệ trước khi truy cập danh sách
        if (index < 0 || index >= controller.videoPlayerControllerList.length) {
          return;
        }
        if (visibilityInfo.visibleFraction < 0.5) {
          // Kiểm tra controller đã initialize hay chưa trước khi gọi seekTo, pause
          if (controller.videoPlayerControllerList[index].value.isInitialized) {
            await controller.videoPlayerControllerList[index]
                .seekTo(Duration.zero);
            await controller.videoPlayerControllerList[index].pause();
          }
          controller.safeAnimationStop();
        } else {
          if (controller.videoPlayerControllerList[index].value.isInitialized) {
            await controller.videoPlayerControllerList[index].play();
          }
          controller.listenEvents(index);
          await controller.initNearByVideos(index);
          if (!controller.caching.contains(controller.videoList[index])) {
            await controller.cacheVideo(index);
          }
          controller.safeAnimationRepeat();
        }
      },
      child: GestureDetector(
        onTap: () async {
          if (index < 0 ||
              index >= controller.videoPlayerControllerList.length) {
            return;
          }
          final vpController = controller.videoPlayerControllerList[index];
          if (vpController.value.isInitialized) {
            if (vpController.value.isPlaying) {
              await vpController.pause();
              controller.visible.value = true;
              controller.safeAnimationStop();
            } else {
              await vpController.play();
              controller.visible.value = false;
              controller.safeAnimationRepeat();
            }
          }
        },
        child: Obx(() {
          // Kiểm tra index hợp lệ trước khi truy cập danh sách
          if (index < 0 ||
              index >= controller.videoPlayerControllerList.length) {
            return const Center(child: Text("Error: Invalid index"));
          }
          if (controller.loading.value ||
              !controller
                  .videoPlayerControllerList[index].value.isInitialized) {
            return widget.loader ??
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        GifsPath.loadingGif2,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
          }
          // Tạo StreamController cho video nếu chưa tồn tại
          if (!_progressControllers.containsKey(index)) {
            _progressControllers[index] = StreamController<double>.broadcast();
            controller.videoPlayerControllerList[index].addListener(() {
              if (controller
                      .videoPlayerControllerList[index].value.isInitialized &&
                  _isMounted) {
                double videoProgress = controller
                        .videoPlayerControllerList[index]
                        .value
                        .position
                        .inMilliseconds /
                    controller.videoPlayerControllerList[index].value.duration
                        .inMilliseconds;
                _progressControllers[index]!.add(videoProgress);
              }
            });
          }

          Widget videoWidget = VideoFullScreenWidget(
            videoPlayerController: controller.videoPlayerControllerList[index],
            controller: controller,
          );
          return widget.builder == null
              ? videoWidget
              : widget.builder!(
                  context,
                  index,
                  videoWidget,
                  controller.videoPlayerControllerList[index],
                  controller.pageController,
                  _progressControllers[index]!,
                );
        }),
      ),
    );
  }
}
