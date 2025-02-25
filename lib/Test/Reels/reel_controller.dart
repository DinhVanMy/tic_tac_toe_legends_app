import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe_gameapp/Models/Functions/compress_image_function.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_model.dart';
import 'package:uuid/uuid.dart';
import '../../Models/user_model.dart';
import '../../Configs/messages.dart';

class ReelController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription subscriptionListenReels;
  final ImagePicker picker = ImagePicker();
  DocumentSnapshot? lastDocument;

  var reelsList = <ReelModel>[].obs;
  RxBool isLiked = false.obs;
  bool isFetching = false;
  int pageSize = 3;

  @override
  void onInit() {
    super.onInit();
    fetchInitialReels();
    listenToReelChanges();
  }

  Future<void> fetchInitialReels() async {
    reelsList.clear();
    if (isFetching) return;
    isFetching = true;
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
      isFetching = false;
    }
  }

  Future<void> fetchMoreReels() async {
    if (isFetching || lastDocument == null) return;
    isFetching = true;
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
        reelsList.addAll(newReels);
        lastDocument = snapshot.docs.last;
      } else {
        lastDocument = null;
      }
    } catch (e) {
      errorMessage("Error fetching more reels: $e");
    } finally {
      isFetching = false;
    }
  }

  void listenToReelChanges() {
    subscriptionListenReels = _firestore
        .collection('reels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          reelsList.insert(
              0, ReelModel.fromJson(change.doc.data() as Map<String, dynamic>));
        } else if (change.type == DocumentChangeType.modified) {
          int index =
              reelsList.indexWhere((reel) => reel.reelId == change.doc.id);
          if (index != -1) {
            reelsList[index] =
                ReelModel.fromJson(change.doc.data() as Map<String, dynamic>);
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
    XFile? thumbnailUrl,
    List<String>? taggedUserIds,
  }) async {
    var uuid = const Uuid();
    String reelId = uuid.v4();
    final String? thumbnailUrl64 = await _getUrlVideo(thumbnailUrl);

    ReelModel newReel = ReelModel(
      reelId: reelId,
      reelUser: user,
      videoUrl: videoUrl,
      description: description,
      thumbnailUrl: thumbnailUrl64,
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
      {required String reelId, required UserModel user}) async {
    try {
      await _firestore
          .collection('reels')
          .doc(reelId)
          .delete()
          .catchError((e) => errorMessage(e));
      successMessage("Reel deleted");
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

  Future<XFile?> pickImageGallery() async {
    final XFile? images = await picker.pickImage(
      maxHeight: 240,
      maxWidth: 320,
      source: ImageSource.gallery,
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
