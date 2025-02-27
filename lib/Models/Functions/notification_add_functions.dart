import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Models/general_notifications_model.dart';
import 'package:uuid/uuid.dart';

class NotificationAddFunctions {
  final FirebaseFirestore firestore;
  NotificationAddFunctions({required this.firestore});

  // Hàm tạo thông báo tổng quát
  Future<void> _createNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
    required String message,
    required String type,
    String? roomId,
    String? postId,
    String? commentId,
  }) async {
    try {
      var uuid = const Uuid();
      String notifyId = uuid.v4();
      final docRef = firestore.collection('notifications').doc(notifyId);

      final notification = GeneralNotificationsModel(
        id: notifyId,
        senderId: senderId,
        senderModel: senderModel,
        receiverId: receiverId,
        message: message,
        type: type,
        timestamp: Timestamp.now(),
        isReaded: false,
        roomId: roomId,
        postId: postId,
        commentId: commentId,
      );

      await docRef
          .set(notification.toJson())
          .catchError((e) => errorMessage(e));
    } catch (e) {
      errorMessage('Error creating notification: $e');
    }
  }

  // Hàm tạo thông báo like
  Future<void> createLikeNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
    required String postId,
  }) async {
    await _createNotification(
      senderId: senderId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: "${senderModel.name} liked your post.",
      type: "like",
      postId: postId,
    );
  }

  // Hàm tạo thông báo comment
  Future<void> createCommentNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
    required String postId,
    required String commentId,
    required String comment,
  }) async {
    await _createNotification(
      senderId: senderId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: "${senderModel.name} commented on your post '$comment'",
      type: "comment",
      postId: postId,
      commentId: commentId,
    );
  }

  Future<void> createReelCommentNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
    required String reelId,
    required String commentId,
    required String comment,
  }) async {
    await _createNotification(
      senderId: senderId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: "${senderModel.name} commented on your reel '$comment'",
      type: "comment",
      postId: reelId,
      commentId: commentId,
    );
  }

  // Hàm tạo thông báo follow
  Future<void> createFollowNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
  }) async {
    await _createNotification(
      senderId: senderId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: "${senderModel.name} đã theo dõi bạn.",
      type: "follow",
    );
  }

  // Hàm tạo thông báo tin nhắn
  Future<void> createShareNotification({
    required String senderId,
    required UserModel senderModel,
    required String receiverId,
    required String postId,
  }) async {
    await _createNotification(
      senderId: senderId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: "${senderModel.name} shared on a your post.",
      type: "share",
      postId: postId,
    );
  }

  Future<dynamic> getFieldDataFromCollection ({
    required String collectionPath,
    required String docId,
    required String fieldName,
  }) async {
    try {
      final docSnapshot =
          await firestore.collection(collectionPath).doc(docId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data()![fieldName];
      } else {
        errorMessage("Document is not available");
        return null;
      }
    } catch (e) {
      errorMessage("Error fetching field data: $e");
      return null;
    }
  }
}
