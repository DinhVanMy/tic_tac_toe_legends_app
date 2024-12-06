import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/agora_end_of_call_lay.dart';

class AgoraCallController extends GetxController {
  late final RtcEngine agoraEngine;

  var friendUid = Rx<int?>(null);
  RxBool isRemmoteVideoEnabled = false.obs;
  var localNetworkQuality = ''.obs; // Chất lượng mạng của local user
  var remoteNetworkQuality = ''.obs; // Chất lượng mạng của remote user
  var remotePing = 0.obs;

  final RxBool isMicEnabled = false.obs;
  final RxBool isVideoEnabled = false.obs;
  final RxBool isAudioEnabled = true.obs;

  final String channelId;
  final String userId;
  final String url;

  AgoraCallController({
    required this.channelId,
    required this.userId,
    required this.url,
    required bool initialMicState,
    required bool initialVideoState,
  }) {
    isMicEnabled.value = initialMicState;
    isVideoEnabled.value = initialVideoState;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    disposeAgora();
    _stopCallTimer();
    super.onClose();
  }

  Future<void> _initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _joinChannel();
  }

  Future<void> _initAgoraRtcEngine() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: apiAgoraAppId));
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    await agoraEngine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.muteLocalAudioStream(!isMicEnabled.value);
    await agoraEngine.muteLocalVideoStream(!isVideoEnabled.value);
  }

  Future<void> _joinChannel() async {
    final int intUserId = int.parse(extractNumbers(userId));
    final expireTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
        3600; // Thời gian hết hạn trong giây

    final token = RtcTokenBuilder.build(
      appId: apiAgoraAppId,
      appCertificate: apiAgoraAppCertificate,
      channelName: channelId,
      uid: intUserId.toString(),
      role: RtcRole.publisher,
      expireTimestamp: expireTimestamp,
    );
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelId,
      uid: intUserId,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> disposeAgora() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
  }

  void _addAgoraEventHandlers() {
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) => errorMessage("error: $msg"),
        onUserJoined: (connection, remoteUid, elapsed) {
          friendUid.value = remoteUid;
          _startCallTimer();
        },
        onUserMuteVideo: (connection, remoteUid, muted) =>
            isRemmoteVideoEnabled.value = !muted,
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (reason == UserOfflineReasonType.userOfflineQuit) {
            Get.back();
            Get.dialog(
              Material(
                color: Colors.black,
                child: EndOfCallLay(
                  url: url,
                ),
              ),
              useSafeArea: false,
            );
          }
        },
        onNetworkQuality: (RtcConnection connection, int uid,
            QualityType txQuality, QualityType rxQuality) {
          if (uid == 0) {
            localNetworkQuality.value =
                'Uplink: ${_getQualityDescription(txQuality)} \n Downlink: ${_getQualityDescription(rxQuality)}';
          } else {
            remoteNetworkQuality.value =
                'Uplink: ${_getQualityDescription(txQuality)}  \n  Downlink: ${_getQualityDescription(rxQuality)}';
          }
        },
        onRemoteAudioStats:
            (RtcConnection connection, RemoteAudioStats stats) =>
                remotePing.value = stats.networkTransportDelay ?? 0,
        onConnectionLost: (connection) => errorMessage(
            "${connection.channelId}'s Connection is lost,please try again: ${connection.channelId}"),
      ),
    );
  }

  void toggleMicro() {
    isMicEnabled.toggle();
    agoraEngine.muteLocalAudioStream(!isMicEnabled.value);
  }

  void toggleAudio() {
    isAudioEnabled.toggle();
    agoraEngine.muteAllRemoteAudioStreams(!isAudioEnabled.value);
  }

  void toggleVideo() {
    isVideoEnabled.toggle();
    agoraEngine.muteLocalVideoStream(!isVideoEnabled.value);
  }

  void switchCamera() => agoraEngine.switchCamera();

  RxInt callDuration = 0.obs; // Thời gian cuộc gọi (giây)
  Timer? _callTimer; // Bộ đếm thời gian

  void _startCallTimer() {
    _callTimer?.cancel(); // Hủy timer trước đó nếu tồn tại
    _callTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      callDuration.value++;
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel(); // Hủy timer khi kết thúc cuộc gọi
    _callTimer = null;
  }

  String extractNumbers(String userId) {
    return userId.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _getQualityDescription(QualityType quality) {
    switch (quality) {
      case QualityType.qualityExcellent:
        return "Excellent";
      case QualityType.qualityGood:
        return "Good";
      case QualityType.qualityPoor:
        return "Poor";
      case QualityType.qualityBad:
        return "Bad";
      case QualityType.qualityUnknown:
        return "Very Bad";
      case QualityType.qualityDown:
        return "Down";
      default:
        return "Unknown";
    }
  }
}
