import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/confetti_widget_custom.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/Animations/countdown_animation_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_controller.dart';
import 'package:tictactoe_gameapp/Controller/Music/music_play_controller.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Widgets/core/countdown_waiting_widget.dart';

class PlayWithPlayerController extends GetxController {
  RxList<RxList<String>> board = RxList<RxList<String>>();
  RxList<Offset> winningLineCoordinates = <Offset>[].obs;
  RxBool isXtime = true.obs;
  RxString winner = ''.obs;
  var roomModel = Rx<RoomModel?>(null);
  RxInt initialSize = 3.obs;
  RxInt winLength = 5.obs;

  int advancedExpand = 2;
  int currentWin = 0;
  int currentCoin = 0;
  StreamSubscription<DocumentSnapshot>? roomSubscription;
  late int? currentCoinPlayer1;
  late int? winningPrize;
  late int? currentCoinPlayer2;
  late int? currentWinPlayer1;
  late int? currentWinPlayer2;

  final db = FirebaseFirestore.instance;
  final String currentUserEmail =
      Get.find<AuthController>().getCurrentUserEmail();
  final MusicPlayController musicPlayController =
      Get.put(MusicPlayController());
  final MusicController musicController = Get.find();

  void getRoomDetails(String roomId) async {
    try {
      // Lấy dữ liệu ban đầu với get()
      DocumentSnapshot initialSnapshot =
          await db.collection("rooms").doc(roomId).get();
      roomModel.value =
          RoomModel.fromJson(initialSnapshot.data()! as Map<String, dynamic>);

      initialSize.value = roomModel.value!.initialMode!;
      winLength.value = roomModel.value!.winLengthMode!;

      board.value = List.generate(initialSize.value, (_) {
        return List.generate(initialSize.value, (_) => '').obs;
      }).obs;

      await db.collection("rooms").doc(roomId).update({
        "gameValue": board.expand((row) => row).toList(),
      });

      winningPrize = int.tryParse(roomModel.value!.winningPrize!);
      currentCoinPlayer1 =
          int.tryParse(roomModel.value!.player1!.totalCoins ?? "0");
      currentWinPlayer1 =
          int.tryParse(roomModel.value!.player1!.totalWins ?? "0");
      currentCoinPlayer2 =
          int.tryParse(roomModel.value!.player2!.totalCoins ?? "0");
      currentWinPlayer2 =
          int.tryParse(roomModel.value!.player2!.totalWins ?? "0");

      roomSubscription =
          db.collection("rooms").doc(roomId).snapshots().listen((event) async {
        RoomModel updatedRoomModel = RoomModel.fromJson(event.data()!);

        // Kiểm tra nếu gameValue có sự thay đổi
        if (updatedRoomModel.gameValue != roomModel.value!.gameValue) {
          roomModel.value = updatedRoomModel;
          isXtime.value = roomModel.value!.isXturn!;
          winner.value = roomModel.value!.winnerVariable!;

          // Cập nhật lại board từ gameValue mới
          List<String> updatedGameValue = roomModel.value!.gameValue ?? [];
          initialSize.value = sqrt(updatedGameValue.length).toInt();

          board.value = List.generate(initialSize.value, (rowIndex) {
            return RxList<String>.from(
              updatedGameValue.sublist(
                rowIndex * initialSize.value,
                (rowIndex + 1) * initialSize.value,
              ),
            );
          }).obs;
          // board.value = List.generate(
          //   sqrt(updatedGameValue.length)
          //       .toInt(), // Tạo bảng có kích thước dựa trên độ dài của gameValue
          //   (rowIndex) {
          //     return RxList<String>.from(
          //       updatedGameValue.sublist(
          //         rowIndex * sqrt(updatedGameValue.length).toInt(),
          //         (rowIndex + 1) * sqrt(updatedGameValue.length).toInt(),
          //       ),
          //     );
          //   },
          // ).obs;
          // board.refresh();
        }
        // if (updatedRoomModel.isXturn!) {
        //   await musicPlayController.playSoundPlayer1();
        // } else {
        //   await musicPlayController.playSoundPlayer2();
        // }
        // if (updatedRoomModel.player1 != null || updatedRoomModel.player2 != null) {
        //   if (updatedRoomModel.player1!.quickMess != null ||
        //       updatedRoomModel.player2!.quickMess != null) {
        //     removeMessage(updatedRoomModel);
        //   }
        // }
        // if (updatedRoomModel.player1 != null || updatedRoomModel.player2 != null) {
        //   if (updatedRoomModel.player1!.quickEmote != null ||
        //       updatedRoomModel.player2!.quickEmote != null) {
        //     removeEmote(updatedRoomModel);
        //   }
        // }
      }, onError: (error) {
        errorMessage("Error fetching room details: $error");
      });
    } catch (e) {
      errorMessage("Error fetching room details: $e");
    }
  }

  Future<void> updateData(
    RoomModel roomData,
    int row,
    int col,
  ) async {
    if (board[row][col] == '' && winner.value == '') {
      board[row][col] = isXtime.value ? 'X' : 'O';
      await db.collection("rooms").doc(roomData.id!).update({
        "gameValue": board.expand((row) => row).toList(),
        "isXturn": !isXtime.value,
      });
      board.refresh();
      if (checkWinner(row, col)) {
        winner.value = !isXtime.value ? 'X' : 'O';
        await db.collection("rooms").doc(roomData.id!).update({
          "winnerVariable": winner.value,
        });
      } else {
        if (isBoardFull()) {
          advancedExpand++;
          for (int i = 0; i < advancedExpand; i++) {
            await expandBoard(roomData);
          }
        }
      }
    }
  }

  bool isBoardFull() {
    for (var row in board) {
      if (row.contains('')) {
        return false;
      }
    }
    return true;
  }

  Future<void> expandBoard(RoomModel roomData) async {
    int oldSize = board.length;
    int newSize = oldSize + 2;
    // Add new rows at the top and bottom
    board.insert(0, List.generate(newSize, (_) => '').obs);
    board.add(List.generate(newSize, (_) => '').obs);

    // Update existing rows to add new columns at the start and end
    for (int i = 1; i < board.length - 1; i++) {
      // Skip first and last row
      board[i].insert(0, '');
      board[i].add('');
    }

    await db.collection("rooms").doc(roomData.id!).update({
      "gameValue": board.expand((row) => row).toList(),
    });

    board.refresh();
  }

  bool checkWinner(int row, int col) {
    String currentPlayer = board[row][col];
    int n = board.length;

    // Kiểm tra hàng ngang
    for (int i = 0; i <= n - winLength.value; i++) {
      if (board[row]
          .sublist(i, i + winLength.value)
          .every((element) => element == currentPlayer)) {
        winningLineCoordinates.value = List.generate(winLength.value,
            (index) => Offset(row.toDouble(), (i + index).toDouble()));
        return true;
      }
    }

    // Kiểm tra hàng dọc
    for (int i = 0; i <= n - winLength.value; i++) {
      if (List.generate(winLength.value, (index) => board[i + index][col])
          .every((element) => element == currentPlayer)) {
        winningLineCoordinates.value = List.generate(winLength.value,
            (index) => Offset((i + index).toDouble(), col.toDouble()));
        return true;
      }
    }

    // Kiểm tra đường chéo chính
    for (int i = 0; i <= n - winLength.value; i++) {
      for (int j = 0; j <= n - winLength.value; j++) {
        if (List.generate(
                winLength.value, (index) => board[i + index][j + index])
            .every((element) => element == currentPlayer)) {
          winningLineCoordinates.value = List.generate(
              winLength.value,
              (index) =>
                  Offset((i + index).toDouble(), (j + index).toDouble()));
          return true;
        }
      }
    }

    // Kiểm tra đường chéo phụ
    for (int i = 0; i <= n - winLength.value; i++) {
      for (int j = winLength.value - 1; j < n; j++) {
        if (List.generate(
                winLength.value, (index) => board[i + index][j - index])
            .every((element) => element == currentPlayer)) {
          winningLineCoordinates.value = List.generate(
              winLength.value,
              (index) =>
                  Offset((i + index).toDouble(), (j - index).toDouble()));
          return true;
        }
      }
    }
    return false;
  }

  void winnerDialog(String winner, RoomModel roomData) {
    // musicPlayController.playSoundWinner();
    Get.defaultDialog(
      barrierDismissible: false,
      title: "VICTORY",
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        fontSize: 30,
      ),
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 5),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  IconsPath.wonIcon,
                  width: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Congratulations",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),
                const Text(
                  "You won the match",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Get.showOverlay(
                          asyncFunction: () async {
                            await scoreCalculateWinner(
                                winner: winner, roomData: roomData);
                            await resetPlayValue(roomData.id!);
                          },
                          loadingWidget: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  GifsPath.transitionGif,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ).then((_) => Get.back());
                      },
                      child: const Text("Play Again"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await scoreCalculateWinner(
                            winner: winner, roomData: roomData);
                        await deleteRoom(roomData.id!);
                        Get.offAllNamed("/mainHome");
                      },
                      child: const Text("Exit"),
                    )
                  ],
                )
              ],
            ),
          ),
          // const Center(
          //   child: ConfettiWidgetCustom(),
          // )
        ],
      ),
    );
  }

  void defeatDialog(String winner, RoomModel roomData) {
    // musicPlayController.playSoundLoser();
    Get.defaultDialog(
      barrierDismissible: false,
      title: "DEFEAT",
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.red,
        fontSize: 30,
      ),
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent, width: 5),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  IconsPath.wonIcon,
                  width: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Defeat",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                ),
                const Text(
                  "Enemy won the match",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Get.showOverlay(
                          asyncFunction: () async {
                            await scoreCalculateLoser(
                                winner: winner, roomData: roomData);
                            await resetPlayValue(roomData.id!);
                          },
                          loadingWidget: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  GifsPath.transitionGif,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ).then((_) => Get.back());
                        // Get.until((route) => route.isFirst);
                      },
                      child: const Text("Play Again"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await scoreCalculateLoser(
                            winner: winner, roomData: roomData);
                        await deleteRoom(roomData.id!);
                        Get.offAllNamed("/mainHome");
                      },
                      child: const Text("Exit"),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initializeBoard(String roomId) async {
    initialSize.value = roomModel.value!.initialMode!;
    final List<String> emptyBoard =
        List.filled(initialSize.value * initialSize.value, '');

    await db.collection("rooms").doc(roomId).update({
      "gameValue": emptyBoard, // Reset game values to empty
      "winnerVariable": '', // Reset winner
    });

    // Update local board state
    board.value = List.generate(initialSize.value, (rowIndex) {
      return RxList<String>.from(emptyBoard.sublist(
          rowIndex * initialSize.value, (rowIndex + 1) * initialSize.value));
    }).obs;
  }

  Future<void> resetPlayValue(String roomId) async {
    await initializeBoard(roomId);
    roomModel.update((room) {
      room!.gameValue = List.filled(initialSize.value * initialSize.value, '');
      room.winnerVariable = '';
    });
    board.refresh();
  }

  Future<void> scoreCalculateWinner({
    required String winner,
    required RoomModel roomData,
  }) async {
    if (winner == "X") {
      int? newCoinsPlayer1 = currentCoinPlayer1! + winningPrize!;
      int? newWinsPlayer1 = currentWinPlayer1! + 1;
      await db.collection('users').doc(roomData.player1!.id!).update({
        'totalCoins': newCoinsPlayer1.toString(),
        'totalWins': newWinsPlayer1.toString(),
      }).catchError((e) => errorMessage(e.toString()));
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.totalCoins": newCoinsPlayer1.toString(),
        "player1.totalWins": newWinsPlayer1.toString(),
      }).catchError((e) => errorMessage(e.toString()));
    } else {
      int? newCoinsPlayer2 = currentCoinPlayer2! + winningPrize!;
      int? newWinsPlayer2 = currentWinPlayer2! + 1;
      await db.collection('users').doc(roomData.player2!.id!).update({
        'totalCoins': newCoinsPlayer2.toString(),
        'totalWins': newWinsPlayer2.toString(),
      }).catchError((e) => errorMessage(e.toString()));
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.totalCoins": newCoinsPlayer2.toString(),
        "player2.totalWins": newWinsPlayer2.toString(),
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  Future<void> scoreCalculateLoser({
    required String winner,
    required RoomModel roomData,
  }) async {
    if (winner == "X") {
      int? newCoinsPlayer2 = currentCoinPlayer2! - winningPrize!;
      int? newWinsPlayer2 = currentWinPlayer2! - 1;
      await db.collection('users').doc(roomData.player2!.id!).update({
        'totalCoins': newCoinsPlayer2.toString(),
        'totalWins': newWinsPlayer2.toString(),
      }).catchError((e) => errorMessage(e.toString()));
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.totalCoins": newCoinsPlayer2.toString(),
        "player2.totalWins": newWinsPlayer2.toString(),
      }).catchError((e) => errorMessage(e.toString()));
    } else {
      int? newCoinsPlayer1 = currentCoinPlayer1! - winningPrize!;
      int? newWinsPlayer1 = currentWinPlayer1! - 1;
      await db.collection('users').doc(roomData.player1!.id!).update({
        'totalCoins': newCoinsPlayer1.toString(),
        'totalWins': newWinsPlayer1.toString(),
      }).catchError((e) => errorMessage(e.toString()));
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.totalCoins": newCoinsPlayer1.toString(),
        "player1.totalWins": newWinsPlayer1.toString(),
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  Future<String> updateRoomWhenPlayerLeaves(String roomId) async {
    try {
      // Lấy thông tin của room từ Firestore
      var roomSnapshot = await db.collection('rooms').doc(roomId).get();
      var roomData = roomSnapshot.data() as Map<String, dynamic>;
      if (roomData['player1'] != null &&
          roomData['player1']['email'] == currentUserEmail) {
        return "Player 1 has left the room";
      } else if (roomData['player2'] != null &&
          roomData['player2']['email'] == currentUserEmail) {
        await db.collection('rooms').doc(roomId).update({
          'player2': null,
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
      await db
          .collection("rooms")
          .doc(roomId)
          .delete()
          .catchError((e) => errorMessage(e.toString()));
    } else if (checkedPlayerLeave == "Player 2 has left the room") {
      errorMessage("You has left the room");
    }
  }

  void chatFeature(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 100,
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            labelText: 'Type your message...',
                            labelStyle: const TextStyle(
                              fontSize: 13.0,
                            )),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        sendMessage(textController.text, roomModel.value!);
                        FocusScope.of(context).unfocus();
                        textController.clear();
                        Get.back();
                      },
                    ),
                  ],
                ),
                const TabBar(
                  labelColor: Colors.white,
                  indicatorColor: Colors.blueAccent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.message)),
                    Tab(icon: Icon(Icons.history)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView.builder(
                        itemCount: quickChatMessages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              quickChatMessages[index],
                              style: const TextStyle(
                                  fontSize: 13.0, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: quickChatMessages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              quickChatMessages[index],
                              style: const TextStyle(
                                  fontSize: 13.0, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: quickChatMessages.length,
                //     itemBuilder: (context, index) {
                //       return Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 8.0),
                //         child: Text(
                //           quickChatMessages[index],
                //           style: const TextStyle(
                //               fontSize: 13.0, color: Colors.white),
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(String text, RoomModel roomData) async {
    if (roomData.player1!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.quickMess": text,
      }).catchError((e) => errorMessage(e.toString()));
    } else if (roomData.player2!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.quickMess": text,
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  Future<void> removeMessage(RoomModel roomData) async {
    await Future.delayed(const Duration(seconds: 5));
    if (roomData.player1!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.quickMess": null,
      }).catchError((e) => errorMessage(e.toString()));
    } else if (roomData.player2!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.quickMess": null,
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  void emoteFeature(BuildContext context, RoomModel roomData) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 100,
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: emotes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    sendEmote(emotes[index], roomData);
                    Get.back();
                  },
                  child: Image.asset(
                    emotes[index],
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendEmote(String imagePath, RoomModel roomData) async {
    if (roomData.player1!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.quickEmote": imagePath,
      }).catchError((e) => errorMessage(e.toString()));
    } else if (roomData.player2!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.quickEmote": imagePath,
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  Future<void> removeEmote(RoomModel roomData) async {
    await Future.delayed(const Duration(seconds: 5));
    if (roomData.player1!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player1.quickEmote": null,
      }).catchError((e) => errorMessage(e.toString()));
    } else if (roomData.player2!.email == currentUserEmail) {
      await db.collection("rooms").doc(roomData.id!).update({
        "player2.quickEmote": null,
      }).catchError((e) => errorMessage(e.toString()));
    }
  }

  var isImagePicked = false.obs;
  var selectedImagePath = "".obs;
  var selectedImageX = "".obs;
  var selectedImageXHeroIndex = (-1).obs;
  var selectedImageO = "".obs;
  var selectedImageOHeroIndex = (-1).obs;
  var selectedImageIndex = (-1).obs;
  var selectedModeIndex = (-1).obs;
  var selectedDifficultyIndex = (-1).obs;
  var selectedWinningPrize = "".obs;
  var selectedImageModes = "".obs;

  List<String> imagePaths = [
    ImagePath.map1,
    ImagePath.map2,
    ImagePath.map4,
    ImagePath.map5,
    ImagePath.map6,
    ImagePath.map7,
    ImagePath.map8,
    ImagePath.map9,
    ImagePath.map10,
  ];
  List<String> modeImages = [
    ImagePath.board_3x3,
    ImagePath.board_6x6,
    ImagePath.board_9x9,
    ImagePath.board_11x11,
    ImagePath.board_11x11,
  ];
  List<String> modeTexts = ['3 x 3', '6 x 6', '9 x 9', '11 x 11', '15 x 15'];
  List<int> initialMode = [3, 6, 9, 11, 15];
  List<int> winLengthMode = [3, 4, 5, 6, 7];
  List<String> winningPrizeTexts = [
    '1 Coins',
    '10 Coins',
    '20 Coins',
    '50 Coins',
    '100 Coins',
    '200 Coins',
  ];
  List<String> winningFee = [
    '1',
    '10',
    '20',
    '50',
    '100',
    '200',
  ];

  void selectImage(String path, int index) {
    selectedImagePath.value = path;
    selectedImageIndex.value = index;
  }

  void selectMode(String imageMode, int initial, int winL, int index) {
    initialSize.value = initial;
    winLength.value = winL;
    selectedModeIndex.value = index;
    selectedImageModes.value = imageMode;
  }

  void selectForX(String X, int index) {
    selectedImageX.value = X;
    selectedImageXHeroIndex.value = index;
  }

  void selectForO(String O, int index) {
    selectedImageO.value = O;
    selectedImageOHeroIndex.value = index;
  }

  void selectDifficulty(String winningPrize, int index) {
    selectedDifficultyIndex.value = index;
    selectedWinningPrize.value = winningPrize;
  }

  void showPickerMultiPlayer({required String roomId}) {
    final CountdownController countdownController =
        Get.put(CountdownController());
    // final MusicController musicController = Get.find();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   musicController.playMusicOnScreen5();
    // });
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 500,
              padding: const EdgeInsets.all(10),
              child: Scrollbar(
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick a Map',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(imagePaths.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                selectImage(imagePaths[index], index);
                              },
                              child: Obx(() {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedImageIndex.value == index
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 5,
                                    ),
                                  ),
                                  child: Image.asset(
                                    imagePaths[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),

                    // Phần chọn chế độ
                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick a Mode',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(modeTexts.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                selectMode(
                                  modeImages[index],
                                  initialMode[index],
                                  winLengthMode[index],
                                  index,
                                );
                              },
                              child: Obx(() {
                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              selectedModeIndex.value == index
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                          width: 5,
                                        ),
                                      ),
                                      child: Image.asset(
                                        modeImages[index],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: selectedModeIndex.value == index
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        modeTexts[index],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick a hero for you',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 400,
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: listChamA.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                selectForX(listChamA[index], index);
                              },
                              child: Obx(() {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          selectedImageXHeroIndex.value == index
                                              ? Colors.blue
                                              : Colors.transparent,
                                      width: 5,
                                    ),
                                  ),
                                  child: Image.asset(
                                    listChamA[index],
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick a hero for Enemy',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 400,
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: listChamB.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                selectForO(listChamB[index], index);
                              },
                              child: Obx(() {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          selectedImageOHeroIndex.value == index
                                              ? Colors.blue
                                              : Colors.transparent,
                                      width: 5,
                                    ),
                                  ),
                                  child: Image.asset(
                                    listChamB[index],
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick Coin Prize',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Image.asset(
                        ImagePath.welcome3,
                        width: 50,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              List.generate(winningPrizeTexts.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                selectDifficulty(winningFee[index], index);
                              },
                              child: Obx(() {
                                return Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedDifficultyIndex.value == index
                                            ? Colors.blue
                                            : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    winningPrizeTexts[index],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.yellowAccent,
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -10,
              left: -10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueAccent,
                      offset: Offset(0, 5),
                      spreadRadius: 3.0,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            countdownController.stopAnimation();
                            Get.offAllNamed("/mainHome");
                          },
                          icon: const Icon(Icons.arrow_back_ios),
                        ),
                        const Text("Back"),
                      ],
                    ),
                    const CountdownWaitingWidget(),
                    Row(
                      children: [
                        const Text("Ok"),
                        IconButton(
                          onPressed: () async {
                            if (selectedImageIndex.value == -1) {
                              errorMessage("Please select a map.");
                            } else if (selectedModeIndex.value == -1) {
                              errorMessage("Please select a mode.");
                            } else if (selectedDifficultyIndex.value == -1) {
                              errorMessage("Please select a level.");
                            } else if (selectedImageXHeroIndex.value == -1) {
                              errorMessage(
                                  "Please select a hero for yourself.");
                            } else if (selectedImageOHeroIndex.value == -1) {
                              errorMessage("Please select a hero for bot.");
                            } else {
                              countdownController.stopAnimation();
                              await db.collection("rooms").doc(roomId).update({
                                "pickedMap": selectedImagePath.value,
                                "winnerVariable": "",
                                "champX": selectedImageX.value,
                                "champO": selectedImageO.value,
                                "initialMode": initialSize.value,
                                "winLengthMode": winLength.value,
                                "player1Status": "ready",
                                "winningPrize": selectedWinningPrize.value,
                                "imageMode": selectedImageModes.value,
                              });
                              Get.back();
                            }
                          },
                          icon: const Icon(
                              Icons.keyboard_double_arrow_right_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
