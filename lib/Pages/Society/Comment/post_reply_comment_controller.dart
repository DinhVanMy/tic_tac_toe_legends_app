import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_model.dart';
import 'package:uuid/uuid.dart';

class PostReplyCommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenComment;

  RxList<CommentModel> subCommentsList = <CommentModel>[].obs;
  final int commentsPerPage = 1; // Số sub-comments tải mỗi lần cho pagination
  DocumentSnapshot? lastDocument; // Để theo dõi pagination
  bool isFetching = false;

  final String postId; // ID của bài viết
  final String commentId; // ID của comment chính
  PostReplyCommentController(this.postId, this.commentId);

  @override
  void onInit() {
    super.onInit();
    fetchSubComments(); // Lắng nghe sub-comments ngay từ khi init
    listenToSubComments();
  }

  // Lấy danh sách sub-comments theo pagination
  Future<void> fetchSubComments({bool isPagination = false}) async {
    if (isFetching) return;
    isFetching = true;

    try {
      Query query = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .orderBy('createdAt', descending: true)
          .limit(commentsPerPage);

      // Nếu đang pagination, bắt đầu từ document cuối cùng đã lấy
      if (isPagination && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();

      // Cập nhật document cuối để tiếp tục pagination
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      // Nếu không phải là pagination, clear danh sách trước khi thêm mới
      if (!isPagination) {
        subCommentsList.clear();
      }

      // Thêm vào danh sách subCommentsList
      subCommentsList.addAll(
        snapshot.docs.map((doc) {
          return CommentModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList(),
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
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // Thêm bình luận mới vào đầu danh sách
          subCommentsList.insert(0,
              CommentModel.fromJson(change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          // Cập nhật bình luận nếu có thay đổi
          int index = subCommentsList
              .indexWhere((comment) => comment.id == change.doc.id);
          if (index != -1) {
            subCommentsList[index] = CommentModel.fromJson(
                change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Xóa bình luận nếu bị xóa khỏi Firestore
          subCommentsList.removeWhere((comment) => comment.id == change.doc.id);
        }
      }
    });
  }

  // Thêm sub-comment
  Future<void> addSubComment(
      {required String content,
      String? gifUrl,
      List<String>? taggedUserIds,
      required UserModel currentUser}) async {
    try {
      var uuid = const Uuid();
      String subCommentId = uuid.v4();
      CommentModel newSubComment = CommentModel(
        id: commentId,
        postId: commentId,
        gif: gifUrl,
        content: content,
        commentUser: currentUser,
        createdAt: DateTime.now(),
        taggedUserIds: taggedUserIds,
      );
      DocumentReference subCommentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .doc(subCommentId);

      await subCommentRef
          .set(newSubComment.toJson())
          .catchError((e) => errorMessage(e));

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      }).catchError((e) => errorMessage(e));
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'countReplies': FieldValue.increment(1),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      throw Exception("Error adding sub-comment: $e");
    }
  }

  Future<void> likeSubComment(String subCommentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .doc(subCommentId);

    await commentRef.update({
      'likedList': FieldValue.arrayUnion([userId]) // Thêm userId vào likedList
    }).catchError((e) => errorMessage(e));
  }

  // Hàm xóa userId khỏi likedList khi unlike
  Future<void> unlikeSubComment(String subCommentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('subComments')
        .doc(subCommentId);

    await commentRef.update({
      'likedList': FieldValue.arrayRemove([userId]) // Xóa userId khỏi likedList
    }).catchError((e) => errorMessage(e));
  }

  RxBool isLikedSubComment(String userId, String subCommentId) {
    // Tìm bài viết theo postId
    final comment = subCommentsList
        .firstWhereOrNull((subComment) => subComment.id == subCommentId);

    // Nếu không tìm thấy post hoặc likedList là null, trả về false
    if (comment == null || comment.likedList == null) {
      return false.obs;
    }

    // Kiểm tra xem userId có nằm trong likedList của post không
    final isLiked = comment.likedList!.contains(userId);

    return isLiked.obs; // Trả về RxBool phản ánh trạng thái "liked"
  }

  // Hàm xóa bình luận
  Future<void> deleteComment(String subCommentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('subComments')
          .doc(subCommentId)
          .delete()
          .catchError((e) => errorMessage(e));
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      }).catchError((e) => errorMessage(e));
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'countReplies': FieldValue.increment(-1),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      errorMessage("Error deleting comment: $e");
    }
  }

  // Hàm để tải thêm sub-comments cho pagination
  Future<void> loadMoreSubComments() async {
    await fetchSubComments(isPagination: true);
  }

  @override
  void onClose() {
    subscriptionListenComment.cancel();
    super.onClose();
  }
}
