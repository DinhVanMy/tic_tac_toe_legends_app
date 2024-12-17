import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class BeautyFiltersController extends GetxController {
  final RxBool isEnabled = false.obs;
  final RxDouble lighteningLevel = 0.5.obs;
  final RxDouble smoothnessLevel = 0.5.obs;
  final RxDouble rednessLevel = 0.1.obs;

  final RtcEngine agoraEngine;

  BeautyFiltersController({required this.agoraEngine});

  void applyBeautyFilter() {
    final beautyOptions = BeautyOptions(
      lighteningLevel: lighteningLevel.value,
      smoothnessLevel: smoothnessLevel.value,
      rednessLevel: rednessLevel.value,
    );

    agoraEngine.setBeautyEffectOptions(
      enabled: isEnabled.value,
      options: beautyOptions,
    );
  }

  void updateLightening(double value) {
    lighteningLevel.value = value;
    applyBeautyFilter();
  }

  void updateSmoothness(double value) {
    smoothnessLevel.value = value;
    applyBeautyFilter();
  }

  void updateRedness(double value) {
    rednessLevel.value = value;
    applyBeautyFilter();
  }

  void toggleEnable(bool value) {
    isEnabled.value = value;
    applyBeautyFilter();
  }
}
