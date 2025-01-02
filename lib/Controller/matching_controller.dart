import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/LobbyPage/lobby_page.dart';
import 'package:tictactoe_gameapp/Models/queue_model.dart';
import 'package:uuid/uuid.dart';

class MatchingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = Get.find<AuthController>().getCurrentUserId();
  final String currentUserEmail =
      Get.find<AuthController>().getCurrentUserEmail();

  RxBool isSearching = false.obs;
  RxBool isFindingPlayer2 = false.obs;

  final auth = FirebaseAuth.instance;
  var uuid = const Uuid();
  RxBool isLoading = false.obs;
  Rx<UserModel> user = UserModel().obs;
  StreamSubscription? matchListener;

  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  // Hàm tìm đối thủ
  Future<void> startMatching() async {
    var newQueue = QueueModel(
      isSearching: true,
      createdAt: DateTime.now(),
      userId: currentUserId,
      userEmail: currentUserEmail,
    );

    isSearching.value = true;

    try {
      // Đưa người chơi vào hàng đợi tìm trận
      await _firestore
          .collection('matchings')
          .doc(currentUserId)
          .update(newQueue.toJson())
          .catchError((e) => errorMessage(e.toString()));

      // await Future.delayed(const Duration(seconds: 2));

      // Lắng nghe thay đổi trong hàng đợi
      matchListener = _firestore.collection('matchings').snapshots().listen(
          (snapshot) async {
        if (isSearching.value) {
          var availablePlayers = snapshot.docs.where((doc) =>
              doc['userId'] != currentUserId &&
              doc['isSearching'] == true &&
              doc['userEmail'] != currentUserEmail);

          if (availablePlayers.isNotEmpty) {
            var opponent = availablePlayers.first;
            // So sánh thời gian tạo để xác định ai sẽ tạo phòng

            if (opponent['createdAt'] == null) {
              await waitForOpponentRoom(opponent['userId']);
            } else {
              Timestamp opponentCreatedAt =
                  (opponent['createdAt'] as Timestamp);
              Timestamp myCreatedAt = Timestamp.fromDate(newQueue.createdAt!);
              if (myCreatedAt.compareTo(opponentCreatedAt) < 0) {
                await createMatch();
              } else {
                // Đợi người chơi khác tạo phòng
                await Future.delayed(const Duration(seconds: 3));
                await waitForOpponentRoom(opponent['userId']);
              }
            }
          } else {
            await Future.delayed(const Duration(seconds: 35));
            cancelMatching();
          }
        }
      }, onError: (error) {
        errorMessage(error.toString());
      });
    } catch (e) {
      isSearching.value = false;
      errorMessage("Failed to search for a match: $e");
    }
  }

  // Hàm tạo trận đấu
  Future<void> createMatch() async {
    isSearching.value = false;
    isLoading.value = true;
    String id = uuid.v4().substring(0, 8).toUpperCase();

    var player1 = UserModel(
      id: currentUserId,
      name: user.value.name,
      image: user.value.image,
      email: user.value.email,
      totalWins: user.value.totalWins,
      totalCoins: user.value.totalCoins,
      role: "Admin",
    );

    var newRoom = RoomModel(
      id: id,
      player1: player1,
      gameStatus: "lobby",
      player1Status: "waiting",
      player2Status: "",
      isXturn: true,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore
          .collection("rooms")
          .doc(id)
          .set(newRoom.toJson())
          .catchError((e) => errorMessage(e.toString()));
      Get.to(
        LobbyPage(roomId: id),
        transition: Transition.leftToRightWithFade,
      );
      isSearching.value = false;
    } catch (e) {
      errorMessage(e.toString());
    }
    isLoading.value = false;
  }

  // Hàm đợi đối thủ tạo phòng
  Future<void> waitForOpponentRoom(String opponentId) async {
    var player2 = UserModel(
      id: opponentId,
      name: user.value.name,
      image: user.value.image,
      email: user.value.email,
      totalWins: user.value.totalWins,
      totalCoins: user.value.totalCoins,
      role: "player",
    );
    matchListener = _firestore
        .collection('rooms')
        .where('player1.id', isEqualTo: opponentId)
        .where('player2Status', isEqualTo: "")
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var roomId = snapshot.docs.first.id;
        // Kiểm tra tài liệu tồn tại trước khi cập nhật
        _firestore.collection("rooms").doc(roomId).get().then((docSnapshot) {
          if (docSnapshot.exists) {
            // Tiến hành cập nhật
            _firestore.collection("rooms").doc(roomId).update({
              "player2": player2.toJson(),
              "player2Status": "waiting",
            }).catchError((e) => errorMessage(e.toString()));
            cancelMatching();
            Get.to(
              LobbyPage(roomId: roomId),
              transition: Transition.leftToRightWithFade,
            );
          }
        });
      }
    }, onError: (error) {
      errorMessage(error.toString());
    });
  }

  // Hủy tìm trận
  Future<void> cancelMatching() async {
    isSearching.value = false;
    // Hủy lắng nghe nếu tồn tại
    if (matchListener != null) {
      await matchListener?.cancel();
      matchListener = null;
    }
    var newQueue = QueueModel(
      userId: currentUserId,
      isSearching: false,
      createdAt: DateTime.now(),
      userEmail: currentUserEmail,
    );
    await _firestore
        .collection('matchings')
        .doc(currentUserId)
        .update(newQueue.toJson())
        .catchError((e) => errorMessage(e.toString()));
  }

  Future<String> updateRoomWhenPlayerLeaves(String roomId) async {
    try {
      // Lấy thông tin của room từ Firestore
      var roomSnapshot = await _firestore.collection('rooms').doc(roomId).get();
      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      if (roomData['player1'] != null &&
          roomData['player1']['email'] == currentUserEmail) {
        return "Player 1 has left the room";
      } else if (roomData['player2'] != null &&
          roomData['player2']['email'] == currentUserEmail) {
        // Nếu player2 là người thoát phòng
        await _firestore.collection('rooms').doc(roomId).update({
          'player2': "",
          'player2Status': "",
        }).catchError((e) => errorMessage(e.toString()));
        return "Player 2 has left the room";
      } else {
        return "";
      }
    } catch (error) {
      return error.toString();
    }
  }

  //delete room
  Future<void> deleteRoom(String roomId) async {
    String checkedPlayerLeave = await updateRoomWhenPlayerLeaves(roomId);
    if (checkedPlayerLeave == "Player 1 has left the room") {
      await _firestore
          .collection("rooms")
          .doc(roomId)
          .delete()
          .catchError((e) => errorMessage(e.toString()));
    } else if (checkedPlayerLeave == "Player 2 has left the room") {
      errorMessage("You has left the room");
    }
    cancelMatching();
  }

  // function for updating the "matchings"
  void findingPlayer2() async {
    isFindingPlayer2.value = true;
    var newMatching = QueueModel(
      isSearching: true,
      createdAt: DateTime.now(),
      userId: currentUserId,
      userEmail: currentUserEmail,
    );
    await _firestore
        .collection('matchings')
        .doc(currentUserId)
        .update(newMatching.toJson())
        .catchError((e) => errorMessage(e.toString()));
    await Future.delayed(const Duration(seconds: 10));
    cancelFindingPlayer2();
  }

  void cancelFindingPlayer2() async {
    isFindingPlayer2.value = false;
    var newMatching = QueueModel(
      isSearching: false,
      createdAt: DateTime.now(),
      userId: currentUserId,
      userEmail: currentUserEmail,
    );
    await _firestore
        .collection('matchings')
        .doc(currentUserId)
        .update(newMatching.toJson())
        .catchError((e) => errorMessage(e.toString()));
  }

  // Lấy thông tin người chơi hiện tại
  Future<void> getUserDetails() async {
    await _firestore
        .collection("users")
        .doc(auth.currentUser?.uid)
        .get()
        .then((value) {
      user.value = UserModel.fromJson(value.data()!);
    });
  }

  //get room details
  Future<String> getOpponentIdFromRoom(String roomId) async {
    var roomSnapshot = await _firestore.collection('rooms').doc(roomId).get();
    var roomData = roomSnapshot.data() as Map<String, dynamic>;
    return roomData['player1']['id'];
  }

  @override
  void onClose() {
    cancelMatching();
    super.onClose();
  }
}
