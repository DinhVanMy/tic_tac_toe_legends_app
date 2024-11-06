import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/general_notifications_model.dart';

class PostNotificationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final String userId;
  PostNotificationController(this.userId);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TabController tabController;

  // Danh sách thông báo và số lượng thông báo chưa đọc
  var notifications = <GeneralNotificationsModel>[].obs;
  var unisReadedCount = 0.obs;

  // Map phân loại thông báo để dễ dàng hiển thị trên UI
  var likeNotifications = <GeneralNotificationsModel>[].obs;
  var commentNotifications = <GeneralNotificationsModel>[].obs;
  var sharedNotifications = <GeneralNotificationsModel>[].obs;

  // Trang hiện tại và số lượng thông báo mỗi trang
  final int notificationsPerPage = 10;
  DocumentSnapshot? lastDocument;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    _listenToNotifications();
    removeOldNotifications();
  }

  // Lắng nghe và phân loại thông báo theo thời gian thực, với tính năng thông báo nhóm
  void _listenToNotifications() {
    _firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .limit(notificationsPerPage)
        .snapshots()
        .listen((snapshot) {
      var allNotifications = snapshot.docs
          .map((doc) => GeneralNotificationsModel.fromJson(doc.data()))
          .toList();

      // Lưu trữ tài liệu cuối cùng để phân trang
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      notifications.value = allNotifications;
      unisReadedCount.value =
          allNotifications.where((n) => !n.isReaded!).length;

      // Phân loại thông báo
      _categorizeNotifications(allNotifications);
    });
  }

  // Phân loại thông báo thành các nhóm dựa trên loại thông báo
  void _categorizeNotifications(
      List<GeneralNotificationsModel> allNotifications) {
    likeNotifications.value = allNotifications
        .where((n) => n.type == "like")
        .take(notificationsPerPage)
        .toList();

    commentNotifications.value = allNotifications
        .where((n) => n.type == "comment")
        .take(notificationsPerPage)
        .toList();

    sharedNotifications.value = allNotifications
        .where((n) => n.type == "share")
        .take(notificationsPerPage)
        .toList();
  }

  // Đánh dấu tất cả thông báo thuộc một loại là đã đọc
  Future<void> markAllAsReadByType(String type) async {
    // Lọc thông báo theo kiểu type
    List<GeneralNotificationsModel> notificationsToMarkAsRead;
    if (type == "like") {
      notificationsToMarkAsRead =
          likeNotifications.where((n) => !n.isReaded!).toList();
    } else if (type == "comment") {
      notificationsToMarkAsRead =
          commentNotifications.where((n) => !n.isReaded!).toList();
    } else if (type == "share") {
      notificationsToMarkAsRead =
          sharedNotifications.where((n) => !n.isReaded!).toList();
    } else {
      return; // Không làm gì nếu type không hợp lệ
    }

    // Cập nhật Firestore cho từng thông báo chưa đọc
    WriteBatch batch = _firestore.batch();
    for (var notification in notificationsToMarkAsRead) {
      batch.update(
        _firestore.collection("notifications").doc(notification.id),
        {"isReaded": true},
      );
    }
    await batch.commit();

    // Cập nhật trạng thái local
    for (var n in notificationsToMarkAsRead) {
      n.isReaded = true;
    }
    unisReadedCount.value = notifications.where((n) => !n.isReaded!).length;

    // Cập nhật lại danh sách các thông báo đã phân loại
    _categorizeNotifications(notifications);
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection("notifications")
        .doc(notificationId)
        .update({"isReaded": true});

    // Cập nhật trạng thái local
    var index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index].isReaded = true;
      unisReadedCount.value = notifications.where((n) => !n.isReaded!).length;
      _categorizeNotifications(notifications);
    }
  }

  // Phân trang để lấy thêm thông báo
  Future<void> loadMoreNotifications() async {
    if (lastDocument == null) return; // Không có thông báo mới hơn

    final snapshot = await _firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .startAfterDocument(lastDocument!)
        .limit(notificationsPerPage)
        .get();

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      var moreNotifications = snapshot.docs
          .map((doc) => GeneralNotificationsModel.fromJson(doc.data()))
          .toList();

      // Thêm thông báo mới vào danh sách và cập nhật
      notifications.addAll(moreNotifications);
      unisReadedCount.value = notifications.where((n) => !n.isReaded!).length;
      _categorizeNotifications(notifications);
    }
  }

  // Hàm tự động xóa các thông báo cũ hơn 7 ngày
  Future<void> removeOldNotifications() async {
    // Tính toán thời điểm 7 ngày trước
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    // Lọc các thông báo có timestamp cũ hơn 7 ngày và giới hạn số lượng xử lý mỗi lần
    final oldNotifications = await _firestore
        .collection("notifications")
        .where("timestamp", isLessThan: sevenDaysAgo)
        .limit(50) // Giới hạn số lượng để giảm tải
        .get();

    // Xóa các thông báo đã lọc
    if (oldNotifications.docs.isNotEmpty) {
      WriteBatch batch = _firestore.batch();
      for (var doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
