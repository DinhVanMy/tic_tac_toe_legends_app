import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/Widgets/daily_mission.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/Widgets/monthly_mission.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/Widgets/weekly_mission.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/mission_controller.dart';

class MissionsPage extends StatelessWidget {
  final String userId;
  const MissionsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController =
        Get.put(TaskController(userId: userId));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
            top: -150,
            left: 100,
            right: 100,
            child: Image.asset(
              TrimRanking.challTrim,
              width: 40,
            )),
        Container(
          height: 400,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Colors.purpleAccent, Colors.deepPurpleAccent]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 10, color: Colors.blueAccent),
          ),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const Text(
                  "Return tomorrow for the new missions!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TabBar(
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.blueGrey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.yellowAccent,
                  tabs: [
                    Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Daily",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Weekly",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Monthly",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      DailyMissionPage(taskController: taskController),
                      WeeklyMissionPage(taskController: taskController),
                      MonthlyMissionPage(taskController: taskController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: 50,
          right: 50,
          child: Container(
            alignment: Alignment.center,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: const Text(
              "Missions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -30,
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.cancel,
              size: 40,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }
}
