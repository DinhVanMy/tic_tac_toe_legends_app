import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Controller/text_to_speech_controller.dart';

class TtsChangeSettingWidget extends StatelessWidget {
  final TextToSpeechController ttsController;
  const TtsChangeSettingWidget({super.key, required this.ttsController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () => SwitchListTile(
                  title: const Text("Echo Mode"),
                  value: ttsController.isEchoMode.value,
                  onChanged: (bool value) {
                    ttsController.isEchoMode.value = value;
                    if (value) {
                      ttsController.isAlexaMode.value = false;
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => SwitchListTile(
                  title: const Text("Alexa Mode"),
                  value: ttsController.isAlexaMode.value,
                  onChanged: (bool value) {
                    ttsController.isAlexaMode.value = value;
                    if (value) {
                      ttsController.isEchoMode.value = false;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Slider(
              value: ttsController.volume.value,
              onChanged: ttsController.setVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: "Volume: ${ttsController.volume.value}",
            )),
        Obx(() => Slider(
              value: ttsController.pitch.value,
              onChanged: ttsController.setPitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: "Pitch: ${ttsController.pitch.value}",
            )),
        Obx(() => Slider(
              value: ttsController.rate.value,
              onChanged: ttsController.setRate,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: "Rate: ${ttsController.rate.value}",
            )),
      ],
    );
  }
}
