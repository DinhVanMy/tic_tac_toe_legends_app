import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/room_model.dart';

class GameInfo extends StatelessWidget {
  final RoomModel roomData;
  const GameInfo({super.key, required this.roomData});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final ThemeData theme = Theme.of(context);
    return Container(
      height: w * 0.4,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "Map",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: w * 0.2,
                  width: w * 0.2,
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: roomData.pickedMap != null
                      ? Image.asset(
                          roomData.pickedMap!,
                        ).animate().scale(duration: duration750)
                      : Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: w * 0.15,
                        ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "Mode",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: w * 0.2,
                  width: w * 0.2,
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: roomData.imageMode != null
                      ? Image.asset(
                          roomData.imageMode!,
                        ).animate().scale(duration: duration750)
                      : Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: w * 0.15,
                        ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "Hero X",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: w * 0.2,
                  width: w * 0.2,
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: roomData.pickedMap != null
                      ? Image.asset(
                          roomData.champX!,
                        ).animate().scale(duration: duration750)
                      : Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: w * 0.15,
                        ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "Hero O",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: w * 0.2,
                  width: w * 0.2,
                  decoration: const BoxDecoration(color: Colors.grey),
                  child: roomData.pickedMap != null
                      ? Image.asset(roomData.champO!)
                          .animate()
                          .scale(duration: duration750)
                      : Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: w * 0.15,
                        ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "Coin",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: w * 0.2,
                  width: w * 0.2,
                  decoration: roomData.pickedMap != null
                      ? BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.yellow,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(100))
                      : const BoxDecoration(color: Colors.grey),
                  child: roomData.pickedMap != null
                      ? Center(
                          child: Text(
                            roomData.winningPrize!,
                            style: theme.textTheme.headlineLarge!
                                .copyWith(color: Colors.yellowAccent),
                          ),
                        ).animate().scale(duration: duration750)
                      : Icon(
                          Icons.question_mark,
                          color: Colors.white,
                          size: w * 0.15,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
