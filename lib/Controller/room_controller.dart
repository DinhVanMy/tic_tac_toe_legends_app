import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/LobbyPage/lobby_page.dart';
import 'package:uuid/uuid.dart';

class RoomController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  var uuid = const Uuid();
  RxBool isLoading = false.obs;
  Rx<UserModel> user = UserModel().obs;
  Rx<RoomModel?> roomData = Rx<RoomModel?>(null);
  @override
  void onInit() {
    super.onInit();
    getUserDetails();
  }

  Future<void> createRoom() async {
    isLoading.value = true;
    String id = uuid.v4().substring(0, 8).toUpperCase();
    var player1 = UserModel(
      id: user.value.id,
      name: user.value.name,
      image: user.value.image,
      email: user.value.email,
      totalWins: user.value.totalWins,
      totalCoins: user.value.totalCoins,
      yourTurn: "X",
      role: "admin",
    );
    var newRoom = RoomModel(
      id: id,
      player1: player1,
      gameStatus: "lobby",
      player1Status: "waiting",
      isXturn: true,
      createdAt: DateTime.now(),
    );
    try {
      await db
          .collection("rooms")
          .doc(id)
          .set(
            newRoom.toJson(),
          )
          .catchError((e) => errorMessage(e.toString()));
      Get.to(LobbyPage(roomId: id));
    } catch (e) {
      errorMessage("Error");
    }
    isLoading.value = false;
  }

  Future<void> getUserDetails() async {
    await db.collection("users").doc(auth.currentUser?.uid).get().then((value) {
      user.value = UserModel.fromJson(value.data()!);
    });
  }

  void getRoomDetails(String roomId) {
    db.collection('rooms').doc(roomId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        // Update roomData when the snapshot is received
        roomData.value =
            RoomModel.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        roomData.value = null; // Room not found
      }
    });
  }

  void listenRoomChanges(String roomId) {
    db.collection('rooms').doc(roomId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          roomData.value = RoomModel.fromJson(snapshot.data()!);
        } else {
          roomData.value = null;
        }
      },
    );
  }

  Future<void> joinRoom(String roomId) async {
    isLoading.value = true;
    var player2 = UserModel(
      id: user.value.id,
      name: user.value.name,
      image: user.value.image,
      email: user.value.email,
      totalWins: "0",
      yourTurn: "O",
      role: "player",
    );
    try {
      await db.collection("rooms").doc(roomId).update(
        {
          "player2": player2.toJson(),
          "player2Status": "waiting",
        },
      ).catchError((e) => errorMessage(e.toString()));
      Get.to(LobbyPage(roomId: roomId));
    } catch (e) {
      errorMessage(e.toString());
    }
    isLoading.value = false;
  }

  Future<void> updatePlayer2Status(String roomId, String status) async {
    await db.collection("rooms").doc(roomId).update(
      {
        "player2Status": status,
      },
    );
  }
}
