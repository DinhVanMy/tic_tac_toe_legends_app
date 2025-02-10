import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/agora_livestreaming_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/create_livestream_room_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';

class WorldBlogPage extends StatelessWidget {
  final UserModel user;
  final ThemeData theme;
  const WorldBlogPage({super.key, required this.user, required this.theme});

  @override
  Widget build(BuildContext context) {
    final LiveStreamController liveStreamController =
        Get.put(LiveStreamController());
    final GlobalKey<RefreshIndicatorState> refreshIndicatorState =
        GlobalKey<RefreshIndicatorState>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => CreateLivestreamRoomPage(currentUser: user),
                    transition: Transition.leftToRightWithFade,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.redAccent,
                  padding: const EdgeInsets.all(5),
                  elevation: 5,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.live_tv_sharp,
                        size: 30,
                      ),
                      Text(
                        "Create your own live",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 30,
                      ),
                    ],
                  ),
                )),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (contex, index) {
                  return Container(
                    width: 100,
                    alignment: Alignment.center,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Cate $index"),
                  );
                },
              ),
            ),
            Expanded(
              child: Obx(() {
                if (liveStreamController.liveStreamsList.isEmpty) {
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  );
                } else {
                  var liveStreams =
                      liveStreamController.liveStreamsList.toList();
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent - 200) {
                        liveStreamController.fetchMoreLiveStreams();
                      }
                      return true;
                    },
                    child: RefreshIndicator(
                      key: refreshIndicatorState,
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      onRefresh: () async {
                        await liveStreamController.fetchInitialLiveStreams();
                      },
                      child: GridView.builder(
                          controller: liveStreamController.scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: liveStreams.length,
                          itemBuilder: (context, index) {
                            var liveStream = liveStreams[index];
                            var streamer = liveStream.streamer!;
                            return InkWell(
                              onTap: () async {
                                final LiveStreamService liveStreamService =
                                    LiveStreamService();
                                await liveStreamService
                                    .incrementViewerCount(liveStream.streamId!);
                                Get.to(
                                  () => AgoraLivestreamingPage(
                                    currentUser: user,
                                    channelId: liveStream.channelId!,
                                    isStreamer: false,
                                    liveStreamModel: liveStream,
                                  ),
                                  transition: Transition.zoom,
                                );
                              },
                              splashColor: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(
                                      base64Decode(
                                        liveStream.thumbnailUrl!,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  // border: Border.all(color: Colors.pinkAccent, width: 3),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 30,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "Live",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.visibility_rounded,
                                                    color: Colors.lightBlue,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    liveStream.viewerCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      color: Colors.lightBlue,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              AvatarUserWidget(
                                                radius: 20,
                                                imagePath: streamer.image!,
                                                borderThickness: 2,
                                                gradientColors: const [
                                                  Colors.white,
                                                  Colors.blueAccent
                                                ],
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    streamer.name!,
                                                    style: theme
                                                        .textTheme.bodyMedium!
                                                        .copyWith(
                                                      color: Colors
                                                          .lightBlueAccent,
                                                    ),
                                                  ),
                                                  Text(
                                                    liveStream.category ??
                                                        "Default",
                                                    style: const TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          liveStream.title!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.lightGreenAccent,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          liveStream.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.lightGreen,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            TimeFunctions.timeAgo(
                                                now: DateTime.now(),
                                                createdAt:
                                                    liveStream.createdAt!),
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .scale(duration: duration750)
                                .fadeIn(duration: duration750);
                          }),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
