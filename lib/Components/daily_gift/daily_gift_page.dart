import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/daily_reward_controller.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/reward_model.dart';

class DailyRewardPage extends StatelessWidget {
  const DailyRewardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyRewardController controller = Get.put(DailyRewardController());
    const List<String> heroGifts = [
      ChampionsPathA.ahri,
      ChampionsPathA.akali,
      ChampionsPathA.aphelios,
      ChampionsPathA.annie,
    ];
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 400,
            width: 400,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurpleAccent]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 10, color: Colors.blueAccent),
            ),
            child: Column(
              children: [
                const Text(
                  "Return tomorrow for the next reward!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 3.0,
                ),
                Expanded(
                  child: Obx(() {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: controller.rewards.length,
                      itemBuilder: (context, index) {
                        final reward = controller.rewards[index];
                        final isToday = controller.isToday(reward.date);
                        final isPast = controller.isPast(reward.date);
                        Color backgroundColor;
                        if (isToday) {
                          backgroundColor = Colors.blue; // Ngày hiện tại
                        } else if (isPast) {
                          backgroundColor = Colors.grey[400]!; // Ngày trước đó
                        } else {
                          backgroundColor =
                              Colors.lightGreen; // Ngày trong tương lai
                        }
                        return GestureDetector(
                          onTap: () async {
                            if (!reward.isCollected && isToday) {
                              await controller.collectReward(index);
                              successMessage(
                                  "Congratulation! You received ${reward.date.day}");
                            } else if (reward.isCollected) {
                              errorMessage(
                                  "You've already collected this reward!");
                            } else {
                              errorMessage(
                                  "This reward is not available today!");
                            }
                          },
                          child: reward.isCollected
                              ? ClipRect(
                                  clipBehavior: Clip.antiAlias,
                                  child: Banner(
                                      message: "Done",
                                      location: BannerLocation.topStart,
                                      color: Colors.blueAccent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: reward.isCollected
                                              ? Colors.blueGrey
                                              : backgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: isToday
                                              ? Border.all(
                                                  color: reward.isCollected
                                                      ? Colors.redAccent
                                                      : Colors.white,
                                                  width: 4)
                                              : null,
                                        ),
                                        child: reward.rewardType ==
                                                RewardType.coin
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${reward.date.day}00",
                                                    style: const TextStyle(
                                                      color:
                                                          Colors.yellowAccent,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                    IconsPath.coinIcon,
                                                    colorFilter:
                                                        const ColorFilter
                                                            .linearToSrgbGamma(),
                                                  )
                                                ],
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  heroGifts[
                                                      index % heroGifts.length],
                                                  fit: BoxFit.cover,
                                                  width: 20,
                                                ),
                                              ),
                                      )),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: reward.isCollected
                                        ? Colors.blueGrey
                                        : backgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isToday
                                        ? Border.all(
                                            color: reward.isCollected
                                                ? Colors.redAccent
                                                : Colors.white,
                                            width: 4)
                                        : null,
                                  ),
                                  child: reward.rewardType == RewardType.coin
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${reward.date.day}00",
                                              style: const TextStyle(
                                                color: Colors.yellowAccent,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                              IconsPath.coinIcon,
                                              colorFilter: const ColorFilter
                                                  .linearToSrgbGamma(),
                                            )
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            heroGifts[index % heroGifts.length],
                                            fit: BoxFit.cover,
                                            width: 20,
                                          ),
                                        ),
                                ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -15,
            left: 130,
            right: 130,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: 2.0,
                      color: Colors.greenAccent,
                      blurRadius: 15.0,
                      offset: Offset(3, 3),
                    ),
                    BoxShadow(
                      spreadRadius: 2.0,
                      color: Colors.greenAccent,
                      blurRadius: 15.0,
                      offset: Offset(-3, -3),
                    ),
                  ]),
              child: const Text(
                "Claim",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            left: 50,
            right: 50,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: const Text(
                    "Reward Calendar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: -30,
                  left: 50,
                  right: 50,
                  child: Container(
                    alignment: Alignment.center,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent[400],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Obx(() => Text(
                          "${controller.today.value.day.toString()}-${controller.today.value.month.toString()}-${controller.today.value.year.toString()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -30,
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
      ),
    );
  }
}
