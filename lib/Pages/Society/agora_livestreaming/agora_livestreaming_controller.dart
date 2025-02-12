import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/live_sream_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/agora_livestreaming/livestream_doc_service.dart';

class AgoraLivestreamController extends GetxController {
  late final RtcEngine agoraEngine;
  LiveStreamService liveStreamService = LiveStreamService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? liveStreamSubscription;
  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  final RxBool isMicEnabled = true.obs;
  final RxBool isVideoEnabled = true.obs;
  final RxBool isSharingScreen = false.obs;

  final String channelId;
  final String userId;
  final String url;
  final bool isStreamer;
  final String streamId;

  AgoraLivestreamController({
    required this.channelId,
    required this.userId,
    required this.url,
    required this.isStreamer,
    required this.streamId,
  });

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    if (isStreamer) {
      stopScreenSharing();
    }
    _disposeAgora();
    liveStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initialize() async {
    await _initializeAgora();
    await _joinChannel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToForestoreLiveStreamEvent();
    });
  }

  // 2.1. Khởi tạo Agora Engine
  Future<void> _initializeAgora() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(
       RtcEngineContext(appId: apiAgoraAppId),
    );
    await agoraEngine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    if (isStreamer) {
      await agoraEngine.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster);
      await agoraEngine.enableAudio();
      await agoraEngine.enableVideo();
    } else {
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  // 2.2. Tham gia phòng livestream
  Future<void> _joinChannel() async {
    final int intUserId = int.parse(_extractNumbers(userId));
    final expireTimestamp =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    final token = RtcTokenBuilder.build(
      appId: apiAgoraAppId,
      appCertificate: apiAgoraAppCertificate,
      channelName: channelId,
      uid: intUserId.toString(),
      role: isStreamer ? RtcRole.publisher : RtcRole.subscriber,
      expireTimestamp: expireTimestamp,
    );

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelId,
      uid: intUserId,
      options: ChannelMediaOptions(
        clientRoleType: isStreamer
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
      ),
    );
  }

  // 2.3. Bật chia sẻ màn hình (Host)
  Future<void> enableScreenSharing({required BuildContext context}) async {
    try {
      if (!isSharingScreen.value) {
        toggleVideo();
        await agoraEngine
            .setScreenCaptureScenario(ScreenScenarioType.screenScenarioGaming);
        const ScreenAudioParameters parametersAudioParams =
            ScreenAudioParameters(
          sampleRate: 100,
        );
        //todo: reposive screen sharing
        final FlutterView view = View.of(context);
        // final screenWidth = view.physicalSize.width.toInt();
        // final screenHeight = view.physicalSize.height.toInt();
        final int logicalWidth =
            (view.physicalSize.width / view.devicePixelRatio).toInt();
        final int logicalHeight =
            (view.physicalSize.height / view.devicePixelRatio).toInt();
        final VideoDimensions videoParamsDimensions = VideoDimensions(
          // width: 1280,
          // height: 720,
          width: logicalWidth,
          height: logicalHeight,
        );
        final ScreenVideoParameters parametersVideoParams =
            ScreenVideoParameters(
          dimensions: videoParamsDimensions,
          frameRate: 30,
          bitrate: 1000,
          contentHint: VideoContentHint.contentHintMotion,
        );
        final ScreenCaptureParameters2 parameters = ScreenCaptureParameters2(
          captureAudio: true,
          audioParams: parametersAudioParams,
          captureVideo: true,
          videoParams: parametersVideoParams,
        );

        await agoraEngine.startScreenCapture(parameters);

        isSharingScreen.value = true;
      } else {
        stopScreenSharing();
        toggleVideo();
      }
    } catch (e) {
      errorMessage("Failed to enable screen sharing: $e");
      isSharingScreen.value = false;
    }
  }

  // 2.4. Tắt chia sẻ màn hình
  Future<void> stopScreenSharing() async {
    if (isSharingScreen.value) {
      await agoraEngine.stopScreenCapture();
      isSharingScreen.value = false;
    }
  }

  // 2.6. Tắt mic
  void toggleMic() {
    isMicEnabled.toggle();
    agoraEngine.muteLocalAudioStream(!isMicEnabled.value);
  }

  void toggleVideo() {
    isVideoEnabled.toggle();
    agoraEngine.muteLocalVideoStream(!isVideoEnabled.value);
  }

  RxInt viewerCount = 1.obs;
  RxInt likeCount = 0.obs;
  RxList<Map<String, String>> comments = <Map<String, String>>[].obs;
  RxList<String> emojies = <String>[].obs;
  void _listenToForestoreLiveStreamEvent() {
    liveStreamSubscription = _firestore
        .collection('liveStreams')
        .doc(streamId)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        LiveStreamModel liveStreamModel =
            LiveStreamModel.fromJson(event.data()!);

        viewerCount.value = liveStreamModel.viewerCount ?? 1;

        likeCount.value = liveStreamModel.likeCount ?? 0;

        emojies.value = liveStreamModel.emotes ?? [];

        if (event.data()?['comments'] is Map) {
          comments.value = (event.data()?['comments'] as Map<String, dynamic>)
              .entries
              .map((entry) => {
                    "name": entry.value['name']?.toString() ?? '',
                    "photoUrl": entry.value['photoUrl']?.toString() ?? '',
                    "content": entry.value['content']?.toString() ?? '',
                    "gif": entry.value['gif']?.toString() ?? '',
                    "createdAt": entry.value['createdAt']?.toString() ?? '',
                  })
              .toList();

          comments.sort((a, b) {
            final timeA = DateTime.parse(a['createdAt']!);
            final timeB = DateTime.parse(b['createdAt']!);
            return timeA.compareTo(timeB);
          });
          _scrollToBottom();
        } else {
          comments.clear();
        }
      } else {
        errorMessage("Room is not existing");
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOut,
        );
        // _scrollController.jumpTo(
        //   _scrollController.position.maxScrollExtent,
        // );
      }
    });
  }

  // 2.8. Giải phóng Agora Engine
  Future<void> _disposeAgora() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.release();
  }

  String _extractNumbers(String userId) {
    return userId.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
