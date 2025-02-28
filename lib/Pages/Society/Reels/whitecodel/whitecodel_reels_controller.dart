import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
      CachedVideoControllerService(DefaultCacheManager());

  RxBool loading = true.obs;
  RxBool visible = false.obs;
  late AnimationController animationController;
  late Animation animation;

  // Danh sách URL gốc
  final List<String> reelsVideoList;
  // Danh sách URL hợp lệ sau khi loại bỏ URL không hợp lệ
  List<String> videoList = <String>[].obs;

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
    // Copy toàn bộ URL ban đầu vào videoList
    videoList.addAll(reelsVideoList);
    // Khởi tạo số trang dựa trên số URL hợp lệ (sẽ cập nhật sau)
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
    // Tạo bản sao danh sách controller hiện tại
    final List<VideoPlayerController> controllersToDispose =
        List.from(videoPlayerControllerList);

    // Trì hoãn việc clear RxList cho đến sau frame hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoPlayerControllerList.clear();
    });

    for (var controller in controllersToDispose) {
      // Nếu controller đã được khởi tạo, pause trước khi dispose
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

// Kiểm tra và fetch thêm reels khi gần cuối danh sách
  void checkAndFetchMoreReels({
    required ReelController reelController,
    required int currentIndex,
  }) async {
    if (currentIndex >= videoList.length - 1 && !reelController.isFetching) {
      // Pause tất cả video đang phát
      for (var controller in videoPlayerControllerList) {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
        }
      }
      // Fetch thêm reels
      await reelController.fetchMoreReels();
      updateVideoList(
          reelController.reelsList.map((e) => e.videoUrl!).toList());
    }
  }

  // Cập nhật danh sách video và VideoPlayerController
  void updateVideoList(List<String> newVideoList) async {
    final newUrls =
        newVideoList.where((url) => !videoList.contains(url)).toList();
    if (newUrls.isEmpty) return;

    videoList.addAll(newUrls);
    pageCount.value = videoList.length;

    for (var url in newUrls) {
      try {
        final controller =
            await videoControllerService.getControllerForVideo(url, isCaching);
        videoPlayerControllerList.add(controller);
      } catch (e) {
        log('Error adding video controller for $url: $e');
      }
    }
    videoPlayerControllerList.refresh();
  }

  Future<void> _initializeVideoControllers(int startIndex) async {
    loading.value = true; // Đặt loading thành true ngay từ đầu
    List<String> validUrls = [];
    videoPlayerControllerList.clear();

    // Khởi tạo danh sách controller
    for (var url in videoList) {
      try {
        final controller =
            await videoControllerService.getControllerForVideo(url, isCaching);
        videoPlayerControllerList.add(controller);
        validUrls.add(url);
      } catch (e) {
        debugPrint('Skipping invalid URL: $url, error: $e');
      }
    }
    videoPlayerControllerList.refresh();
    videoList = validUrls;
    pageCount.value = videoPlayerControllerList.length;

    // Khởi tạo và phát video đầu tiên
    if (videoPlayerControllerList.isNotEmpty &&
        startIndex < videoPlayerControllerList.length) {
      try {
        await videoPlayerControllerList[startIndex].initialize();
        await videoPlayerControllerList[startIndex].play();
        loading.value = false; // Chỉ đặt false khi video đầu tiên sẵn sàng
      } catch (e) {
        debugPrint('Error initializing first video: $e');
        loading.value = false; // Đặt false nếu có lỗi để tránh treo ứng dụng
      }
    } else {
      loading.value = false; // Không có video thì đặt false
    }
  }

  // Các phương thức khác (initNearByVideos, listenEvents, cacheVideo, ...) giữ nguyên hoặc tinh chỉnh tương tự
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
    final cacheManager = DefaultCacheManager();
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
      // Khởi tạo video sau
      for (int i = index; i < index + loadLimit; i++) {
        if (videoList.asMap().containsKey(i) &&
            !videoPlayerControllerList[i].value.isInitialized) {
          await videoPlayerControllerList[i].initialize();
        }
      }
      // Khởi tạo video trước
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

  /// Hàm an toàn dừng animation controller
  void safeAnimationStop() {
    if (!_isDisposed) {
      try {
        animationController.stop();
      } catch (e) {
        log('Error stopping animationController: $e');
      }
    }
  }

  /// Hàm an toàn chạy lại animation controller
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
