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
  int loadLimit = 1; // Giảm từ 3 xuống 1 để tối ưu hiệu suất
  List<int> alreadyListened = [];
  List<String> caching = [];
  RxInt pageCount = 0.obs;
  final int startIndex;
  bool isCaching;
  bool _isDisposed = false;
  final Map<int, int> _retryAttempts =
      {}; // Theo dõi số lần thử lại cho mỗi video

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      for (var controller in videoPlayerControllerList) {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          controller.pause();
        }
      }
      safeAnimationStop();
    } else if (state == AppLifecycleState.resumed) {
      final currentIndex = pageController.page?.toInt() ?? startIndex;
      if (currentIndex >= 0 &&
          currentIndex < videoPlayerControllerList.length) {
        final controller = videoPlayerControllerList[currentIndex];
        if (controller.value.isInitialized && !controller.value.isPlaying) {
          controller.play();
        }
      }
    }
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
          videoPlayerControllerList
              .add(VideoPlayerController.networkUrl(Uri.parse('')));
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
          newControllers.add(VideoPlayerController.networkUrl(Uri.parse('')));
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
    if (currentIndex >= videoList.length - 1 && !isFetchingMore.value) {
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
      if (_isDisposed) return;
      if (vpController.value.isInitialized &&
          vpController.value.position >= vpController.value.duration &&
          vpController.value.duration != Duration.zero) {
        vpController.seekTo(Duration.zero);
        vpController.play();
      }
    });
  }

  Future<void> cacheVideo(int index) async {
    if (!isCaching || _isDisposed) return;
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
    if (_isDisposed) return;
    try {
      if (videoList.asMap().containsKey(index) &&
          !videoPlayerControllerList[index].value.isInitialized) {
        await videoPlayerControllerList[index].initialize();
      }

      for (int i = 1; i <= loadLimit; i++) {
        if (_isDisposed) return;
        int nextIndex = index + i;
        int prevIndex = index - i;

        if (videoList.asMap().containsKey(nextIndex) &&
            !videoPlayerControllerList[nextIndex].value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 150));
          if (!_isDisposed) {
            await videoPlayerControllerList[nextIndex].initialize();
          }
        }
        if (videoList.asMap().containsKey(prevIndex) &&
            !videoPlayerControllerList[prevIndex].value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 150));
          if (!_isDisposed) {
            await videoPlayerControllerList[prevIndex].initialize();
          }
        }
      }
    } catch (e) {
      log('Error initializing nearby videos at index $index: $e');
    }
    loading.value = false;
  }

  Future<bool> retryInitializeVideo(int index) async {
    if (_isDisposed || index < 0 || index >= videoList.length) return false;

    // Tăng số lần thử lại
    _retryAttempts[index] = (_retryAttempts[index] ?? 0) + 1;

    try {
      final url = videoList[index];
      final newController =
          await videoControllerService.getControllerForVideo(url, isCaching);
      if (newController != null) {
        await videoPlayerControllerList[index].pause();
        videoPlayerControllerList[index].dispose();
        videoPlayerControllerList[index] = newController;
        await newController.initialize();
        await newController.play();
        _retryAttempts.remove(index); // Reset số lần thử khi thành công
        videoPlayerControllerList.refresh();
        return true;
      } else {
        if (_retryAttempts[index]! >= 2) {
          // Nếu thử lại 2 lần vẫn lỗi
          await removeInvalidVideo(index);
        }
        return false;
      }
    } catch (e) {
      log('Error retrying video at index $index: $e');
      if (_retryAttempts[index]! >= 2) {
        await removeInvalidVideo(index);
      }
      return false;
    }
  }

  Future<void> removeInvalidVideo(int index) async {
    if (index < 0 || index >= videoList.length) return;
    log('Removing invalid video at index $index: ${videoList[index]}');
    videoPlayerControllerList[index].dispose();
    videoPlayerControllerList.removeAt(index);
    videoList.removeAt(index);
    pageCount.value = videoList.length;
    videoPlayerControllerList.refresh();
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
