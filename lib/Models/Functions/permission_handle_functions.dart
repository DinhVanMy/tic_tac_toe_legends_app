import 'package:permission_handler/permission_handler.dart';

class PermissionHandleFunctions {
  /// Kiểm tra và yêu cầu quyền Microphone
  Future<bool> checkMicrophonePermission() async {
    return await _checkAndRequestPermission(Permission.microphone);
  }

  /// Kiểm tra và yêu cầu quyền Camera
  Future<bool> checkCameraPermission() async {
    return await _checkAndRequestPermission(Permission.camera);
  }

  /// Kiểm tra và yêu cầu quyền Thông báo
  Future<bool> checkNotificationPermission() async {
    return await _checkAndRequestPermission(Permission.notification);
  }

  /// Kiểm tra và yêu cầu quyền Địa chỉ (Location)
  Future<bool> checkLocationPermission() async {
    return await _checkAndRequestPermission(Permission.location);
  }

  /// Kiểm tra tất cả các quyền cần thiết và trả về kết quả
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      "microphone": await checkMicrophonePermission(),
      "camera": await checkCameraPermission(),
      "notification": await checkNotificationPermission(),
      "location": await checkLocationPermission(),
    };
  }

  /// Hàm chung để kiểm tra và yêu cầu quyền
  Future<bool> _checkAndRequestPermission(Permission permission) async {
    var status = await permission.status;

    // Nếu quyền bị từ chối hoặc chưa xác định, yêu cầu lại
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      var result = await permission.request();
      return result.isGranted;
    }

    // Trả về `true` nếu đã có quyền
    return status.isGranted;
  }

  /// Kiểm tra xem quyền có bị từ chối vĩnh viễn hay không
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// Chuyển hướng người dùng đến cài đặt ứng dụng nếu quyền bị từ chối vĩnh viễn
  Future<void> openAppSettingsIfDenied(Permission permission) async {
    if (await isPermissionPermanentlyDenied(permission)) {
      await openAppSettings();
    }
  }
}
