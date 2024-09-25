import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';

class MusicController extends GetxController {
  late AudioPlayer _audioPlayer; // Player cho màn hình 1-4
  late AudioPlayer _audioPlayerScreen5; // Player cho màn hình 5
  late AudioPlayer _audioPlayerScreen6; // Player cho màn hình 6
  late AudioPlayer _audioPlayerScreen7; // Player cho màn hình 7
  late AudioPlayer _audioPlayerScreen8; // Player cho màn hình 8
  late AudioPlayer _player;

  var isPlaying = false.obs;
  var currentTrackIndex = 0.obs;
  var isOnScreen5 = false.obs;
  var isOnScreen6 = false.obs;
  var isOnScreen7 = false.obs;
  var isOnScreen8 = false.obs;

  // Danh sách bài hát cho các màn hình 1-4
  final List<String> playlist = [AudioSPath.shinobuTheme];

  var volume = 1.0.obs; // Âm lượng

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer(); // Khởi tạo player cho màn hình 1-4
    _audioPlayerScreen5 = AudioPlayer(); // Khởi tạo player cho màn hình 5
    _audioPlayerScreen6 = AudioPlayer(); // Khởi tạo player cho màn hình 6
    _audioPlayerScreen7 = AudioPlayer(); // Khởi tạo player cho màn hình 7
    _audioPlayerScreen8 = AudioPlayer(); // Khởi tạo player cho màn hình 8
    _player = AudioPlayer();

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextTrack();
      }
    });

    _audioPlayer.setVolume(volume.value); // Cài đặt âm lượng ban đầu
  }

  // Thiết lập danh sách phát cho các màn hình 1-4
  Future<void> _setupPlaylist(List<String> playlist) async {
    List<AudioSource> audioSourceList = playlist.map((track) {
      return AudioSource.asset(track);
    }).toList();
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: audioSourceList),
      initialIndex: currentTrackIndex.value,
    );
  }

  // Phát nhạc cho màn hình 1-4
  void playMusic(List<String> playlist) async {
    if (!isOnScreen5.value &&
        !isOnScreen6.value &&
        !isOnScreen7.value &&
        !isOnScreen8.value) {
      // await _audioPlayerScreen5.setLoopMode(LoopMode.all);
      await _setupPlaylist(playlist);
      await _audioPlayer.play();
      isPlaying.value = true;
    }
  }

  // Dừng nhạc cho màn hình 1-4
  void pauseMusic() async {
    if (!isOnScreen5.value &&
        !isOnScreen6.value &&
        !isOnScreen7.value &&
        !isOnScreen8.value) {
      await _audioPlayer.pause();
      isPlaying.value = false;
    }
  }

  // Dừng nhạc hoàn toàn cho màn hình 1-4
  void stopMusic() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
  }

  // Cài đặt âm lượng
  void setVolume(double newVolume) async {
    volume.value = newVolume;
    await _audioPlayer.setVolume(newVolume);
  }

  // Phát bài tiếp theo trong danh sách (màn hình 1-4)
  void _playNextTrack() async {
    if (currentTrackIndex.value < playlist.length - 1) {
      currentTrackIndex.value++;
    } else {
      currentTrackIndex.value = 0; // Lặp lại từ đầu nếu hết danh sách
    }
    await _audioPlayer.seek(Duration.zero, index: currentTrackIndex.value);
    // playMusic();
  }

  // Phát nhạc cho màn hình 5
  void playMusicOnScreen5() async {
    isOnScreen5.value = true;
    setVolume(0.0);
    await _audioPlayerScreen5.setAsset(AudioSPath.blindPick);
    await _audioPlayerScreen5.setLoopMode(LoopMode.off);
    await _audioPlayerScreen5.play();
  }

  // Dừng nhạc ở màn hình 5 và quay lại màn hình 1-4
  void stopMusicOnScreen5() async {
    await _audioPlayerScreen5.stop(); // Dừng nhạc màn hình 5
    isOnScreen5.value = false;
    setVolume(1.0);
  }

  // Phát nhạc cho màn hình 6
  void playMusicOnScreen6() async {
    isOnScreen6.value = true;
    setVolume(0.0);
    await _audioPlayerScreen6.setAsset(AudioSPath.welcomeSound);
    await _audioPlayerScreen6.setLoopMode(LoopMode.off);
    await _audioPlayerScreen6.play();
    await Future.delayed(const Duration(seconds: 5));
    stopMusicOnScreen6();
  }

  // Dừng nhạc ở màn hình 6 và quay lại màn hình 1-4
  void stopMusicOnScreen6() async {
    await _audioPlayerScreen6.stop(); // Dừng nhạc màn hình 6
    isOnScreen6.value = false;
    setVolume(1.0);
  }

  // Phát nhạc cho màn hình 7
  void playMusicOnScreen7() async {
    stopMusicOnScreen8(0.0);
    isOnScreen7.value = true;
    await _audioPlayerScreen7.setAsset(AudioSPath.infinityCastle);
    await _audioPlayerScreen7.setLoopMode(LoopMode.all);
    await _audioPlayerScreen7.play();
  }

  // Dừng nhạc ở màn hình 7 và quay lại màn hình 1-4
  void stopMusicOnScreen7() async {
    await _audioPlayerScreen7.stop(); // Dừng nhạc màn hình 7
    isOnScreen7.value = false;
    setVolume(1.0);
  }

  void playMusicOnScreen8() async {
    isOnScreen8.value = true;
    setVolume(0.0);
    await _audioPlayerScreen8.setAsset(AudioSPath.matchingSound);
    await _audioPlayerScreen8.setLoopMode(LoopMode.off);
    await _audioPlayerScreen8.play();
  }

  void stopMusicOnScreen8(double volume) async {
    await _audioPlayerScreen8.stop();
    isOnScreen8.value = false;
    setVolume(volume);
  }

  //setup sound effect for button press in app
  Future<void> _playSound(String assetPath) async {
    await _player.setAsset(assetPath);
    _player.setLoopMode(LoopMode.off);
    _player.play();
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

  Future<void> swordSoundEffect() async {
    await _playSound(AudioSPath.swordEffect);
  }

  @override
  void onClose() {
    // _audioPlayer.dispose();
    _player.dispose();
    _audioPlayerScreen5.dispose();
    _audioPlayerScreen6.dispose();
    _audioPlayerScreen7.dispose();
    _audioPlayerScreen8.dispose();

    super.onClose();
  }
}
