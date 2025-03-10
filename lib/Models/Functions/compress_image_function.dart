import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CompressImageFunction {
  static Future<List<String>> processImages(List<XFile>? imageFiles) async {
    List<String> base64ImageList = [];
    int totalBase64Size = 0;

    if (imageFiles == null || imageFiles.isEmpty) {
      return base64ImageList;
    }

    try {
      for (XFile imageFile in imageFiles) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64String = base64Encode(imageBytes);

        // Tính kích thước Base64 của ảnh hiện tại
        int base64Size = calculateBase64Size(base64String);
        totalBase64Size += base64Size;

        // Kiểm tra nếu tổng kích thước ảnh vượt quá 1MB
        if (totalBase64Size > 999999) {
          errorMessage(
              "Total size of selected images exceeds 1 MB. Please select smaller images.");
          return []; // Trả về danh sách rỗng nếu kích thước vượt quá 1MB
        }

        base64ImageList.add(base64String);
      }
    } catch (e) {
      errorMessage("Error reading images: ${e.toString()}");
      return []; // Trả về danh sách rỗng nếu gặp lỗi
    }

    return base64ImageList;
  }

  static Future<String> processImage(XFile imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String? base64String = base64Encode(imageBytes);

      // Kiểm tra kích thước của chuỗi Base64
      int base64Size = CompressImageFunction.calculateBase64Size(base64String);
      if (base64Size > 999999) {
        errorMessage("Please pick a image which is lighter than 1 mega byte");
        return "";
      }
      return base64String;
    } catch (e) {
      errorMessage("Error reading image: ${e.toString()}");
      return "";
    }
  }

  static int calculateBase64Size(String base64String) {
    int padding = base64String.endsWith('==')
        ? 2
        : base64String.endsWith('=')
            ? 1
            : 0;
    int size = (base64String.length * 3 / 4).floor() - padding;
    return size; // Kích thước tính bằng byte
  }

  static Future<String?> generateThumbnailBase64(String videoUrl) async {
    try {
      // Tạo thumbnail từ video URL
      Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.WEBP, // Dùng JPEG để nén tốt hơn
        maxHeight: 480, // Chiều cao tối đa phù hợp mobile (720p/2)
        maxWidth: 270, // Chiều rộng tỉ lệ 9:16
        timeMs: 0, // Lấy khung hình đầu tiên
        quality: 75, // Chất lượng ban đầu
      );

      if (thumbnailData == null) {
        errorMessage("Failed to generate thumbnail from video");
        return null;
      }

      // Kiểm tra kích thước dữ liệu
      int sizeInBytes = thumbnailData.lengthInBytes;
      if (sizeInBytes > 500 * 1024) {
        // Nếu lớn hơn 500KB, nén thêm
        int quality = 75;
        while (sizeInBytes > 500 * 1024 && quality > 10) {
          quality -= 10;
          thumbnailData = await VideoThumbnail.thumbnailData(
            video: videoUrl,
            imageFormat: ImageFormat.WEBP,
            maxHeight: 480,
            maxWidth: 270,
            timeMs: 0,
            quality: quality,
          );
          sizeInBytes = thumbnailData!.lengthInBytes;
        }
      }

      // Chuyển thành base64
      String base64String = base64Encode(thumbnailData!);
      double base64Size =
          base64String.length * 0.75; // Ước tính kích thước bytes
      if (base64Size > 500 * 1024) {
        // Đảm bảo dưới 500KB để an toàn trong 1MB Firestore
        errorMessage("Thumbnail size exceeds limit after compression");
        return null;
      }

      return base64String;
    } catch (e) {
      errorMessage("Error generating thumbnail: $e");
      return null;
    }
  }
}
