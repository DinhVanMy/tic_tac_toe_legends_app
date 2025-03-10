import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/whitecodel/video_full_screen_widget.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/whitecodel/whitecodel_reels_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class WhiteCodelReelsPage extends StatefulWidget {
  final List<ReelModel>? reels;
  final String? singleVideoUrl;
  final String? reelThumbnail;
  final bool isCaching;
  final int startIndex;
  final ReelController? reelController;
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
    this.singleVideoUrl,
    this.isCaching = false,
    this.builder,
    this.startIndex = 0,
    this.reelController,
    this.reelThumbnail,
    this.reels,
  });

  @override
  State<WhiteCodelReelsPage> createState() => _WhiteCodelReelsPageState();
}

class _WhiteCodelReelsPageState extends State<WhiteCodelReelsPage> {
  late final WhiteCodelReelsController controller;
  bool _isMounted = true;
  final Map<int, StreamController<double>> _progressControllers = {};
  final Map<int, Function()> _progressListeners = {};

  @override
  void initState() {
    super.initState();
    final tag = widget.singleVideoUrl != null
        ? 'whitecodel_reels_controller_${widget.singleVideoUrl.hashCode}'
        : 'whitecodel_reels_controller';

    Get.delete<WhiteCodelReelsController>(tag: tag, force: true);
    if (Get.isRegistered<WhiteCodelReelsController>(tag: tag)) {
      controller = Get.find<WhiteCodelReelsController>(tag: tag);
    } else {
      controller = Get.put(
        WhiteCodelReelsController(
          reelsVideoList: widget.reels?.map((e) => e.videoUrl!).toList() ??
              (widget.singleVideoUrl != null ? [widget.singleVideoUrl!] : []),
          isCaching: widget.isCaching,
          startIndex: widget.startIndex,
        ),
        tag: tag,
      );
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _progressListeners.forEach((index, listener) {
      if (index < controller.videoPlayerControllerList.length) {
        controller.videoPlayerControllerList[index].removeListener(listener);
      }
    });
    _progressControllers.forEach((_, controller) => controller.close());
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
      body: Obx(() {
        final itemCount = controller.isFetchingMore.value
            ? controller.videoPlayerControllerList.length + 1
            : controller.videoPlayerControllerList.length;
        return PageView.builder(
          controller: controller.pageController,
          itemCount: itemCount,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) async {
            try {
              if (index < 0 ||
                  index >= controller.videoPlayerControllerList.length) {
                return;
              }
              for (var i = 0;
                  i < controller.videoPlayerControllerList.length;
                  i++) {
                if (i != index &&
                    controller
                        .videoPlayerControllerList[i].value.isInitialized) {
                  await controller.videoPlayerControllerList[i].pause();
                }
              }
              if (controller
                  .videoPlayerControllerList[index].value.isInitialized) {
                await controller.videoPlayerControllerList[index].play();
              }
              if (widget.reelController != null) {
                controller.checkAndFetchMoreReels(
                    reelController: widget.reelController!,
                    currentIndex: index);
              }
            } catch (e) {
              errorMessage("Please calm down the controller");
            }
          },
          itemBuilder: (context, index) {
            if (index < controller.videoPlayerControllerList.length) {
              return _buildTile(index);
            } else {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
          },
        );
      }),
    );
  }

  Widget _buildTile(int index) {
    final reel = widget.reels != null && index < widget.reels!.length
        ? widget.reels![index]
        : null;
    final vpController = controller.videoPlayerControllerList[index];
    if (vpController.dataSource.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: reel?.thumbnailUrl != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(base64Decode(reel!.thumbnailUrl!)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.dstATop),
                  ),
                )
              : null,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text("Video unavailable",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return VisibilityDetector(
      key: Key('reel_tile_$index'),
      onVisibilityChanged: (visibilityInfo) async {
        if (!_isMounted) return;
        if (index < 0 || index >= controller.videoPlayerControllerList.length) {
          return;
        }
        await Future.delayed(const Duration(milliseconds: 100));
        if (visibilityInfo.visibleFraction < 0.5) {
          if (vpController.value.isInitialized) {
            await vpController.seekTo(Duration.zero);
            await vpController.pause();
          }
          controller.safeAnimationStop();
        } else {
          if (vpController.value.isInitialized) {
            await vpController.play();
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
          if (index < 0 || index >= controller.videoPlayerControllerList.length) {
            return;
          }
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
          if (index < 0 ||
              index >= controller.videoPlayerControllerList.length) {
            return const Center(child: Text("Error: Invalid index"));
          }
          if (controller.loading.value || !vpController.value.isInitialized) {
            return reel?.thumbnailUrl != null
                ? Image.memory(
                    base64Decode(reel!.thumbnailUrl!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(GifsPath.loadingGif2),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(GifsPath.loadingGif2),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
          }
          if (!_progressControllers.containsKey(index)) {
            _progressControllers[index] = StreamController<double>.broadcast();
            void listener() {
              if (vpController.value.isInitialized && _isMounted) {
                double videoProgress =
                    vpController.value.position.inMilliseconds /
                        vpController.value.duration.inMilliseconds;
                _progressControllers[index]!.add(videoProgress);
              }
            }

            _progressListeners[index] = listener;
            vpController.addListener(listener);
          }

          Widget videoWidget = VideoFullScreenWidget(
            videoPlayerController: vpController,
            controller: controller,
          );
          return widget.builder == null
              ? videoWidget
              : widget.builder!(
                  context,
                  index,
                  videoWidget,
                  vpController,
                  controller.pageController,
                  _progressControllers[index]!,
                );
        }),
      ),
    );
  }
}
