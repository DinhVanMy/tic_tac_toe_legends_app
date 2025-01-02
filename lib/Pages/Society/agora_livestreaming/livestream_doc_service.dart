import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:uuid/uuid.dart';

class LiveStreamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Collection Reference**
  /// Đây là tham chiếu đến collection trong Firestore nơi lưu trữ các livestream.
  CollectionReference get _liveStreamCollection =>
      _firestore.collection('liveStreams');

  /// **Tạo mới một livestream**
  Future<void> createLiveStream(LiveStreamModel liveStream) async {
    try {
      // Tạo ID tự động nếu không có
      final String newStreamId =
          liveStream.streamId ?? _liveStreamCollection.doc().id;

      liveStream.streamId = newStreamId;

      await _liveStreamCollection.doc(newStreamId).set(liveStream.toJson());
    } catch (e) {
      errorMessage("Error creating live stream: $e");
      rethrow;
    }
  }

  /// **Lấy danh sách tất cả các livestream**
  Future<List<LiveStreamModel>> getAllLiveStreams() async {
    try {
      final QuerySnapshot snapshot = await _liveStreamCollection.get();
      return snapshot.docs
          .map((doc) =>
              LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage("Error fetching live streams: $e");
      rethrow;
    }
  }

  /// **Lấy thông tin một livestream theo streamId**
  Future<LiveStreamModel?> getLiveStreamById(String streamId) async {
    try {
      final DocumentSnapshot doc =
          await _liveStreamCollection.doc(streamId).get();

      if (doc.exists) {
        return LiveStreamModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      errorMessage("Error fetching live stream by ID: $e");
      rethrow;
    }
  }

  /// **Cập nhật thông tin livestream**
  Future<void> updateLiveStream(
      String streamId, LiveStreamModel liveStream) async {
    try {
      await _liveStreamCollection.doc(streamId).update(liveStream.toJson());
      print("Live stream updated successfully");
    } catch (e) {
      errorMessage("Error updating live stream: $e");
      rethrow;
    }
  }

  /// **Cập nhật một số trường của livestream**
  Future<void> updateLiveStreamFields(
      String streamId, String field, dynamic value) async {
    try {
      // Chỉ cập nhật các trường được truyền trong fieldsToUpdate
      await _liveStreamCollection.doc(streamId).update({field: value});
    } on FirebaseException catch (e) {
      // Bắt lỗi cụ thể từ Firebase
      errorMessage("Firebase error: ${e.message}");
      rethrow;
    } catch (e) {
      // Bắt các lỗi khác (nếu có)
      errorMessage("Unexpected error: $e");
      rethrow;
    }
  }

  /// **Xóa livestream**
  Future<void> deleteLiveStream(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).delete();
    } catch (e) {
      errorMessage("Error deleting live stream: $e");
      rethrow;
    }
  }

  /// **Tăng số lượt xem**
  Future<void> incrementViewerCount(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).update({
        'viewerCount': FieldValue.increment(1),
      });
    } catch (e) {
      errorMessage("Error incrementing viewer count: $e");
      rethrow;
    }
  }

  Future<void> decrementViewerCount(String streamId) async {
    try {
      await _liveStreamCollection.doc(streamId).update({
        'viewerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      errorMessage("Error decrementing viewer count: $e");
    }
  }

  /// **Thêm bình luận vào livestream**
  Future<void> addComment(
    String streamId,
    String content,
    String avtCommentUser,
    String nameCommentUser,
    String? gifUrl,
  ) async {
    try {
      var uuid = const Uuid();
      final String commentId = uuid.v4().substring(0, 12);
      final Map<String, String> comment = {
        "name": nameCommentUser,
        "photoUrl": avtCommentUser,
        "content": content,
        "createdAt": DateTime.now().toIso8601String(),
        "gif":gifUrl??"",
      };
      await _liveStreamCollection
          .doc(streamId)
          .update({'comments.$commentId': comment});
    } catch (e) {
      errorMessage("Error adding comment: $e");
      rethrow;
    }
  }

  // Future<void> addComment(
  //   String streamId,
  //   String content,
  //   String avtCommentUser,
  //   String nameCommentUser,
  // ) async {
  //   try {
  //     var uuid = const Uuid();
  //     final String commentId = uuid.v4().substring(0, 12);
  //     final Map<String, dynamic> newComment = {
  //       "name": nameCommentUser,
  //       "photoUrl": avtCommentUser,
  //       "content": content,
  //       "createdAt": DateTime.now().toIso8601String(),
  //     };

  //     final docRef = _liveStreamCollection.doc(streamId);

  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       // Lấy dữ liệu hiện tại
  //       DocumentSnapshot snapshot = await transaction.get(docRef);

  //       if (!snapshot.exists) {
  //         throw Exception("Stream with ID $streamId does not exist.");
  //       }

  //       // Lấy danh sách comments hiện tại (Map)
  //       Map<String, dynamic> comments = snapshot.get("comments") ?? {};

  //       // Chuyển Map thành List để dễ xử lý
  //       List<MapEntry<String, dynamic>> commentList = comments.entries.toList();

  //       // Nếu đã đạt đến giới hạn, xóa comment cũ nhất
  //       if (commentList.length >= 100) {
  //         commentList.removeAt(0);
  //       }

  //       // Thêm comment mới vào danh sách
  //       commentList.add(MapEntry(commentId, newComment));

  //       // Chuyển danh sách trở lại Map và cập nhật Firestore
  //       Map<String, dynamic> updatedComments = Map.fromEntries(commentList);
  //       transaction.update(docRef, {"comments": updatedComments});
  //     });
  //   } catch (e) {
  //     errorMessage("Error adding comment: $e");
  //     rethrow;
  //   }
  // }

  Future<void> addEmotes(String streamId, String emote) async {
    final docRef = _liveStreamCollection.doc(streamId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Lấy document hiện tại
      DocumentSnapshot snapshot = await transaction.get(docRef);

      // Lấy danh sách messages hiện tại
      List<dynamic> messages = snapshot.get('emotes') ?? [];

      // Thêm message mới
      if (messages.length >= 30) {
        messages.removeAt(0); // Xóa message cũ nhất
      }
      messages.add(emote); // Thêm message mới

      // Cập nhật lại danh sách
      transaction.update(docRef, {'emotes': messages});
    }).catchError((e) {
      errorMessage("Failed to add emote: $e");
    });
  }

  /// **Nghe cập nhật realtime cho một livestream**
  Stream<LiveStreamModel?> streamLiveStreamUpdates(String streamId) {
    return _liveStreamCollection.doc(streamId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return LiveStreamModel.fromJson(
            snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
}
