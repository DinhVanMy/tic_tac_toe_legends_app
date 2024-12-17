import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Pages/Friends/Widgets/Agoras_widget/beauty_filter_option_controller.dart';

class BeautyFiltersSheet extends StatelessWidget {
  final RtcEngine agoraEngine;
  const BeautyFiltersSheet({super.key, required this.agoraEngine});

  @override
  Widget build(BuildContext context) {
    final BeautyFiltersController controller =
        Get.put(BeautyFiltersController(agoraEngine: agoraEngine));
    return Column(
      children: [
        // Toggle Switch for enabling/disabling beauty filter
        Obx(() => SwitchListTile(
              activeColor: Colors.blue,
              title: const Text("Enable Beauty Filter"),
              value: controller.isEnabled.value,
              onChanged: (value) => controller.toggleEnable(value),
            )),
        // Lightening slider
        Obx(() => _buildSlider(
              label: "Lightening",
              value: controller.lighteningLevel.value,
              onChanged: controller.isEnabled.value
                  ? (value) => controller.updateLightening(value)
                  : null, // Disable interaction when isEnabled is false
              enabled: controller.isEnabled.value,
            )),
        // Smoothness slider
        Obx(() => _buildSlider(
              label: "Smoothness",
              value: controller.smoothnessLevel.value,
              onChanged: controller.isEnabled.value
                  ? (value) => controller.updateSmoothness(value)
                  : null,
              enabled: controller.isEnabled.value,
            )),
        // Redness slider
        Obx(() => _buildSlider(
              label: "Redness",
              value: controller.rednessLevel.value,
              onChanged: controller.isEnabled.value
                  ? (value) => controller.updateRedness(value)
                  : null,
              enabled: controller.isEnabled.value,
            )),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double>? onChanged,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.black : Colors.grey, // Change text color
            ),
          ),
          Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
            activeColor:
                enabled ? Colors.blue : Colors.grey, // Change active color
            inactiveColor: Colors.grey, // Set inactive color
          ),
        ],
      ),
    );
  }
}
