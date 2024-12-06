import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Models/general_notifications_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_notification_controller.dart';

class EditNotifyBottomsheet extends StatelessWidget {
  final ScrollController scrollController;
  final GeneralNotificationsModel likeNotification;
  final PostNotificationController postNotificationController;
  const EditNotifyBottomsheet(
      {super.key,
      required this.likeNotification,
      required this.scrollController,
      required this.postNotificationController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
                likeNotification.senderModel!.image!),
            radius: 30,
          ),
          Text(
            likeNotification.senderModel!.name!,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            likeNotification.message!,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 15,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            child: InkWell(
              splashColor: Colors.blueGrey,
              onTap: () async {
                Get.showOverlay(
                    asyncFunction: () async {
                      await postNotificationController
                          .turnOffNotify(likeNotification.postId!);
                    },
                    loadingWidget: Center(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: const SizedBox(),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              GifsPath.loadingGif,
                              height: 200,
                              width: 200,
                            ),
                          ),
                        ],
                      ),
                    ));
              },
              child: Obx(() => Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: postNotificationController.isNotifed.value
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        child: postNotificationController.isNotifed.value
                            ? const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                              )
                            : const Icon(Icons.notifications_off),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      postNotificationController.isNotifed.value
                          ? const Expanded(
                              child: Text(
                                "Turn off status update notifications for this ...",
                              ),
                            )
                          : const Expanded(
                              child: Text(
                                "Turn on status update notifications for this ...",
                              ),
                            ),
                    ],
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            child: InkWell(
              splashColor: Colors.blueGrey,
              onTap: () async {
                await postNotificationController
                    .deleteNotification(likeNotification.id!);
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: const Icon(Icons.delete),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(child: Text("Delete this notification")),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            child: InkWell(
              splashColor: Colors.blueGrey,
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: const Icon(Icons.report),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Expanded(child: Text("Report issue to the Boss")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
