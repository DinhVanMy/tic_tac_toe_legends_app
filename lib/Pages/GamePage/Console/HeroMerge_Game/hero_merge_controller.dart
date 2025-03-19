import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Data/fetch_firestore_database.dart';

class HeroMergeController extends GetxController {
  Rx<GameBoardModel> gameBoard =
      Rx<GameBoardModel>(GameBoardModel(rows: 0, columns: 0));
  RxInt score = 0.obs;
  Rx<BlockModel?> nextBlock = Rx<BlockModel?>(null); // Hero đang rơi
  Rx<BlockModel?> upcomingBlock =
      Rx<BlockModel?>(null); // Hero kế tiếp (preview)
  RxInt currentColumn = 0.obs;
  RxDouble blockPositionY = 0.0.obs;
  List<Map<String, dynamic>> previousState = [];
  RxBool isDragging = false.obs;
  RxBool isPaused = false.obs;
  Timer? dropTimer;
  Map<int, String> numberToHero = {};

  late int rows;
  late int columns;
  late int level;
  double containerHeight = 500.0;

  final FirestoreController firestoreController =
      Get.find<FirestoreController>();

  final Map<int, double> levelSpeeds = {
    1: 2.0,
    2: 4.0,
    3: 6.0,
    4: 8.0,
    5: 10.0,
  };

  final Map<int, List<int>> levelToValues = {
    1: [2, 4, 8, 16],
    2: [2, 4, 8, 16, 32],
    3: [2, 4, 8, 16, 32, 64],
    4: [2, 4, 8, 16, 32, 64, 128],
    5: [2, 4, 8, 16, 32, 64, 128, 256],
  };

  HeroMergeController({
    required this.rows,
    required this.columns,
    required this.level,
  }) {
    rows = rows.clamp(3, 10);
    columns = columns.clamp(3, 7);
    level = level.clamp(1, 5);
    _initializeHeroMapping();
    _initializeGame();
  }

  void _initializeHeroMapping() {
    numberToHero.clear();
    final random = Random();
    List<String> shuffledHeroes = List.from(listChampions)..shuffle(random);
    List<int> values = levelToValues[level]!;

    for (int i = 0; i < values.length; i++) {
      if (i < shuffledHeroes.length) {
        numberToHero[values[i]] = shuffledHeroes[i];
      } else {
        numberToHero[values[i]] =
            listChampions[random.nextInt(listChampions.length)];
      }
    }
    print("Initialized hero mapping for level $level: $numberToHero");
  }

  String getHeroForValue(int value) {
    if (!numberToHero.containsKey(value)) {
      final random = Random();
      numberToHero[value] = listChampions[random.nextInt(listChampions.length)];
      print(
          "Unexpected value $value not mapped, assigned random hero: ${numberToHero[value]}");
    }
    return numberToHero[value]!;
  }

  void _initializeGame() {
    dropTimer?.cancel();
    gameBoard.value = GameBoardModel(rows: rows, columns: columns);
    currentColumn.value = columns ~/ 2;
    score.value = 0;
    previousState.clear();
    nextBlock.value = null;
    upcomingBlock.value = null;
    isDragging.value = false;
    isPaused.value = false;
    blockPositionY.value = 0.0;
    _generateInitialBlocks();
  }

  void _generateInitialBlocks() {
    List<int> values = levelToValues[level]!;
    int nextValue = values[Random().nextInt(values.length)];
    int upcomingValue = values[Random().nextInt(values.length)];
    nextBlock.value =
        BlockModel(value: nextValue, hero: getHeroForValue(nextValue));
    upcomingBlock.value =
        BlockModel(value: upcomingValue, hero: getHeroForValue(upcomingValue));
    blockPositionY.value = 0.0;
    currentColumn.value = columns ~/ 2;
    isDragging.value = false;
    print(
        "Generated initial blocks - Next: ${nextBlock.value!.value}, ${nextBlock.value!.hero} | Upcoming: ${upcomingBlock.value!.value}, ${upcomingBlock.value!.hero}");
  }

  void _generateNextBlock() {
    nextBlock.value = upcomingBlock.value;
    List<int> values = levelToValues[level]!;
    int value = values[Random().nextInt(values.length)];
    upcomingBlock.value =
        BlockModel(value: value, hero: getHeroForValue(value));
    blockPositionY.value = 0.0;
    currentColumn.value = columns ~/ 2;
    isDragging.value = false;
    print(
        "Generated next block - Next: ${nextBlock.value!.value}, ${nextBlock.value!.hero} | Upcoming: ${upcomingBlock.value!.value}, ${upcomingBlock.value!.hero}");
  }

  void _startBlockDrop() {
    dropTimer?.cancel();
    double speed = levelSpeeds[level] ?? 2.0;
    dropTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isDragging.value && !isPaused.value) {
        blockPositionY.value += speed;
        if (blockPositionY.value >= containerHeight - 70) {
          _placeBlock();
          timer.cancel();
        }
      }
    });
  }

  void dragBlock(int newColumn) {
    if (newColumn >= 0 && newColumn < columns) {
      currentColumn.value = newColumn;
      isDragging.value = true;
    }
  }

  void releaseBlock() {
    isDragging.value = false;
    _placeBlock();
  }

  void tapToDrop(int columnIndex) {
    currentColumn.value = columnIndex;
    blockPositionY.value = containerHeight - 70;
    _placeBlock();
  }

  void _placeBlock() {
    savePreviousState();
    int col = currentColumn.value;
    int targetRow = -1;

    for (int row = 0; row < rows; row++) {
      if (gameBoard.value.grid[row][col].value == null) {
        targetRow = row;
        break;
      }
    }

    if (targetRow != -1) {
      gameBoard.value.grid[targetRow][col].value = nextBlock.value;
      _mergeColumn(col);
      gameBoard.refresh();
      _generateNextBlock();
      _startBlockDrop();
    } else if (isGameOver()) {
      _addCoinsOnGameOver();
      _showGameOverDialog();
    }
  }

  void _mergeColumn(int col) {
    bool hasMerged;
    do {
      hasMerged = false;
      List<BlockModel?> tempColumn =
          List.from(gameBoard.value.grid.map((row) => row[col].value));
      int writePos = 0;

      for (int readPos = 0; readPos < rows; readPos++) {
        if (tempColumn[readPos] == null) continue;

        if (writePos > 0 &&
            tempColumn[writePos - 1] != null &&
            tempColumn[writePos - 1]!.value == tempColumn[readPos]!.value &&
            tempColumn[writePos - 1]!.hero == tempColumn[readPos]!.hero) {
          // Kiểm tra cả hero
          tempColumn[writePos - 1]!.value *= 2;
          tempColumn[writePos - 1]!.mergeCount = max(
                  tempColumn[writePos - 1]!.mergeCount,
                  tempColumn[readPos]!.mergeCount) +
              1;
          score.value += tempColumn[writePos - 1]!.value;
          hasMerged = true;
          tempColumn[readPos] = null;
          print(
              "Merged blocks: [${tempColumn[writePos - 1]!.value},${tempColumn[writePos - 1]!.mergeCount},${tempColumn[writePos - 1]!.hero}]");
        } else {
          tempColumn[writePos] = tempColumn[readPos];
          writePos++;
        }
      }

      for (int row = 0; row < rows; row++) {
        gameBoard.value.grid[row][col].value =
            row < writePos ? tempColumn[row] : null;
      }
      print(
          "Merged column $col: ${tempColumn.map((b) => b != null ? '${b.value},${b.mergeCount},${b.hero}' : 'null').toList()}");
    } while (hasMerged);
  }

  bool isGameOver() {
    for (int col = 0; col < columns; col++) {
      if (gameBoard.value.grid[rows - 1][col].value != null) return true;
    }
    return false;
  }

  void _addCoinsOnGameOver() async {
    int coinsEarned = (score.value ~/ 100) * 10;
    await firestoreController.incrementCoinsAndWins(coinsEarned);
  }

  void _showGameOverDialog() {
    int coinsEarned = (score.value ~/ 100) * 10;
    Get.defaultDialog(
      barrierDismissible: false,
      title: "Game Over",
      titleStyle: const TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("No more moves!", style: TextStyle(fontSize: 18)),
          Text("Score: ${score.value}", style: const TextStyle(fontSize: 16)),
          Text("Coins Earned: $coinsEarned",
              style: const TextStyle(fontSize: 16, color: Colors.green)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  refreshGame();
                  Get.back();
                },
                child: const Text("Play Again"),
              ),
              ElevatedButton(
                onPressed: () => Get.offAllNamed("/mainHome"),
                child: const Text("Exit"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void savePreviousState() {
    previousState.add({
      'gameBoard': Rx<GameBoardModel>(GameBoardModel.clone(gameBoard.value)),
      'nextBlock':
          nextBlock.value != null ? BlockModel.clone(nextBlock.value!) : null,
      'upcomingBlock': upcomingBlock.value != null
          ? BlockModel.clone(upcomingBlock.value!)
          : null,
      'blockPositionY': blockPositionY.value,
      'score': score.value,
    });
    if (previousState.length > 1) previousState.removeAt(0);
  }

  void undoMove() {
    if (previousState.isNotEmpty && !isPaused.value) {
      dropTimer?.cancel();
      var lastState = previousState.last;
      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          gameBoard.value.grid[row][col].value =
              lastState['gameBoard'].value.grid[row][col].value != null
                  ? BlockModel.clone(
                      lastState['gameBoard'].value.grid[row][col].value!)
                  : null;
        }
      }
      nextBlock.value = lastState['nextBlock'] != null
          ? BlockModel.clone(lastState['nextBlock'])
          : null;
      upcomingBlock.value = lastState['upcomingBlock'] != null
          ? BlockModel.clone(lastState['upcomingBlock'])
          : null;
      blockPositionY.value = lastState['blockPositionY'];
      score.value = lastState['score'];
      previousState.removeLast();
      gameBoard.refresh();
      _startBlockDrop();
    }
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
    if (isPaused.value) {
      dropTimer?.cancel();
      Get.dialog(
        AlertDialog(
          title: const Text("Paused",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  togglePause();
                },
                child: const Text("Resume"),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  refreshGame();
                },
                child: const Text("Restart"),
              ),
              ElevatedButton(
                onPressed: () => Get.offAllNamed("/mainHome"),
                child: const Text("Exit"),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      _startBlockDrop();
    }
  }

  void refreshGame() {
    dropTimer?.cancel();
    _initializeHeroMapping();
    _initializeGame();
    gameBoard.refresh();
    nextBlock.refresh();
    upcomingBlock.refresh();
    blockPositionY.value = 0.0;
    Future.microtask(() {
      _startBlockDrop();
      print(
          "RefreshGame: Animation started, blockPositionY=${blockPositionY.value}");
    });
  }

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => _startBlockDrop());
  }

  @override
  void onClose() {
    dropTimer?.cancel();
    super.onClose();
  }
}

class BlockModel {
  int value;
  int mergeCount;
  String hero;

  BlockModel({required this.value, this.mergeCount = 0, required this.hero});

  BlockModel.clone(BlockModel other)
      : value = other.value,
        mergeCount = other.mergeCount,
        hero = other.hero;
}

class GameBoardModel {
  List<List<Rx<BlockModel?>>> grid;
  int rows;
  int columns;

  GameBoardModel({required this.rows, required this.columns})
      : grid = List.generate(
            rows, (_) => List.generate(columns, (_) => Rx<BlockModel?>(null)));

  GameBoardModel.clone(GameBoardModel other)
      : rows = other.rows,
        columns = other.columns,
        grid = other.grid
            .map((row) => row
                .map((block) => block.value != null
                    ? Rx<BlockModel?>(BlockModel.clone(block.value!))
                    : Rx<BlockModel?>(null))
                .toList())
            .toList();
}
