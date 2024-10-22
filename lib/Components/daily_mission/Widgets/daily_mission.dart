import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Components/daily_mission/mission_controller.dart';

class DailyMissionPage extends StatelessWidget {
  final TaskController taskController;
  const DailyMissionPage({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (taskController.dailyTasks.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Get.showOverlay(
            asyncFunction: () async {
              await taskController.checkAndCreateDailyTasks();
            },
            loadingWidget: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            ),
          );
        });
      }
      var dailyTasks = taskController.dailyTasks.toList();
      return ListView.builder(
        itemCount: dailyTasks.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          var dailyTask = dailyTasks[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "+${dailyTask.reward}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SvgPicture.asset(
                      IconsPath.coinIcon,
                      width: 35,
                      colorFilter: const ColorFilter.linearToSrgbGamma(),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dailyTask.name,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.yellow),
                      ),
                      Text(
                        dailyTask.description,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade400,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: Colors.yellow, width: 3),
                            ),
                            child: Text(
                              "${dailyTask.progress} / ${dailyTask.goal}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            taskController.displayTime(dailyTask.deadline),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                dailyTask.status == "incomplete"
                    ? GestureDetector(
                        onTap: () {
                          taskController.updateTaskByFieldId(
                              taskFieldId: dailyTask.id);
                          successMessage("Congratulations!");
                        },
                        child: Container(
                          width: 70,
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blueAccent,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Go",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_double_arrow_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 70,
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.orange,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "OK!",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.done_all,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      );
    });
  }
}
