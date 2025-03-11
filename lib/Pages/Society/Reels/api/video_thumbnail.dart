import 'dart:async';
import 'package:flutter/services.dart';

/// Enum định nghĩa các định dạng ảnh thumbnail hỗ trợ
enum ImageFormat { JPEG, PNG, WEBP }

/// Lớp xử lý tạo thumbnail từ video, thay thế package video_thumbnail
class VideoThumbnail {
  // Định nghĩa MethodChannel với một tên duy nhất cho dự án của bạn
  static const MethodChannel _channel =
      MethodChannel('com.example.tictactoe_gameapp/video_thumbnail');

  /// Tạo thumbnail dưới dạng tệp và lưu vào đường dẫn được chỉ định
  static Future<String?> thumbnailFile({
    required String video, // Đường dẫn video cục bộ hoặc URL
    Map<String, String>? headers, // Headers cho yêu cầu HTTP (nếu là URL)
    String? thumbnailPath, // Đường dẫn lưu thumbnail (nếu null, dùng mặc định)
    ImageFormat imageFormat = ImageFormat.JPEG, // Định dạng mặc định là JPEG để tối ưu dung lượng
    int maxHeight = 0, // 0 để giữ nguyên chiều cao gốc
    int maxWidth = 0,  // 0 để giữ nguyên chiều rộng gốc
    int timeMs = 0,    // Frame tại thời gian (ms), mặc định là frame đầu tiên
    int quality = 75,  // Chất lượng mặc định cao hơn (75) cho hình ảnh nét
  }) async {
    try {
      // Kiểm tra video không rỗng
      if (video.isEmpty) throw Exception('Video path or URL cannot be empty');

      final reqMap = <String, dynamic>{
        'video': video,
        'headers': headers,
        'path': thumbnailPath,
        'format': imageFormat.index,
        'maxh': maxHeight,
        'maxw': maxWidth,
        'timeMs': timeMs,
        'quality': quality.clamp(0, 100), // Giới hạn quality từ 0-100
      };

      final result = await _channel.invokeMethod<String>('file', reqMap);
      if (result == null) throw Exception('Failed to generate thumbnail file');
      return result;
    } catch (e) {
      print('Error generating thumbnail file: $e');
      return null;
    }
  }

  /// Tạo thumbnail dưới dạng dữ liệu Uint8List để dùng trực tiếp trong bộ nhớ
  static Future<Uint8List?> thumbnailData({
    required String video,
    Map<String, String>? headers,
    ImageFormat imageFormat = ImageFormat.JPEG,
    int maxHeight = 0,
    int maxWidth = 0,
    int timeMs = 0,
    int quality = 75,
  }) async {
    try {
      if (video.isEmpty) throw Exception('Video path or URL cannot be empty');

      final reqMap = <String, dynamic>{
        'video': video,
        'headers': headers,
        'format': imageFormat.index,
        'maxh': maxHeight,
        'maxw': maxWidth,
        'timeMs': timeMs,
        'quality': quality.clamp(0, 100),
      };

      final result = await _channel.invokeMethod<Uint8List>('data', reqMap);
      if (result == null) throw Exception('Failed to generate thumbnail data');
      return result;
    } catch (e) {
      print('Error generating thumbnail data: $e');
      return null;
    }
  }

  /// Tối ưu hóa: Tạo thumbnail với kích thước chuẩn cho reels (360x640)
  static Future<Uint8List?> generateReelThumbnail({
    required String videoUrl,
    Map<String, String>? headers,
    int timeMs = 0,
    int quality = 75,
  }) async {
    return await thumbnailData(
      video: videoUrl,
      headers: headers,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 640, // Tỷ lệ 9:16 phổ biến cho reels
      maxWidth: 360,
      timeMs: timeMs,
      quality: quality,
    );
  }
}