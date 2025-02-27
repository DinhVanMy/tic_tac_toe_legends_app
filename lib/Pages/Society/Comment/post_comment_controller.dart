import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/notification_add_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_model.dart';
import 'package:uuid/uuid.dart';

class PostCommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late StreamSubscription subscriptionListenComment;
  late final NotificationAddFunctions _notificationAddFunctions;
  DocumentSnapshot? lastDocument; // Tài liệu cuối cùng để phục vụ phân trang

  final List<String> options = ["Favoritest", "Newest", "Oldest"];
  var selectedOption = 'Newest'.obs;
  var commentsList = <CommentModel>[].obs;
  var isLoading = false.obs;
  int pageSize = 2;

  final String postId; // ID của bài viết mà controller này quản lý comments
  PostCommentController(this.postId);

  @override
  void onInit() {
    super.onInit();
    _notificationAddFunctions = NotificationAddFunctions(firestore: _firestore);
    fetchInitialComments();
    listenToCommentChanges();
    ever(selectedOption, (_) => fetchFilteredComments());
  }

  // Hàm tải các bình luận đầu tiên cho bài viết
  Future<void> fetchInitialComments() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        commentsList.value = snapshot.docs.map((doc) {
          return CommentModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      errorMessage("Error fetching comments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm lọc bình luận dựa trên lựa chọn
  Future<void> fetchFilteredComments() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      Query query = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .limit(pageSize);

      switch (selectedOption.value) {
        case 'Favoritest':
          query = query.orderBy('likedList', descending: true);
          break;
        case 'Newest':
          query = query.orderBy('createdAt', descending: true);
          break;
        case 'Oldest':
          query = query.orderBy('createdAt', descending: false);
          break;
      }

      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        commentsList.value = snapshot.docs.map((doc) {
          return CommentModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      errorMessage("Error fetching comments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm tải thêm bình luận
  Future<void> fetchMoreFilteredComments() async {
    if (isLoading.value || lastDocument == null) return;
    isLoading.value = true;

    try {
      // Khởi tạo query và sắp xếp trước
      Query query =
          _firestore.collection('posts').doc(postId).collection('comments');

      switch (selectedOption.value) {
        case 'Favoritest':
          query = query.orderBy('likedList', descending: true);
          break;
        case 'Newest':
          query = query.orderBy('createdAt', descending: true);
          break;
        case 'Oldest':
          query = query.orderBy('createdAt', descending: false);
          break;
      }

      // Thêm startAfterDocument sau khi orderBy
      query = query.startAfterDocument(lastDocument!).limit(pageSize);

      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var newComments = snapshot.docs.map((doc) {
          return CommentModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        commentsList.addAll(newComments);
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null;
      }
    } catch (e) {
      errorMessage("Error fetching more comments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Lắng nghe thay đổi real-time cho comments
  void listenToCommentChanges() {
    subscriptionListenComment = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // Thêm bình luận mới vào đầu danh sách
          commentsList.insert(0,
              CommentModel.fromJson(change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          // Cập nhật bình luận nếu có thay đổi
          int index =
              commentsList.indexWhere((comment) => comment.id == change.doc.id);
          if (index != -1) {
            commentsList[index] = CommentModel.fromJson(
                change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Xóa bình luận nếu bị xóa khỏi Firestore
          commentsList.removeWhere((comment) => comment.id == change.doc.id);
        }
      }
    });
  }

  // Hàm thêm bình luận mới
  Future<void> addComment(
      {required String content,
      List<String>? taggedUserIds,
      String? gifUrl,
      required String receiverId,
      required UserModel currentUser}) async {
    try {
      var uuid = const Uuid();
      String commentId = uuid.v4();
      CommentModel newComment = CommentModel(
        id: commentId,
        postId: postId,
        content: content,
        gif: gifUrl,
        commentUser: currentUser,
        createdAt: DateTime.now(),
        taggedUserIds: taggedUserIds,
      );
      DocumentReference commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      await commentRef
          .set(newComment.toJson())
          .catchError((e) => errorMessage(e));

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      }).catchError((e) => errorMessage(e));

      await _notificationAddFunctions.createCommentNotification(
        senderId: currentUser.id!,
        senderModel: currentUser,
        receiverId: receiverId,
        postId: postId,
        commentId: commentId,
        comment: content,
      );
    } catch (e) {
      errorMessage("Error adding comment: $e");
    }
  }

  // Hàm cập nhật bình luận
  Future<void> updateComment(String commentId, String newContent) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'content': newContent,
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      errorMessage("Error updating comment: $e");
    }
  }

  Future<void> likeComment(String commentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection("comments")
        .doc(commentId);

    await commentRef.update({
      'likedList': FieldValue.arrayUnion([userId]) // Thêm userId vào likedList
    }).catchError((e) => errorMessage(e));
  }

  // Hàm xóa userId khỏi likedList khi unlike
  Future<void> unlikeComment(String commentId, String userId) async {
    DocumentReference commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection("comments")
        .doc(commentId);

    await commentRef.update({
      'likedList': FieldValue.arrayRemove([userId]) // Xóa userId khỏi likedList
    }).catchError((e) => errorMessage(e));
  }

  RxBool isLikedComment(String userId, String commentId) {
    // Tìm bài viết theo postId
    final comment =
        commentsList.firstWhereOrNull((comment) => comment.id == commentId);

    // Nếu không tìm thấy post hoặc likedList là null, trả về false
    if (comment == null || comment.likedList == null) {
      return false.obs;
    }

    // Kiểm tra xem userId có nằm trong likedList của post không
    final isLiked = comment.likedList!.contains(userId);

    return isLiked.obs; // Trả về RxBool phản ánh trạng thái "liked"
  }

  // Hàm xóa bình luận
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete()
          .catchError((e) => errorMessage(e));

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      }).catchError((e) => errorMessage(e));
    } catch (e) {
      errorMessage("Error deleting comment: $e");
    }
  }

  // Hàm để cập nhật lựa chọn
  void updateSelectedOption(String value) {
    selectedOption.value = value;
  }

  // Hủy stream khi không cần thiết
  @override
  void onClose() {
    subscriptionListenComment.cancel();
    super.onClose();
  }
}
