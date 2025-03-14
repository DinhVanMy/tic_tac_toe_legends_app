import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/invite_request_dialog.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Controller/matching_controller.dart';
import 'package:tictactoe_gameapp/Controller/notification_controller.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Controller/room_controller.dart';
import 'package:tictactoe_gameapp/Models/Functions/permission_handle_functions.dart';
import 'package:tictactoe_gameapp/Models/general_notifications_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/agora_call_page.dart';
import 'package:tictactoe_gameapp/main.dart';
import 'package:uuid/uuid.dart';

class NotifyInMainController extends GetxController {
  var friendRequests =
      <GeneralNotificationsModel>[].obs; // Lời mời kết bạn lưu trữ
  var filteredFriendRequests =
      <GeneralNotificationsModel>[].obs; // Lời mời kết bạn đã lọc
  var searchText = ''.obs; // Text tìm kiếm từ người dùng
  var isWaitingForOk = false.obs;
  final Rx<OverlayEntry?> _popupEntry = Rx<OverlayEntry?>(null);
  RxBool isPopupVisible = false.obs; // Để kiểm soát trạng thái của popup

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String currentUserId = Get.find<AuthController>().getCurrentUserId();
  var uuid = const Uuid();
  final RoomController roomController = Get.put(RoomController());

  late StreamSubscription listenForFriendRequestsSub;
  late StreamSubscription listenForGameInvitesSub;
  late StreamSubscription listenForCallSub;

  @override
  void onInit() {
    super.onInit();
    deleteOldNotifications();
    setupSearchListener();
  }

  // Lắng nghe các lời mời kết bạn (Lưu lại trong Firestore)
  void listenForFriendRequests() {
    listenForFriendRequestsSub = db
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'friendRequest')
        .snapshots(includeMetadataChanges: true)
        .listen((QuerySnapshot snapshot) {
      // Xử lý từng thay đổi trong snapshot
      for (var change in snapshot.docChanges) {
        var request = GeneralNotificationsModel.fromJson(
            change.doc.data() as Map<String, dynamic>);
        request.id = change.doc.id; // Lưu ID từ Firestore vào model

        if (change.type == DocumentChangeType.added) {
          // Kiểm tra nếu lời mời chưa tồn tại, thêm vào đầu danh sách
          if (!friendRequests.any((req) => req.id == request.id)) {
            friendRequests.insert(0, request); // Thêm mới lời mời kết bạn
          }
        } else if (change.type == DocumentChangeType.modified) {
          // Tìm lời mời đã tồn tại và cập nhật
          final index =
              friendRequests.indexWhere((req) => req.id == request.id);
          if (index != -1) {
            friendRequests[index] = request; // Cập nhật lời mời đã sửa
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Xóa lời mời khỏi danh sách
          friendRequests.removeWhere((req) => req.id == request.id);
        }
      }
      // Sau khi cập nhật danh sách, lọc lại dữ liệu theo searchText
      filterFriendRequests();
    });
  }

  // Hàm thiết lập lắng nghe sự thay đổi của searchText
  void setupSearchListener() {
    debounce(searchText, (_) => filterFriendRequests(),
        time: const Duration(milliseconds: 300));
  }

  // Hàm lọc friendRequests dựa trên searchText
  void filterFriendRequests() {
    // Nếu không có nội dung tìm kiếm, hiển thị toàn bộ friendRequests
    if (searchText.isEmpty) {
      filteredFriendRequests.assignAll(friendRequests);
    } else {
      final searchLower = searchText.value.toLowerCase();

      // Lọc danh sách theo nội dung tìm kiếm
      filteredFriendRequests.assignAll(friendRequests.where((request) {
        final senderName = request.senderModel!.name!.toLowerCase();
        final email = request.senderModel!.email!.toLowerCase();
        // Kiểm tra nếu senderName hoặc message chứa nội dung tìm kiếm
        return senderName.contains(searchLower) || email.contains(searchLower);
      }).toList());
    }
  }

  // Hàm cập nhật nội dung tìm kiếm khi người dùng nhập text
  void updateSearchText(String text) {
    searchText.value =
        text.toLowerCase(); // Chuyển sang chữ thường khi cập nhật
  }

  // Lắng nghe các lời mời chơi game (Tự động xóa sau 30 giây)
  void listenForGameInvites() {
    listenForGameInvitesSub = db
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'gameInvite')
        .snapshots()
        .listen((snapshot) {
      var gameInvites = snapshot.docs.map((doc) {
        var notification = GeneralNotificationsModel.fromJson(doc.data());
        notification.id = doc.id;
        return notification;
      }).toList();

      // Hiển thị lời mời chơi game và xóa sau 30 giây
      for (var invite in gameInvites) {
        // showGameInviteRequest(invite);
        // final NotificationController notificationController =
        //     Get.put(NotificationController());
        // notificationController.showMessageNotification(context,
        //   invite.senderModel!,
        //   "Uint8List largeIconBytes = await _loadNetworkImage(callerImage);",
        // );
        // Xóa lời mời chơi game từ Firestore sau 30 giây
        Future.delayed(const Duration(seconds: 10), () {
          if (invite.id != null) {
            db.collection('notifications').doc(invite.id).delete();
          }
          removePopup();
        });
      }
    });
  }

  void listenForCall() {
    listenForCallSub = db
        .collection('notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('type', isEqualTo: 'call')
        .snapshots()
        .listen((snapshot) {
      var callInvites = snapshot.docs.map((doc) {
        var notification = GeneralNotificationsModel.fromJson(doc.data());
        notification.id = doc.id;
        return notification;
      }).toList();

      // Hiển thị lời mời call và xóa sau 30 giây
      for (var call in callInvites) {
        showCallInviteRequest(call);
        final NotificationController notificationController =
            Get.put(NotificationController());
        notificationController.showCallNotification(
            call.senderModel!.name!, call.senderModel!.image!);

        // Xóa lời mời call từ Firestore sau 30 giây
        Future.delayed(const Duration(seconds: 10), () async {
          if (call.id != null) {
            await db.collection('notifications').doc(call.id).delete();
          }
          removePopup();
        });
      }
    });
  }

  // Gửi lời mời kết bạn (Lưu lại)
  Future<void> sendFriendRequest(
    String receiverId,
    UserModel senderUser,
  ) async {
    String id = uuid.v4().substring(0, 12);
    var senderModel = UserModel(
      id: senderUser.id,
      name: senderUser.name,
      email: senderUser.email,
      image: senderUser.image,
    );
    GeneralNotificationsModel request = GeneralNotificationsModel(
      id: id,
      senderId: currentUserId,
      senderModel: senderModel,
      receiverId: receiverId,
      message: ' ${senderUser.name} have sent a friend request',
      type: 'friendRequest',
      timestamp: Timestamp.now(),
    );
    await db.collection('notifications').doc(id).set(request.toJson());
  }

  // Gửi lời mời chơi game (Tự động xóa sau 30 giây)
  Future<void> sendGameInvite(
      String receiverId, String roomId, UserModel senderUser) async {
    try {
      isWaitingForOk.value = true;
      var senderModel = UserModel(
        id: senderUser.id,
        name: senderUser.name,
        email: senderUser.email,
        image: senderUser.image,
      );
      GeneralNotificationsModel invite = GeneralNotificationsModel(
        senderId: currentUserId,
        senderModel: senderModel,
        receiverId: receiverId,
        message: 'Bạn có lời mời chơi game từ $currentUserId',
        type: 'gameInvite',
        roomId: roomId,
        timestamp: Timestamp.now(),
      );
      await db.collection('notifications').add(invite.toJson());
      await Future.delayed(const Duration(seconds: 5));
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isWaitingForOk.value = false;
    }
  }

  Future<void> sendCallInvite({
    required String receiverId,
    required UserModel senderUser,
    required String channelId,
    required bool isVideoCall,
  }) async {
    try {
      var senderModel = UserModel(
        id: senderUser.id,
        name: senderUser.name,
        email: senderUser.email,
        image: senderUser.image,
      );
      GeneralNotificationsModel call = GeneralNotificationsModel(
        senderId: currentUserId,
        senderModel: senderModel,
        receiverId: receiverId,
        roomId: channelId,
        isVideoCall: isVideoCall,
        type: 'call',
        timestamp: Timestamp.now(),
      );
      await db.collection('notifications').add(call.toJson());
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  Future<void> deleteFriendRequest(String id) async {
    await db
        .collection('notifications')
        .doc(id)
        .delete()
        .catchError((e) => errorMessage(e.toString()));
  }

  void deleteOldNotifications() {
    final Timestamp sevenDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    db
        .collection('notifications')
        .where('timestamp', isLessThan: sevenDaysAgo)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        db.collection('notifications').doc(doc.id).delete();
      }
    });
  }

  void showGameInviteRequest(
    GeneralNotificationsModel invite,
  ) {
    if (_popupEntry.value != null) {
      // Xóa popup cũ nếu đã hiển thị
      removePopup();
    }

    _popupEntry.value = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GameInviteRequestDialog(
            friend: invite.senderModel!,
            onPressedAccept: () {
              Get.showOverlay(
                asyncFunction: () async {
                  try {
                    await db
                        .collection('notifications')
                        .doc(invite.id)
                        .delete();
                    Get.put(MatchingController());
                    removePopup();
                    await roomController.joinRoom(invite.roomId!);
                  } catch (e) {
                    errorMessage(e.toString());
                  }
                },
                loadingWidget: Stack(
                  children: [
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: const SizedBox(),
                      ),
                    ),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          GifsPath.loadingGif,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
            onPressedRefuse: () async {
              removePopup();
            },
          ),
        ),
      ),
    );

    // Hiển thị popup
    navigatorKey.currentState!.overlay!.insert(_popupEntry.value!);
    // animationController.forward();
    isPopupVisible.value = true;
  }

  void showCallInviteRequest(GeneralNotificationsModel call) {
    if (_popupEntry.value != null) {
      // Xóa popup cũ nếu đã hiển thị
      removePopup();
    }
    _popupEntry.value = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: CallInviteRequestDialog(
            friend: call.senderModel!,
            onPressedRefuse: () {
              removePopup();
            },
            onPressedAccept: () async {
              removePopup();
              final permissionHandler = PermissionHandleFunctions();
              bool micGranted =
                  await permissionHandler.checkMicrophonePermission();
              bool camGranted = await permissionHandler.checkCameraPermission();
              if (micGranted == true && camGranted == true) {
                final ProfileController profileController = Get.find();
                Get.to(() => AgoraCallPage(
                      userFriend: call.senderModel!,
                      userCurrent: profileController.user!,
                      channelId: call.roomId!,
                      initialMicState: true,
                      initialVideoState: call.isVideoCall ?? false,
                    ));
              } else {}
            },
            isVideoCall: call.isVideoCall ?? false,
          ),
        ),
      ),
    );

    // Hiển thị popup
    navigatorKey.currentState!.overlay!.insert(_popupEntry.value!);
    // animationController.forward();
    isPopupVisible.value = true;
  }

  void removePopup() {
    if (_popupEntry.value != null) {
      _popupEntry.value?.remove();
      _popupEntry.value = null;
      isPopupVisible.value = false;
    }
  }

  @override
  void onClose() {
    listenForFriendRequestsSub.cancel();
    listenForGameInvitesSub.cancel();
    listenForCallSub.cancel();
    removePopup();
    super.onClose();
  }
}
