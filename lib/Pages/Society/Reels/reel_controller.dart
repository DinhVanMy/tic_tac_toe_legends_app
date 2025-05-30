import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Models/Functions/compress_image_function.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/reel_model.dart';
import 'package:uuid/uuid.dart';
import '../../../Models/user_model.dart';
import '../../../Configs/messages.dart';

class ReelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenReels;
  final ImagePicker picker = ImagePicker();
  DocumentSnapshot? lastDocument;

  var reelsList = <ReelModel>[].obs;
  RxBool isLiked = false.obs;
  RxBool isFetching = false.obs;
  int pageSize = 3;
  RxBool showLikeAnimation = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialReels();
    listenToReelChanges();
  }

  Future<void> fetchInitialReels() async {
    reelsList.clear();
    if (isFetching.value) return;
    isFetching.value = true;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reels')
          .orderBy('createdAt', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        reelsList.value = snapshot.docs.map((doc) {
          return ReelModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      errorMessage("Error fetching reels: $e");
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> fetchMoreReels() async {
    try {
      Query query = _firestore
          .collection('reels')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize);
      QuerySnapshot snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        var newReels = snapshot.docs.map((doc) {
          return ReelModel.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
        var uniqueNewReels = newReels.where((newReel) =>
            !reelsList.any((reel) => reel.reelId == newReel.reelId));
        reelsList.addAll(uniqueNewReels);
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null;
      }
    } catch (e) {
      errorMessage("Error fetching more reels: $e");
    }
  }

  void listenToReelChanges() {
    subscriptionListenReels = _firestore
        .collection('reels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        var newReel =
            ReelModel.fromJson(change.doc.data() as Map<String, dynamic>);
        if (change.type == DocumentChangeType.added) {
          if (!reelsList.any((reel) => reel.reelId == newReel.reelId)) {
            reelsList.insert(0, newReel);
          }
        } else if (change.type == DocumentChangeType.modified) {
          int index =
              reelsList.indexWhere((reel) => reel.reelId == change.doc.id);
          if (index != -1) {
            reelsList[index] = newReel;
          }
        } else if (change.type == DocumentChangeType.removed) {
          reelsList.removeWhere((reel) => reel.reelId == change.doc.id);
        }
      }
    });
  }

  Future<void> createReel({
    required String videoUrl,
    required UserModel user,
    required String description,
    List<String>? taggedUserIds,
    XFile? imagePath,
  }) async {
    var uuid = const Uuid();
    String reelId = uuid.v4();
    String? thumbnailUrl;
    if (imagePath == null) {
      thumbnailUrl =
          await CompressImageFunction.generateThumbnailBase64(videoUrl);
    } else {
      thumbnailUrl = await _getUrlVideo(imagePath);
    }
    ReelModel newReel = ReelModel(
      reelId: reelId,
      reelUser: user,
      videoUrl: videoUrl,
      description: description,
      thumbnailUrl: thumbnailUrl ?? "",
      taggedUserIds: taggedUserIds,
      createdAt: DateTime.now(),
      likedList: [],
      commentCount: 0,
      shareCount: 0,
      isNotified: true,
      privacy: "public",
    );

    try {
      await _firestore
          .collection('reels')
          .doc(reelId)
          .set(newReel.toJson())
          .catchError((e) => errorMessage(e));
      successMessage("Reel created with ID: $reelId");
    } catch (e) {
      errorMessage("Failed to create reel: ${e.toString()}");
    }
  }

  Future<String?> _getUrlVideo(XFile? thumbnailUrl) async {
    if (thumbnailUrl != null) {
      List<int> imageBytes = await thumbnailUrl.readAsBytes();
      String? base64String = base64Encode(imageBytes);

      // Kiểm tra kích thước của chuỗi Base64
      int base64Size = CompressImageFunction.calculateBase64Size(base64String);
      if (base64Size > 999999) {
        errorMessage("Please pick a image which is lighter than 1 mega byte");
        return null;
      }
      return base64String;
    } else {
      return null;
    }
  }

  Future<void> deleteReel(
      {required ReelModel reel, required UserModel user}) async {
    try {
      if (reel.reelUser!.id == user.id) {
        await _firestore
            .collection('reels')
            .doc(reel.reelId)
            .delete()
            .catchError((e) => errorMessage(e));
        successMessage("Reel deleted");
      } else {
        errorMessage("You don't have permission to delete this post.");
      }
    } catch (e) {
      errorMessage("Error deleting reel: $e");
    }
  }

  Future<void> likeReel(String reelId, String userId) async {
    DocumentReference reelRef = _firestore.collection('reels').doc(reelId);
    await reelRef.update({
      'likedList': FieldValue.arrayUnion([userId])
    }).catchError((e) => errorMessage(e));
  }

  Future<void> unlikeReel(String reelId, String userId) async {
    DocumentReference reelRef = _firestore.collection('reels').doc(reelId);
    await reelRef.update({
      'likedList': FieldValue.arrayRemove([userId])
    }).catchError((e) => errorMessage(e));
  }

  RxBool isLikedReel(String userId, String reelId) {
    final reel = reelsList.firstWhereOrNull((reel) => reel.reelId == reelId);
    if (reel == null || reel.likedList == null) {
      return false.obs;
    }
    return reel.likedList!.contains(userId).obs;
  }

  Future<void> incrementSharedCount(
      ReelModel reelModel, UserModel userModel) async {
    DocumentReference postRef =
        _firestore.collection('reels').doc(reelModel.reelId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);
      if (postSnapshot.exists) {
        int currentShareCount = postSnapshot['shareCount'] ?? 0;
        transaction.update(postRef, {'shareCount': currentShareCount + 1});
      }
    });

    // if (postModel.isNotified != null && postModel.isNotified == true) {
    //   await _notificationAddFunctions.createShareNotification(
    //     senderId: userModel.id!,
    //     senderModel: userModel,
    //     receiverId: postModel.postUser!.id!,
    //     postId: postModel.postId!,
    //   );
    // }
  }

  @override
  void onClose() {
    subscriptionListenReels.cancel();
    super.onClose();
  }
}
