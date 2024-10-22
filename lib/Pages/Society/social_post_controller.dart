import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';
import 'package:uuid/uuid.dart';

class PostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenPosts;
  late final ScrollController scrollController;
  final ImagePicker picker = ImagePicker();
  DocumentSnapshot? lastDocument;

  var postsList = <PostModel>[].obs;
  RxBool isLiked = false.obs;

  bool isFetching = false;
  int pageSize = 2;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    fetchInitialPosts();
    listenToPostChanges();
  }

  // Hàm tải dữ liệu trang đầu tiên
  Future<void> fetchInitialPosts() async {
    if (isFetching) return; // Nếu đang tải, bỏ qua
    isFetching = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      // Cập nhật danh sách posts và lastDocument
      if (snapshot.docs.isNotEmpty) {
        postsList.value = snapshot.docs.map((doc) {
          return PostModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      errorMessage("Error fetching posts: $e");
    } finally {
      isFetching = false;
    }
  }

  // Hàm tải thêm bài viết khi cuộn xuống dưới (pagination)
  Future<void> fetchMorePosts() async {
    if (isFetching || lastDocument == null) {
      return;
    }
    isFetching = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument!) // Tiếp tục sau tài liệu cuối cùng
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var newPosts = snapshot.docs.map((doc) {
          return PostModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        postsList.addAll(newPosts); // Thêm bài viết mới vào danh sách
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null; // Không còn bài viết để tải thêm
      }
    } catch (e) {
      errorMessage("Error fetching more posts: $e");
    } finally {
      isFetching = false;
    }
  }

  // Lắng nghe các thay đổi của bài viết theo thời gian thực
  void listenToPostChanges() {
    subscriptionListenPosts = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // Bài viết mới được thêm
          postsList.insert(
              0, PostModel.fromJson(change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          // Bài viết được cập nhật
          int index =
              postsList.indexWhere((post) => post.postId == change.doc.id);
          if (index != -1) {
            postsList[index] =
                PostModel.fromJson(change.doc.data() as Map<String, dynamic>);
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Bài viết bị xóa
          postsList.removeWhere((post) => post.postId == change.doc.id);
        }
      }
    });
  }

  Future<void> createPost({
    required String content,
    required UserModel user,
    List<Color>? backgroundPost,
    List<XFile>? imageFiles,
    List<String>? taggedUserIds,
    required String privacy,
  }) async {
    var uuid = const Uuid();
    String postId = uuid.v4();

    List<String> base64ImageList = await _processImages(imageFiles);

    if (base64ImageList.isEmpty && imageFiles != null) {
      return;
    }

    // Tạo post mới với thông tin đã chuẩn bị
    PostModel newPost = PostModel(
      postId: postId,
      postUser: user,
      content: content,
      backgroundPost: backgroundPost,
      imageUrls: base64ImageList.isEmpty ? null : base64ImageList,
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      createdAt: DateTime.now(),
      taggedUserIds: taggedUserIds,
      privacy: privacy,
    );

    // Cập nhật vào Firestore
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .set(newPost.toJson())
          .catchError((e) => errorMessage(e));
      successMessage("Post created with ID: $postId");
    } catch (e) {
      errorMessage("Failed to create post: ${e.toString()}");
    }
  }

  // Hàm cập nhật post
  Future<void> updatePost(
    String postId, {
    String? content,
    List<Color>? backgroundPost,
    List<XFile>? imageFiles,
    List<String>? taggedUserIds,
    String? privacy,
  }) async {
    Map<String, dynamic> updatedFields = {};

    if (content != null) {
      updatedFields['content'] = content;
    }
    if (backgroundPost != null) {
      updatedFields['backgroundPost'] = backgroundPost;
    }
    if (taggedUserIds != null) {
      updatedFields['taggedUserIds'] = taggedUserIds;
    }
    if (privacy != null) {
      updatedFields['privacy'] = privacy;
    }

    List<String> base64ImageList = await _processImages(imageFiles);

    if (base64ImageList.isEmpty && imageFiles != null) {
      return;
    }

    if (updatedFields.isNotEmpty) {
      try {
        await _firestore
            .collection('posts')
            .doc(postId)
            .update(updatedFields)
            .catchError((e) => errorMessage(e));
        successMessage("Post updated with ID: $postId");
      } catch (e) {
        errorMessage("Failed to update post: ${e.toString()}");
      }
    } else {
      errorMessage("No fields to update");
    }
  }

  Future<List<String>> _processImages(List<XFile>? imageFiles) async {
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

  int calculateBase64Size(String base64String) {
    int padding = base64String.endsWith('==')
        ? 2
        : base64String.endsWith('=')
            ? 1
            : 0;
    int size = (base64String.length * 3 / 4).floor() - padding;
    return size; // Kích thước tính bằng byte
  }

  // Hàm xoá post
  Future<void> deletePost(
      {required PostModel post, required UserModel user}) async {
    if (post.postUser!.id == user.id) {
      await _firestore
          .collection('posts')
          .doc(post.postId)
          .delete()
          .catchError((e) => errorMessage(e));
      successMessage("Post deleted with ID: ${post.postId}");
    } else {
      errorMessage("You don't have permission to delete this post.");
    }
  }

  // Hàm tăng/giảm lượt like
  Future<void> toggleLikePost(String postId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        int currentLikeCount = postSnapshot['likeCount'] ?? 0;
        int updatedLikeCount =
            !isLiked.value ? currentLikeCount - 1 : currentLikeCount + 1;
        transaction.update(postRef, {'likeCount': updatedLikeCount});
      }
    });
  }

  // Hàm tăng lượt bình luận
  Future<void> incrementCommentCount(String postId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        int currentCommentCount = postSnapshot['commentCount'] ?? 0;
        transaction.update(postRef, {'commentCount': currentCommentCount + 1});
      }
    });
  }

  Future<void> incrementSharedCount(String postId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        int currentShareCount = postSnapshot['shareCount'] ?? 0;
        transaction.update(postRef, {'shareCount': currentShareCount + 1});
      }
    });
  }

  Future<List<XFile>?> pickMultiImages() async {
    final List<XFile> images = await picker.pickMultiImage(
      maxHeight: 240,
      maxWidth: 320,
      limit: 5,
    );
    return images;
  }

  Future<XFile?> pickImageCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 240,
      maxWidth: 320,
    );
    return image;
  }

  Future<void> scrollToTop() async {
    await scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
    await fetchInitialPosts();
  }

  String timeAgo({required DateTime now, required DateTime createdAt}) {
    Duration difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'a few seconds ago'; // Dưới 1 phút
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""} ago'; // Dưới 1 giờ
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago'; // Dưới 1 ngày
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago'; // Dưới 1 tuần
    }
    if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? "s" : ""} ago'; // Dưới 1 tháng
    }
    if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? "s" : ""} ago'; // Dưới 1 năm
    }

    int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? "s" : ""} ago'; // Lâu hơn 1 năm
  }

  @override
  void onClose() {
    subscriptionListenPosts.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
