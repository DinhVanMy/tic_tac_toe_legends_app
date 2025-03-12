import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/compress_image_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/notification_add_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/post_polls_model.dart';
import 'package:uuid/uuid.dart';

class PostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenPosts;
  late final ScrollController scrollController;
  final ImagePicker picker = ImagePicker();
  DocumentSnapshot? lastDocument;
  late final NotificationAddFunctions _notificationAddFunctions;

  final List<String> options = ["Favoritest", "Newest", "Oldest"];
  var selectedOption = 'Newest'.obs;
  var postsList = <PostModel>[].obs;
  RxBool isLiked = false.obs;

  RxBool isFetching = false.obs;
  int pageSize = 2;

  @override
  void onInit() {
    super.onInit();
    _notificationAddFunctions = NotificationAddFunctions(firestore: _firestore);
    scrollController = ScrollController();
    fetchInitialPosts();
    listenToPostChanges();
    ever(selectedOption, (_) => fetchFilteredPosts());
  }

  // Hàm tải dữ liệu trang đầu tiên
  Future<void> fetchInitialPosts() async {
    postsList.clear();
    if (isFetching.value) return; // Nếu đang tải, bỏ qua
    isFetching.value = true;
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
      isFetching.value = false;
    }
  }

  Future<void> fetchFilteredPosts() async {
    postsList.clear();
    if (isFetching.value) return;
    isFetching.value = true;
    try {
      Query query = _firestore.collection('posts').limit(pageSize);

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
        postsList.value = snapshot.docs.map((doc) {
          return PostModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      errorMessage("Error fetching posts: $e");
    } finally {
      isFetching.value = false;
    }
  }

  // Hàm tải thêm bình luận
  Future<void> fetchMoreFilteredPosts() async {
    if (isFetching.value || lastDocument == null) return;
    isFetching.value = true;

    try {
      // Khởi tạo query và sắp xếp trước
      Query query = _firestore.collection('posts');

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
        var newPosts = snapshot.docs.map((doc) {
          return PostModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        var uniqueNewPosts = newPosts.where((newPost) =>
            !postsList.any((post) => post.postId == newPost.postId));
        postsList.addAll(uniqueNewPosts);
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null;
      }
    } catch (e) {
      errorMessage("Error fetching more posts: $e");
    } finally {
      isFetching.value = false;
    }
  }

  // Lắng nghe các thay đổi của bài viết theo thời gian thực
  void listenToPostChanges() {
    subscriptionListenPosts = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      // if (isFetching.value) return;
      for (var change in snapshot.docChanges) {
        var newPost =
            PostModel.fromJson(change.doc.data() as Map<String, dynamic>);
        if (change.type == DocumentChangeType.added) {
          if (!postsList.any((post) => post.postId == newPost.postId)) {
            postsList.insert(0, newPost);
          }
        } else if (change.type == DocumentChangeType.modified) {
          int index =
              postsList.indexWhere((post) => post.postId == change.doc.id);
          if (index != -1) {
            postsList[index] = newPost;
          }
        } else if (change.type == DocumentChangeType.removed) {
          postsList.removeWhere((post) => post.postId == change.doc.id);
        }
      }
    });
  }

  Future<void> createPost({
    required String content,
    required UserModel user,
    List<String>? backgroundPost,
    List<XFile>? imageFiles,
    List<String>? taggedUserIds,
    required String privacy,
    String? gifUrl,
    PostPollsModel? postPollsModel,
  }) async {
    var uuid = const Uuid();
    String postId = uuid.v4();

    List<String> base64ImageList =
        await CompressImageFunction.processImages(imageFiles);

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
      shareCount: 0,
      commentCount: 0,
      createdAt: DateTime.now(),
      taggedUserIds: taggedUserIds,
      privacy: privacy,
      isNotified: true,
      gif: gifUrl,
      postPolls: postPollsModel,
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

    List<String> base64ImageList =
        await CompressImageFunction.processImages(imageFiles);

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

  Future<bool> onVoteFunction({
    required PollOption pollOption,
    required int newTotalVotes,
    required PostPollsModel postPolls,
    required String postId,
    required String userId,
  }) async {
    // Kiểm tra nếu user đã vote
    if (postPolls.voterList?.contains(userId) ?? false) {
      return false;
    }

    // Tìm option mà user đã vote
    OptionalPolls? option = postPolls.options?.firstWhere(
        (opt) => opt.id.toString() == pollOption.id,
        orElse: () => OptionalPolls());

    if (option == null) return false;

    // Cập nhật số lượng votes và danh sách user đã vote
    option.votes = (option.votes ?? 0) + 1;
    option.votedUserIds ??= [];
    option.votedUserIds!.add(userId);

    // Thêm user vào danh sách voterList của poll
    postPolls.voterList ??= [];
    postPolls.voterList!.add(userId);

    // Cập nhật dữ liệu trên Firestore
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'postPolls': postPolls.toJson()});
      return true;
    } catch (e) {
      errorMessage('Error updating vote: $e');
      return false;
    }
  }

  Future<void> undoVoteFunction({
    required PostPollsModel postPolls,
    required String postId,
    required String userId,
  }) async {
    // postPolls.voterList ??= [];
    // postPolls.options?.forEach((option) {
    //   option.votedUserIds ??= [];
    // });

    // Kiểm tra nếu userId nằm trong voterList
    if (!(postPolls.voterList?.contains(userId) ?? false)) return;

    // Tìm tùy chọn mà user đã vote
    OptionalPolls? votedOption = postPolls.options?.firstWhere(
      (option) => option.votedUserIds?.contains(userId) ?? false,
      orElse: () => OptionalPolls(),
    );

    if (votedOption == null) return;

    // Loại bỏ userId khỏi voterList và votedUserIds
    postPolls.voterList?.remove(userId);
    votedOption.votedUserIds?.remove(userId);
    votedOption.votes =
        (votedOption.votes ?? 1) > 0 ? votedOption.votes! - 1 : 0;

    // Cập nhật trên Firestore
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'postPolls': postPolls.toJson()});
    } catch (e) {
      debugPrint("Undo vote failed: $e");
    }
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

  Future<void> likePost(PostModel postModel, UserModel userModel) async {
    DocumentReference postRef =
        _firestore.collection('posts').doc(postModel.postId);

    await postRef.update({
      'likedList':
          FieldValue.arrayUnion([userModel.id]) // Thêm userId vào likedList
    }).catchError((e) => errorMessage(e));

    if (postModel.isNotified != null && postModel.isNotified == true) {
      await _notificationAddFunctions.createLikeNotification(
        senderId: userModel.id!,
        senderModel: userModel,
        receiverId: postModel.postUser!.id!,
        postId: postModel.postId!,
      );
    }
  }

  // Hàm xóa userId khỏi likedList khi unlike
  Future<void> unlikePost(String postId, String userId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);

    await postRef.update({
      'likedList': FieldValue.arrayRemove([userId]) // Xóa userId khỏi likedList
    }).catchError((e) => errorMessage(e));
  }

  RxBool isLikedPost(String userId, String postId) {
    // Tìm bài viết theo postId
    final post = postsList.firstWhereOrNull((post) => post.postId == postId);

    // Nếu không tìm thấy post hoặc likedList là null, trả về false
    if (post == null || post.likedList == null) {
      return false.obs;
    }

    // Kiểm tra xem userId có nằm trong likedList của post không
    final isLiked = post.likedList!.contains(userId);

    return isLiked.obs; // Trả về RxBool phản ánh trạng thái "liked"
  }

  Future<void> incrementSharedCount(
      PostModel postModel, UserModel userModel) async {
    DocumentReference postRef =
        _firestore.collection('posts').doc(postModel.postId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        int currentShareCount = postSnapshot['shareCount'] ?? 0;
        transaction.update(postRef, {'shareCount': currentShareCount + 1});
      }
    });

    if (postModel.isNotified != null && postModel.isNotified == true) {
      await _notificationAddFunctions.createShareNotification(
        senderId: userModel.id!,
        senderModel: userModel,
        receiverId: postModel.postUser!.id!,
        postId: postModel.postId!,
      );
    }
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
    await fetchFilteredPosts();
  }

  void updateSelectedOption(String value) {
    selectedOption.value = value;
  }

  var unreadCount = 0.obs;
  // Hàm để lắng nghe số lượng thông báo chưa đọc
  void listenToUnreadNotifications({required String userId}) {
    FirebaseFirestore.instance
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .where("isReaded", isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      unreadCount.value =
          snapshot.docs.length; // Cập nhật số lượng thông báo chưa đọc
    });
  }

  @override
  void onClose() {
    subscriptionListenPosts.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
