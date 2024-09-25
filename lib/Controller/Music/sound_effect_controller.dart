import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class SoundEffectController extends GetxController {
  late AudioPlayer _player;

  @override
  void onInit() {
    super.onInit();
    _player = AudioPlayer();
    _player.setLoopMode(LoopMode.off);
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      _player.play();
    } catch (e) {
      errorMessage(e.toString());
    }
  }
  Future<void> buttonSoundEffect() async {
    await _playSound(
      EffectingsPath.rippleEffect,
    );
  }
   Future<void> boosterSoundEffect() async {
    await _playSound(
      EffectingsPath.boosterEffect,
    );
  }
   Future<void> futuricSoundEffect() async {
    await _playSound(
      EffectingsPath.futuricEffect,
    );
  }
   Future<void> digitalSoundEffect() async {
    await _playSound(
      EffectingsPath.digitalEffect,
    );
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
