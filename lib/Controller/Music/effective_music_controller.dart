import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class EffectiveMusicController extends GetxController {
  late AudioPlayer _player;

  @override
  void onInit() {
    super.onInit();
    _player = AudioPlayer();
    _player.setLoopMode(LoopMode.off);
  }

  // Hàm chung để phát âm thanh
  Future<void> _playSound(String assetPath, Duration duration) async {
    try {
      if (_player.playing) {
        await _player.stop();
      }

      await _player.setAsset(assetPath); // Load file nhạc
      _player.play(); // Phát nhạc

      await Future.delayed(duration);
      _player.stop();
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  // Hàm phát nhạc 1
  Future<void> playSoundPlayer1() async {
    await _playSound(
      AudioSPath.coins,
      const Duration(milliseconds: 500),
    );
  }

  // Hàm phát nhạc 2
  Future<void> playSoundPlayer2() async {
    await _playSound(
      AudioSPath.nakime,
      const Duration(milliseconds: 700),
    );
  }

  // Hàm phát nhạc 3
  Future<void> playSoundWinner() async {
    await _playSound(
      AudioSPath.victory,
      const Duration(seconds: 1),
    );
  }

  Future<void> playSoundLoser() async {
    await _playSound(
      AudioSPath.defeat,
      const Duration(seconds: 1),
    );
  }

  // Future<void> playSoundPlayer3() async {
  //   await _player.setAsset(AudioSPath.coins); // Load file nhạc
  //     _player.play(); // Phát nhạc
  // }
  // Future<void> playSoundPlayer4() async {
  //   await _player.setAsset(AudioSPath.coins); // Load file nhạc
  //     _player.play(); // Phát nhạc
  // }

  // @override
  // void onClose() {
  //   _player.dispose();
  //   super.onClose();
  // }
}
