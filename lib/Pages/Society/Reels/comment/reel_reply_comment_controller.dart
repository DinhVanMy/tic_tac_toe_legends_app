import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_model.dart';
import 'package:uuid/uuid.dart';

class ReelReplyCommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenComment;

  RxList<CommentModel> subCommentsList = <CommentModel>[].obs;
  final int commentsPerPage = 1; // Số sub-comments tải mỗi lần cho pagination
  DocumentSnapshot? lastDocument; // Để theo dõi pagination
  bool isFetching = false;

  final String reelId; // ID của reel
  final String commentId; // ID của comment chính
  ReelReplyCommentController(this.reelId, this.commentId);

  @override
  void onInit() {
    super.onInit();
    fetchSubComments(); // Lấy danh sách sub-comments ngay từ khi init
    listenToSubComments(); // Lắng nghe thay đổi thời gian thực
  }

  // Lấy danh sách sub-comments theo pagination
  Future<void> fetchSubComments({bool isPagination = false}) async {
    if (isFetching) return;
    isFetching = true;

    try {
      Query query = _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .orderBy('createdAt', descending: true)
          .limit(commentsPerPage);

      if (isPagination && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      if (!isPagination) {
        subCommentsList.clear();
      }

      subCommentsList.addAll(
        snapshot.docs.map((doc) => CommentModel.fromJson(doc.data() as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      throw Exception("Error fetching sub-comments: $e");
    } finally {
      isFetching = false;
    }
  }

  // Lắng nghe sub-comments theo thời gian thực
  void listenToSubComments() {
    subscriptionListenComment = _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          subCommentsList.insert(0, CommentModel.fromJson(change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          int index = subCommentsList.indexWhere((comment) => comment.id == change.doc.id);
          if (index != -1) {
            subCommentsList[index] = CommentModel.fromJson(change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          subCommentsList.removeWhere((comment) => comment.id == change.doc.id);
        }
      }
    });
  }

  // Thêm sub-comment
  Future<void> addSubComment({
    required String content,
    String? gifUrl,
    List<String>? taggedUserIds,
    required UserModel currentUser,
  }) async {
    try {
      var uuid = const Uuid();
      String subCommentId = uuid.v4();
      CommentModel newSubComment = CommentModel(
        id: subCommentId, // Sử dụng ID mới cho sub-comment
        postId: reelId, // Gán reelId vào postId để tái sử dụng CommentModel
        gif: gifUrl,
        content: content,
        commentUser: currentUser,
        createdAt: DateTime.now(),
        taggedUserIds: taggedUserIds,
      );

      DocumentReference subCommentRef = _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .doc(subCommentId);

      await subCommentRef.set(newSubComment.toJson()).catchError((e) => errorMessage(e));

      await _firestore.collection('reels').doc(reelId).update({
        'commentCount': FieldValue.increment(1),
      }).catchError((e) => errorMessage(e));

      await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .update({
        'countReplies': FieldValue.increment(1),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      throw Exception("Error adding sub-comment: $e");
    }
  }

  // Like sub-comment
  Future<void> likeSubComment(String subCommentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .doc(subCommentId);

    await commentRef.update({
      'likedList': FieldValue.arrayUnion([userId]),
    }).catchError((e) => errorMessage(e));
  }

  // Unlike sub-comment
  Future<void> unlikeSubComment(String subCommentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('reels')
        .doc(reelId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .doc(subCommentId);

    await commentRef.update({
      'likedList': FieldValue.arrayRemove([userId]),
    }).catchError((e) => errorMessage(e));
  }

  // Kiểm tra trạng thái like của sub-comment
  RxBool isLikedSubComment(String userId, String subCommentId) {
    final comment = subCommentsList.firstWhereOrNull((subComment) => subComment.id == subCommentId);
    if (comment == null || comment.likedList == null) {
      return false.obs;
    }
    final isLiked = comment.likedList!.contains(userId);
    return isLiked.obs;
  }

  // Xóa sub-comment
  Future<void> deleteSubComment(String subCommentId) async {
    try {
      await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .doc(subCommentId)
          .delete()
          .catchError((e) => errorMessage(e));

      await _firestore.collection('reels').doc(reelId).update({
        'commentCount': FieldValue.increment(-1),
      }).catchError((e) => errorMessage(e));

      await _firestore
          .collection('reels')
          .doc(reelId)
          .collection('comments')
          .doc(commentId)
          .update({
        'countReplies': FieldValue.increment(-1),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      errorMessage("Error deleting sub-comment: $e");
    }
  }

  // Tải thêm sub-comments (pagination)
  Future<void> loadMoreSubComments() async {
    await fetchSubComments(isPagination: true);
  }

  @override
  void onClose() {
    subscriptionListenComment.cancel();
    super.onClose();
  }
}