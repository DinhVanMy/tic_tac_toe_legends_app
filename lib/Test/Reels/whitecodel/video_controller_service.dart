import 'dart:async';
import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

/// Abstract class định nghĩa phương thức lấy controller cho video.
abstract class VideoControllerService {
  Future<VideoPlayerController> getControllerForVideo(
      String url, bool isCaching);
}

/// Triển khai VideoControllerService sử dụng caching.
class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getControllerForVideo(
      String url, bool isCaching) async {
    if (isCaching) {
      try {
        // Thử lấy file từ cache
        FileInfo? fileInfo = await _cacheManager.getFileFromCache(url);
        if (fileInfo != null) {
          return VideoPlayerController.file(fileInfo.file);
        }
        // Nếu không có trong cache, download file
        fileInfo = await _cacheManager.downloadFile(url);
        return VideoPlayerController.file(fileInfo.file);
      } catch (e) {
        log('Error downloading video from url $url: $e');
        // Nếu xảy ra lỗi (ví dụ: 403), trả về controller từ asset fallback.
        try {
          final fallbackController =
              VideoPlayerController.asset('assets/videos/blank.mp4');
          await fallbackController.initialize();
          return fallbackController;
        } catch (assetError) {
          log('Error initializing fallback asset: $assetError');
          // Nếu fallback asset cũng gặp lỗi, trả về network controller (mặc dù có thể không hoạt động)
          return VideoPlayerController.networkUrl(Uri.parse(url));
        }
      }
    } else {
      try {
        return VideoPlayerController.networkUrl(Uri.parse(url));
      } catch (e) {
        log('Error creating network controller for url $url: $e');
        // Nếu có lỗi tạo controller từ network, dùng fallback asset.
        try {
          final fallbackController =
              VideoPlayerController.asset('assets/videos/blank.mp4');
          await fallbackController.initialize();
          return fallbackController;
        } catch (assetError) {
          log('Error initializing fallback asset: $assetError');
          throw Exception('Invalid video URL: $url');
        }
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
