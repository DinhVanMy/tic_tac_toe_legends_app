import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  // Cache để lưu trữ quyền truy cập admin để tránh truy vấn lặp lại
  static final Map<String, bool> _adminAccessCache = {};
  static DateTime _lastCacheClear = DateTime.now();

  @override
  RouteSettings? redirect(String? route) {
    // Kiểm tra quyền truy cập admin - sử dụng FutureBuilder trong UI thay vì async ở đây
    _checkAdminAccess().then((hasAccess) {
      if (!hasAccess) {
        // Hiển thị thông báo lỗi
        errorMessage('Bạn không có quyền truy cập vào trang quản trị');

        // Chuyển hướng về trang chính
        Get.offAllNamed('/mainHome');
      }
    }).catchError((error) {
      errorMessage('Lỗi khi kiểm tra quyền truy cập: $error');
      Get.offAllNamed('/mainHome');
    });

    // Trả về null để ngăn chặn chuyển hướng nếu người dùng đã có quyền truy cập
    // Chúng ta sẽ thực hiện chuyển hướng thủ công trong hàm _checkAdminAccess nếu cần
    return null;
  }

  Future<bool> _checkAdminAccess() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Kiểm tra cache để tránh truy vấn quá nhiều vào Firestore
      final userId = user.uid;

      // Xóa cache mỗi 15 phút để cập nhật quyền
      _clearCacheIfNeeded();

      // Nếu đã có trong cache, trả về kết quả
      if (_adminAccessCache.containsKey(userId)) {
        return _adminAccessCache[userId]!;
      }

      // Truy vấn Firestore để lấy thông tin người dùng
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final isAdmin = userData['role'] == 'admin';

      // Lưu kết quả vào cache
      _adminAccessCache[userId] = isAdmin;

      return isAdmin;
    } catch (e) {
      print('Error checking admin access: $e');
      return false;
    }
  }

  // Xóa cache mỗi 15 phút để cập nhật quyền
  void _clearCacheIfNeeded() {
    final now = DateTime.now();
    if (now.difference(_lastCacheClear).inMinutes >= 15) {
      _adminAccessCache.clear();
      _lastCacheClear = now;
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null) {
      _logAccess(page.name);
    }
    return page;
  }

  // Ghi log khi có người truy cập trang admin
  void _logAccess(String route) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance.collection('admin_access_logs').add({
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'route': route,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Chỉ ghi log, không ảnh hưởng đến luồng chính
        print('Error logging admin access: $e');
      }
    }
  }
}
