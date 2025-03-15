import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/Agoras_widget/agora_background_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/Agoras_widget/beauty_filter_option_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/agora_call_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraCallPage extends StatelessWidget {
  final UserModel userFriend;
  final UserModel userCurrent;
  final String channelId;
  final bool initialMicState;
  final bool initialVideoState;

  const AgoraCallPage({
    super.key,
    required this.userFriend,
    required this.userCurrent,
    required this.initialMicState,
    required this.initialVideoState,
    required this.channelId,
  });

  @override
  Widget build(BuildContext context) {
    final AgoraCallController agoraCallController = Get.put(
      AgoraCallController(
        userId: userCurrent.id!,
        channelId: channelId,
        url: userFriend.image!,
        initialMicState: initialMicState,
        initialVideoState: initialVideoState,
      ),
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () => agoraCallController.isExtendIcons.value = true,
        child: Stack(
          children: [
            Obx(() {
              //video of the remote user
              return agoraCallController.friendUid.value != null &&
                      agoraCallController.isRemmoteVideoEnabled.value == true
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: agoraCallController.agoraEngine,
                        canvas: VideoCanvas(
                            uid: agoraCallController.friendUid.value),
                        connection: RtcConnection(
                          channelId: channelId,
                        ),
                      ),
                    ).animate().fadeIn(duration: const Duration(seconds: 1))
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
            }),
            // Video của User 1 (Góc trên bên phải)
            Positioned(
              top: 70,
              right: 10,
              child: Obx(() {
                return Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent, width: 3),
                  ),
                  child: agoraCallController.isVideoEnabled.value
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: agoraCallController.agoraEngine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        )
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 1000))
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: Text(
                              'Your video is off',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                );
              }),
            ),
            // Back và menu phía trên

            Positioned(
              top: 20,
              left: 5,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.deepPurpleAccent,
                      size: 35,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              TimeFunctions.displayTimeCount(
                                  agoraCallController.callDuration.value),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.deepPurpleAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        Obx(() => Text(
                              'Ping: ${agoraCallController.remotePing.value} ms',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _getPingColor(
                                      agoraCallController.remotePing.value)),
                            )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _getPingIcon(agoraCallController.remotePing.value),
                      color:
                          _getPingColor(agoraCallController.remotePing.value),
                      size: 35,
                    ),
                    onPressed: () {
                      Get.dialog(_networkInfoDialog(agoraCallController));
                    },
                  ),
                ],
              ),
            ),
            // Avatar và thông tin bạn bè
            Obx(() => agoraCallController.isRemmoteVideoEnabled.value == false
                ? Positioned(
                    top: 200,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        AvatarUserWidget(
                          radius: 100,
                          imagePath: userFriend.image!,
                          gradientColors: userFriend.avatarFrame ??
                              ["#FF4CAF50", "#FF81C784"],
                          borderThickness: 5,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userFriend.name!,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Calling...",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()),
            // Nút điều khiển phía dưới
            Obx(() => agoraCallController.isExtendIcons.value
                ? Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Obx(
                          () => agoraCallController.isVideoEnabled.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Obx(() => IconButton(
                                          icon: agoraCallController
                                                  .isEnableFaceDetection.value
                                              ? const Icon(
                                                  Icons
                                                      .face_retouching_natural_rounded,
                                                  color: Colors.blueAccent,
                                                  size: 35,
                                                )
                                              : const Icon(
                                                  Icons
                                                      .face_retouching_off_rounded,
                                                  color: Colors.blueAccent,
                                                  size: 35,
                                                ),
                                          onPressed: () async {
                                            await agoraCallController
                                                .toggleFaceDetection();
                                          },
                                        )),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.tips_and_updates,
                                        color: Colors.blueAccent,
                                        size: 35,
                                      ),
                                      onPressed: () async {
                                        await GeneralBottomsheetShowFunction
                                            .showScrollableGeneralBottomsheet(
                                          widgetBuilder:
                                              (context, controller) =>
                                                  BeautyFiltersSheet(
                                            agoraEngine:
                                                agoraCallController.agoraEngine,
                                          ),
                                          context: context,
                                          initHeight: 0.5,
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.mode_edit_outlined,
                                        color: Colors.blueAccent,
                                        size: 35,
                                      ),
                                      onPressed: () async {
                                        await GeneralBottomsheetShowFunction
                                            .showScrollableGeneralBottomsheet(
                                          widgetBuilder:
                                              (context, controller) =>
                                                  AgoraBackgroundSheet(
                                            scrollController: controller,
                                            imageAvatar: userCurrent.image!,
                                          ),
                                          context: context,
                                          initHeight: 0.9,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Obx(() =>
                                  !agoraCallController.isVideoEnabled.value
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.videocam_off_sharp,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                          onPressed: () {
                                            agoraCallController.toggleVideo();
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                          onPressed: () {
                                            agoraCallController.toggleVideo();
                                          },
                                        )),
                              Obx(() => !agoraCallController.isMicEnabled.value
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.mic_off_rounded,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        agoraCallController.toggleMicro();
                                      },
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        agoraCallController.toggleMicro();
                                      },
                                    )),
                              IconButton(
                                icon: const Icon(
                                  Icons.switch_camera_rounded,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                onPressed: () {
                                  agoraCallController.switchCamera();
                                },
                              ),
                              IconButton(
                                  onPressed: () {
                                    agoraCallController.toggleAudio();
                                  },
                                  icon: Obx(() =>
                                      agoraCallController.isAudioEnabled.value
                                          ? const Icon(
                                              Icons.volume_down,
                                              color: Colors.white,
                                              size: 35,
                                            )
                                          : const Icon(
                                              Icons.volume_off_rounded,
                                              color: Colors.white,
                                              size: 35,
                                            ))),
                              IconButton(
                                icon: const Icon(
                                  Icons.phone_disabled_rounded,
                                  color: Colors.redAccent,
                                  size: 35,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().slide()
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _networkInfoDialog(AgoraCallController controller) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Network Quality Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() => Text(
                  'You:\n${controller.localNetworkQuality.value}',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                )),
            const SizedBox(height: 10),
            Obx(() => Text(
                  'Your Friend:\n${controller.remoteNetworkQuality.value}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                )),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ).animate().slide();
  }

  Color _getPingColor(int ping) {
    if (ping >= 0 && ping < 100) {
      return Colors.lightGreenAccent;
    } else if (ping >= 100 && ping < 300) {
      return Colors.yellowAccent;
    } else if (ping >= 300 && ping < 500) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  IconData _getPingIcon(int ping) {
    if (ping >= 0 && ping < 100) {
      return Icons.wifi_rounded;
    } else if (ping >= 100 && ping < 300) {
      return Icons.network_wifi_3_bar_rounded;
    } else if (ping >= 300 && ping < 500) {
      return Icons.wifi_2_bar_rounded;
    } else {
      return Icons.wifi_password_rounded;
    }
  }
}
