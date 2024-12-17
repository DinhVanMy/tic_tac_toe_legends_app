import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class AgoraPreviewController extends GetxController {
  // Variables to track the state of permissions
  RxBool isCameraPermissionGranted = false.obs;
  RxBool isMicrophonePermissionGranted = false.obs;
  
  // Variables to control camera and mic states
  RxBool isCameraOn = true.obs;
  RxBool isMicrophoneOn = true.obs;

  // Agora engine instance
  late RtcEngine agoraEngine;

  @override
  void onInit() {
    super.onInit();
    initializeAgoraEngine();
    checkPermissions();
  }

  // Initialize Agora RTC Engine
  Future<void> initializeAgoraEngine() async {
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: apiAgoraAppId));
  }

  // Check camera and microphone permissions
  Future<void> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted) {
      isCameraPermissionGranted.value = await Permission.camera.request().isGranted;
    } else {
      isCameraPermissionGranted.value = true;
    }

    if (!micStatus.isGranted) {
      isMicrophonePermissionGranted.value = await Permission.microphone.request().isGranted;
    } else {
      isMicrophonePermissionGranted.value = true;
    }
  }

  // Toggle camera
  void toggleCamera() {
    isCameraOn.value = !isCameraOn.value;
    agoraEngine.muteLocalVideoStream(!isCameraOn.value);
  }

  // Toggle microphone
  void toggleMicrophone() {
    isMicrophoneOn.value = !isMicrophoneOn.value;
    agoraEngine.muteLocalAudioStream(!isMicrophoneOn.value);
  }

  // Start preview
  Future<void> startPreview() async {
    if (isCameraPermissionGranted.value && isMicrophonePermissionGranted.value) {
      await agoraEngine.startPreview();
    } else {
      errorMessage("Please grant camera and microphone permissions to proceed.");
    }
  }

  // Stop preview
  Future<void> stopPreview() async {
    await agoraEngine.stopPreview();
  }

  @override
  void onClose() {
    agoraEngine.release();
    super.onClose();
  }
}
