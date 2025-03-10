import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

/// Abstract class định nghĩa phương thức lấy controller cho video.
abstract class VideoControllerService {
  Future<VideoPlayerController?> getControllerForVideo(String url, bool isCaching);
}

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController?> getControllerForVideo(String url, bool isCaching) async {
    if (isCaching) {
      try {
        FileInfo? fileInfo = await _cacheManager.getFileFromCache(url);
        if (fileInfo != null) return VideoPlayerController.file(fileInfo.file);
        fileInfo = await _cacheManager.downloadFile(url);
        return VideoPlayerController.file(fileInfo.file);
      } catch (e) {
        log('Error downloading video from $url: $e');
        return null; // Trả về null khi lỗi
      }
    } else {
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        return controller;
      } catch (e) {
        log('Error creating network controller for $url: $e');
        return null; // Trả về null khi lỗi
      }
    }
  }
}

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 20,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
  static CacheManager defaultInstance = DefaultCacheManager();
}