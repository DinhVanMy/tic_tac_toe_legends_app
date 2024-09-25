import 'dart:math';
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
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';
import 'package:tictactoe_gameapp/Pages/GamePage/Widgets/core/countdown_waiting_widget.dart';

class PlayWithBotController extends GetxController {
  RxList<RxList<String>> board = RxList<RxList<String>>();
  RxList<Offset> winningLineCoordinates = <Offset>[].obs;
  final MusicController musicController = Get.find();
  RxBool isXtime = true.obs;
  RxInt xScore = 0.obs;
  RxInt oScore = 0.obs;
  RxString winner = ''.obs;

  RxInt initialSize = 3.obs;
  RxInt winLength = 5.obs;
  int advancedExpand = 2;
  int currentWin = 0;
  int currentCoin = 0;

  final MusicPlayController musicPlayController =
      Get.put(MusicPlayController());
  final FirestoreController firestoreController =
      Get.put(FirestoreController());

  void initializeBoard() {
    board.value = List.generate(initialSize.value, (_) {
      return List.generate(initialSize.value, (_) => '').obs;
    }).obs;
  }

  void makeMove(int row, int col) async {
    if (board[row][col] == '' && winner.value == '') {
      board[row][col] = isXtime.value ? 'X' : 'O';
      await musicPlayController.playSoundPlayer1();
      board.refresh();
      if (checkWinner(row, col)) {
        winner.value = isXtime.value ? 'X' : 'O';
        winnerDialog(winner.value);
      } else {
        togglePlayer();
        if (isBoardFull()) {
          advancedExpand++;
          for (int i = 0; i < advancedExpand; i++) {
            expandBoard();
          }
        }
        if (winner.value == '') {
          await musicPlayController.playSoundPlayer2();
          await playWithAI();
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

  void expandBoard() {
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

    // Refresh the board state
    board.refresh();
  }

  void togglePlayer() {
    isXtime.value = !isXtime.value;
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

  Future<void> winnerDialog(String winner) async {
    if (winner == 'X') {
      await musicPlayController.playSoundWinner();
    } else {
      await musicPlayController.playSoundLoser();
    }
    scoreCalculate(winner);
    await Get.defaultDialog(
      barrierDismissible: false,
      title: winner == 'X' ? "VICTORY" : "DEFEAT",
      backgroundColor: Colors.white,
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: winner == 'X' ? Colors.deepOrangeAccent : Colors.red,
        fontSize: 30,
      ),
      content: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: winner == 'X'
                  ? Border.all(color: Colors.yellow, width: 5)
                  : Border.all(color: Colors.redAccent, width: 5),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  IconsPath.wonIcon,
                  width: 100,
                ),
                const SizedBox(height: 20),
                winner == 'X'
                    ? const Text(
                        "Congratulations",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.yellow,
                        ),
                      )
                    : const Text(
                        "Defeat",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                Text(
                  "$winner won the match",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        resetGame();
                      },
                      child: const Text("Play Again"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        musicController.stopMusicOnScreen6();
                        Get.offAllNamed("/mainHome");
                      },
                      child: const Text("Exit"),
                    )
                  ],
                )
              ],
            ),
          ),
          winner == 'X'
              ? const Center(
                  child: ConfettiWidgetCustom(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void resetGame() {
    initializeBoard();
    winner.value = '';
    if (!isXtime.value) {
      isXtime.value = !isXtime.value;
    }

    Get.back();
  }

  void resetGameAI() {
    initializeBoard();
    winner.value = '';
    isXtime.value = !isXtime.value;
    Get.back();
  }

  void scoreCalculate(String winner) {
    if (winner == "X") {
      currentWin += 1;
      currentCoin += 10;
      firestoreController.incrementCoinsAndWins();
      xScore.value = xScore.value + 1;
    } else if (winner == "O") {
      oScore.value = oScore.value + 1;
    }
  }

  Future<void> playWithAI() async {
    // Tìm tất cả các ô trống
    var emptyCells = <List<int>>[];
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] == '') {
          emptyCells.add([row, col]);
        }
      }
    }

    // Ưu tiên 1: Kiểm tra nếu AI có thể thắng
    for (var cell in emptyCells) {
      int row = cell[0];
      int col = cell[1];
      board[row][col] = isXtime.value ? 'X' : 'O'; // AI thử đi
      if (checkWinner(row, col)) {
        // Nếu AI có thể thắng, thực hiện nước đi này
        board.refresh();
        winner.value = isXtime.value ? 'X' : 'O';
        await winnerDialog(winner.value);
        return;
      } else {
        board[row][col] = ''; // Hoàn tác nếu không phải nước thắng
      }
    }

    // Ưu tiên 2: Ngăn chặn đối thủ nếu họ có thể thắng
    for (var cell in emptyCells) {
      int row = cell[0];
      int col = cell[1];
      board[row][col] = isXtime.value ? 'O' : 'X'; // Giả định đối thủ đi
      if (checkWinner(row, col)) {
        // Nếu đối thủ có thể thắng, ngăn chặn
        board[row][col] = isXtime.value ? 'X' : 'O'; // AI đi để ngăn chặn
        board.refresh();
        togglePlayer(); // Đổi lượt lại cho người chơi
        return;
      } else {
        board[row][col] = ''; // Hoàn tác nếu không phải nước đi ngăn chặn
      }
    }

    // Ưu tiên 3: Chọn ngẫu nhiên ô trống nếu không có nước nào đặc biệt
    if (emptyCells.isNotEmpty) {
      var randomCell = emptyCells[Random().nextInt(emptyCells.length)];
      // await Future.delayed(const Duration(milliseconds: 500));
      board[randomCell[0]][randomCell[1]] = isXtime.value ? 'X' : 'O';
      board.refresh();
      togglePlayer();
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
  List<String> difficultyTexts = ['Easy', 'Medium', 'Hard', 'Death'];

  void selectImage(String path, int index) {
    selectedImagePath.value = path;
    selectedImageIndex.value = index;
  }

  void selectMode(int initial, int winL, int index) {
    initialSize.value = initial;
    winLength.value = winL;
    selectedModeIndex.value = index;
  }

  void selectForX(String X, int index) {
    selectedImageX.value = X;
    selectedImageXHeroIndex.value = index;
  }

  void selectForO(String O, int index) {
    selectedImageO.value = O;
    selectedImageOHeroIndex.value = index;
  }

  void selectDifficulty(int index) {
    selectedDifficultyIndex.value = index;
  }

  void showMapPicker() {
    final CountdownController countdownController =
        Get.put(CountdownController());
    final MusicController musicController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      musicController.playMusicOnScreen5();
    });
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
                                selectMode(initialMode[index],
                                    winLengthMode[index], index);
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
                              'Pick a hero for Bot',
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

                    // Phần chọn độ khó
                    const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pick a Level',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CircleAvatar(
                        radius: 50,
                        child: Image.asset(
                          GifsPath.androidGif,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              List.generate(difficultyTexts.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                selectDifficulty(index);
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
                                    difficultyTexts[index],
                                    style: const TextStyle(fontSize: 16),
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
                        const Text("Play"),
                        IconButton(
                          onPressed: () {
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
                              initializeBoard();
                              Get.toNamed("/singlePlayer");
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
