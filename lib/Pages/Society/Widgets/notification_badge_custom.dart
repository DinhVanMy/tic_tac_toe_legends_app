import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final String userId;

  const NotificationBadge({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadNotificationCountStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Trường hợp chưa tải được dữ liệu từ Firestore
          return const Icon(Icons.notifications);
        }

        int unreadCount = snapshot.data!;
        return _buildNotificationIcon(unreadCount);
      },
    );
  }

  // Hàm để tạo Stream đếm số lượng thông báo chưa đọc
  Stream<int> _unreadNotificationCountStream() {
    return FirebaseFirestore.instance
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .where("isReaded", isEqualTo: false) // Chỉ lấy thông báo chưa đọc
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Hàm dựng giao diện UI với badge cho số lượng thông báo chưa đọc
  Widget _buildNotificationIcon(int unreadCount) {
    return Stack(
      children: [
        const Icon(Icons.notifications),
        if (unreadCount > 0) // Chỉ hiển thị badge nếu có thông báo chưa đọc
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                unreadCount > 9 ? "9+" : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
