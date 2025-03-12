import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_controller.dart';
import 'package:video_player/video_player.dart';
import 'video_controller_service.dart';

class WhiteCodelReelsController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  final PageController pageController = PageController(viewportFraction: 1.0);
  RxList<VideoPlayerController> videoPlayerControllerList =
      <VideoPlayerController>[].obs;
  final CachedVideoControllerService videoControllerService =
      CachedVideoControllerService(CustomCacheManager.instance);

  RxBool loading = true.obs;
  RxBool visible = false.obs;
  RxBool isFetchingMore = false.obs;
  late AnimationController animationController;
  late Animation animation;

  final List<String> reelsVideoList;
  List<String> videoList = <String>[];
  int loadLimit = 3;
  List<int> alreadyListened = [];
  List<String> caching = [];
  RxInt pageCount = 0.obs;
  final int startIndex;
  bool isCaching;
  bool _isDisposed = false;

  WhiteCodelReelsController({
    required this.reelsVideoList,
    required this.isCaching,
    this.startIndex = 0,
  });

  @override
  void onInit() {
    super.onInit();
    videoList.addAll(reelsVideoList);
    pageCount.value = videoList.length;

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);

    _initializeVideoControllers(startIndex);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    _isDisposed = true;
    final List<VideoPlayerController> controllersToDispose =
        List.from(videoPlayerControllerList);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoPlayerControllerList.clear();
    });
    for (var controller in controllersToDispose) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
      controller.dispose();
    }
    animationController.dispose();
    pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> _initializeVideoControllers(int startIndex) async {
    loading.value = true;
    List<String> validUrls = [];
    videoPlayerControllerList.clear();

    for (var url in videoList) {
      try {
        final controller =
            await videoControllerService.getControllerForVideo(url, isCaching);
        if (controller != null) {
          videoPlayerControllerList.add(controller);
          validUrls.add(url);
        } else {
          videoPlayerControllerList.add(VideoPlayerController.networkUrl(
              Uri.parse(''))); // Controller rỗng
          validUrls.add(url);
        }
      } catch (e) {
        debugPrint('Skipping invalid URL: $url, error: $e');
      }
    }
    videoPlayerControllerList.refresh();
    videoList = validUrls;
    pageCount.value = videoPlayerControllerList.length;

    if (videoPlayerControllerList.isNotEmpty &&
        startIndex < videoPlayerControllerList.length) {
      final initialController = videoPlayerControllerList[startIndex];
      if (initialController.dataSource.isNotEmpty) {
        try {
          await initialController.initialize();
          await initialController.play();
        } catch (e) {
          debugPrint('Error initializing first video: $e');
        }
      }
    }
    loading.value = false;
  }

  Future<void> updateVideoList(List<String> newVideoList) async {
    final newUrls =
        newVideoList.where((url) => !videoList.contains(url)).toList();
    if (newUrls.isEmpty) return;

    List<String> validUrls = [];
    List<VideoPlayerController> newControllers = [];

    for (var url in newUrls) {
      try {
        final controller =
            await videoControllerService.getControllerForVideo(url, isCaching);
        if (controller != null) {
          newControllers.add(controller);
          validUrls.add(url);
        } else {
          newControllers.add(VideoPlayerController.networkUrl(
              Uri.parse(''))); // Controller rỗng
          validUrls.add(url);
        }
      } catch (e) {
        log('Error adding video controller for $url: $e');
      }
    }

    videoList.addAll(validUrls);
    videoPlayerControllerList.addAll(newControllers);
    pageCount.value = videoPlayerControllerList.length;
    videoPlayerControllerList.refresh();
  }

  void checkAndFetchMoreReels(
      {required ReelController reelController,
      required int currentIndex}) async {
    if (currentIndex >= videoList.length - 1 &&
        !isFetchingMore.value &&
        !reelController.isFetching.value) {
      isFetchingMore.value = true;
      for (var controller in videoPlayerControllerList) {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
        }
      }
      await reelController.fetchMoreReels();
      await updateVideoList(
          reelController.reelsList.map((e) => e.videoUrl!).toList());
      isFetchingMore.value = false;
    }
  }

  void listenEvents(int index, {bool force = false}) {
    if (alreadyListened.contains(index) && !force) return;
    alreadyListened.add(index);
    var vpController = videoPlayerControllerList[index];
    vpController.addListener(() {
      if (vpController.value.isInitialized &&
          vpController.value.position >= vpController.value.duration &&
          vpController.value.duration != Duration.zero) {
        vpController.seekTo(Duration.zero);
        vpController.play();
      }
    });
  }

  Future<void> cacheVideo(int index) async {
    if (!isCaching) return;
    String url = videoList[index];
    if (caching.contains(url)) return;
    caching.add(url);
    final cacheManager = CustomCacheManager.instance;
    try {
      final fileInfo = await cacheManager.getFileFromCache(url);
      if (fileInfo != null) return;
      await cacheManager.downloadFile(url);
    } catch (e) {
      caching.remove(url);
      log('Error caching video at index $index: $e');
    }
  }

  Future<void> initNearByVideos(int index) async {
    try {
      for (int i = index; i < index + loadLimit; i++) {
        if (videoList.asMap().containsKey(i) &&
            !videoPlayerControllerList[i].value.isInitialized) {
          await videoPlayerControllerList[i].initialize();
        }
      }
      for (int i = index - 1; i >= index - loadLimit; i--) {
        if (videoList.asMap().containsKey(i) &&
            !videoPlayerControllerList[i].value.isInitialized) {
          await videoPlayerControllerList[i].initialize();
        }
      }
    } catch (e) {
      log('Error initializing nearby videos at index $index: $e');
    }
    loading.value = false;
  }

  void safeAnimationStop() {
    if (!_isDisposed) {
      try {
        animationController.stop();
      } catch (e) {
        log('Error stopping animationController: $e');
      }
    }
  }

  void safeAnimationRepeat() {
    if (!_isDisposed) {
      try {
        animationController.repeat();
      } catch (e) {
        log('Error repeating animationController: $e');
      }
    }
  }
}
