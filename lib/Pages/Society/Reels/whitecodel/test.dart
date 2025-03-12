// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_controller.dart';
// import 'package:video_player/video_player.dart';
// import 'video_controller_service.dart';

// class WhiteCodelReelsController extends GetxController
//     with GetTickerProviderStateMixin, WidgetsBindingObserver {
//   final PageController pageController = PageController(viewportFraction: 1.0);
//   RxList<VideoPlayerController> videoPlayerControllerList =
//       <VideoPlayerController>[].obs;
//   final NetworkVideoControllerService videoControllerService =
//       NetworkVideoControllerService();

//   RxBool loading = true.obs;
//   RxBool visible = false.obs;
//   RxBool isFetchingMore = false.obs;
//   late AnimationController animationController;
//   late Animation animation;

//   final List<String> reelsVideoList;
//   List<String> videoList = <String>[];
//   int loadLimit = 1; // Vẫn giữ để khởi tạo video lân cận
//   List<int> alreadyListened = [];
//   RxInt pageCount = 0.obs;
//   final int startIndex;
//   bool _isDisposed = false;

//   WhiteCodelReelsController({
//     required this.reelsVideoList,
//     this.startIndex = 0,
//   });

//   @override
//   void onInit() {
//     super.onInit();
//     videoList.addAll(reelsVideoList);
//     pageCount.value = videoList.length;

//     animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 5));
//     animation =
//         CurvedAnimation(parent: animationController, curve: Curves.easeIn);

//     _initializeVideoControllers(startIndex);
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void onClose() {
//     _isDisposed = true;
//     final List<VideoPlayerController> controllersToDispose =
//         List.from(videoPlayerControllerList);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       videoPlayerControllerList.clear();
//     });
//     for (var controller in controllersToDispose) {
//       if (controller.value.isInitialized) {
//         controller.pause();
//       }
//       controller.dispose();
//     }
//     animationController.dispose();
//     pageController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.onClose();
//   }

//   Future<void> _initializeVideoControllers(int startIndex) async {
//     loading.value = true;
//     videoPlayerControllerList.clear();
//     videoList.clear();
//     videoList.addAll(reelsVideoList);

//     if (startIndex >= 0 && startIndex < videoList.length) {
//       try {
//         final controller =
//             await videoControllerService.getControllerForVideo(videoList[startIndex]);
//         if (controller != null) {
//           videoPlayerControllerList.add(controller);
//           await controller.play();
//         } else {
//           videoPlayerControllerList.add(VideoPlayerController.networkUrl(Uri.parse('')));
//         }
//       } catch (e) {
//         log('Error initializing first video: $e');
//         videoPlayerControllerList.add(VideoPlayerController.networkUrl(Uri.parse('')));
//       }
//     }

//     pageCount.value = videoList.length;
//     loading.value = false;

//     await initNearByVideos(startIndex);
//   }

//   Future<void> updateVideoList(List<String> newVideoList) async {
//     final newUrls =
//         newVideoList.where((url) => !videoList.contains(url)).toList();
//     if (newUrls.isEmpty) return;

//     videoList.addAll(newUrls);
//     pageCount.value = videoList.length;

//     // Không cache, chỉ thêm controller rỗng
//     for (var url in newUrls) {
//       videoPlayerControllerList.add(VideoPlayerController.networkUrl(Uri.parse('')));
//     }
//   }

//   void checkAndFetchMoreReels({
//     required ReelController reelController,
//     required int currentIndex,
//   }) async {
//     if (currentIndex >= videoList.length - 3 &&
//         !isFetchingMore.value &&
//         !reelController.isFetching.value) {
//       isFetchingMore.value = true;
//       for (var controller in videoPlayerControllerList) {
//         if (controller.value.isInitialized && controller.value.isPlaying) {
//           await controller.pause();
//         }
//       }
//       await reelController.fetchMoreReels();
//       await updateVideoList(
//           reelController.reelsList.map((e) => e.videoUrl!).toList());
//       isFetchingMore.value = false;
//     }
//   }

//   void listenEvents(int index, {bool force = false}) {
//     if (alreadyListened.contains(index) && !force) return;
//     alreadyListened.add(index);
//     var vpController = videoPlayerControllerList[index];
//     vpController.addListener(() async {
//       if (vpController.value.isInitialized) {
//         if (vpController.value.position >= vpController.value.duration &&
//             vpController.value.duration != Duration.zero) {
//           vpController.seekTo(Duration.zero);
//           vpController.play();
//         }
//       }
//     });
//   }

//   Future<void> initNearByVideos(int index) async {
//     try {
//       if (!videoPlayerControllerList[index].value.isInitialized) {
//         final controller =
//             await videoControllerService.getControllerForVideo(videoList[index]);
//         if (controller != null) {
//           videoPlayerControllerList[index] = controller;
//         }
//       }
//       for (int i = index + 1; i < index + loadLimit + 1; i++) {
//         if (videoList.asMap().containsKey(i) &&
//             !videoPlayerControllerList[i].value.isInitialized) {
//           final controller =
//               await videoControllerService.getControllerForVideo(videoList[i]);
//           if (controller != null) {
//             videoPlayerControllerList[i] = controller;
//           }
//         }
//       }
//       for (int i = index - 1; i >= index - loadLimit; i--) {
//         if (videoList.asMap().containsKey(i) &&
//             !videoPlayerControllerList[i].value.isInitialized) {
//           final controller =
//               await videoControllerService.getControllerForVideo(videoList[i]);
//           if (controller != null) {
//             videoPlayerControllerList[i] = controller;
//           }
//         }
//       }
//     } catch (e) {
//       log('Error initializing nearby videos at index $index: $e');
//     }
//   }

//   void disposeFarControllers(int currentIndex) {
//     for (int i = 0; i < videoPlayerControllerList.length; i++) {
//       if ((i - currentIndex).abs() > 2 &&
//           videoPlayerControllerList[i].value.isInitialized) {
//         videoPlayerControllerList[i].dispose();
//         videoPlayerControllerList[i] =
//             VideoPlayerController.networkUrl(Uri.parse(''));
//       }
//     }
//   }

//   void safeAnimationStop() {
//     if (!_isDisposed) {
//       try {
//         animationController.stop();
//       } catch (e) {
//         log('Error stopping animationController: $e');
//       }
//     }
//   }

//   void safeAnimationRepeat() {
//     if (!_isDisposed) {
//       try {
//         animationController.repeat();
//       } catch (e) {
//         log('Error repeating animationController: $e');
//       }
//     }
//   }
// }