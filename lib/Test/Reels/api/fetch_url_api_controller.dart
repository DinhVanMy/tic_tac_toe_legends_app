import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Test/Reels/api/video_api_model.dart';

// Các hằng số cấu hình thời gian random (ở đây dùng 10s để dễ test)
const Duration randomizationThreshold = Duration(hours: 1);
const String lastRandomizationKey = 'last_randomization_time';

class FetchUrlApiController extends GetxController {
  var videoList = <VideoApiModel>[].obs;
  var isLoading = false.obs;
  int page = 1;
  // Biến lưu query tìm kiếm từ người dùng
  var searchQuery = ''.obs;

  final GetStorage storage = GetStorage();
  final Random random = Random();

  @override
  void onInit() {
    super.onInit();
    _checkAndRefreshData();
  }

  /// Kiểm tra xem đã đủ ngưỡng random chưa (ở đây 10s)
  bool get _shouldRandomize {
    int? lastRandomMillis = storage.read(lastRandomizationKey);
    if (lastRandomMillis == null) return true;
    final lastRandom = DateTime.fromMillisecondsSinceEpoch(lastRandomMillis);
    return DateTime.now().difference(lastRandom) >= randomizationThreshold;
  }

  /// Khi đủ thời gian, clear data và fetch dữ liệu mới với random, cập nhật timestamp.
  Future<void> refreshData() async {
    if (_shouldRandomize) {
      clearData();
      await fetchVideos();
      await storage.write(
          lastRandomizationKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      print("Dữ liệu vẫn mới, không cần refresh.");
    }
  }

  /// Kiểm tra tự động khi khởi chạy
  Future<void> _checkAndRefreshData() async {
    if (videoList.isEmpty || _shouldRandomize) {
      clearData();
      await fetchVideos();
      storage.write(
          lastRandomizationKey, DateTime.now().millisecondsSinceEpoch);
    } else {
      await fetchVideos();
    }
  }

  /// Xóa dữ liệu cũ và reset page
  void clearData() {
    videoList.clear();
    page = 1;
  }

  Future<void> fetchVideos() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      var results = await Future.wait([
        fetchPexelsVideos(page),
        fetchPixabayVideos(page),
        fetchDailymotionVideos(page),
      ]);
      videoList.addAll(results.expand((list) => list));
      page++;
    } catch (e) {
      print("Error fetching videos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<VideoApiModel>> fetchPexelsVideos(int page) async {
    bool randomize = _shouldRandomize;
    int pageToUse = randomize ? random.nextInt(50) + 1 : page;
    String randomParam = randomize ? "&_r=${random.nextInt(100000)}" : "";
    final url = Uri.parse(
        "https://api.pexels.com/videos/popular?page=$pageToUse$randomParam");
    final response =
        await http.get(url, headers: {'Authorization': pexelsApiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var list = List<VideoApiModel>.from(
        (data['videos'] as List).map((video) => VideoApiModel(
              title: video['user']['name'] ?? 'Pexels Video',
              description: video['url'] ?? '',
              thumbnail: video['image'] ?? '',
              url: video['video_files'][0]['link'] ?? '',
            )),
      );
      list.shuffle(random);
      return list;
    }
    return [];
  }

  Future<List<VideoApiModel>> fetchPixabayVideos(int page) async {
    bool randomize = _shouldRandomize;
    int pageToUse = randomize ? random.nextInt(50) + 1 : page;
    String randomParam = randomize ? "&_r=${random.nextInt(100000)}" : "";
    final url = Uri.parse(
        "https://pixabay.com/api/videos/?key=$pixabayApiKey&page=$pageToUse$randomParam");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var list = List<VideoApiModel>.from(
        (data['hits'] as List).map((video) => VideoApiModel(
              title: video['tags'] ?? 'Pixabay Video',
              description: "Pixabay Video",
              thumbnail: video['picture_id'] != null
                  ? "https://i.vimeocdn.com/video/${video['picture_id']}_295x166.jpg"
                  : videoPlaceholder,
              url: video['videos']['medium']['url'] ?? '',
            )),
      );
      list.shuffle(random);
      return list;
    }
    return [];
  }

  Future<List<VideoApiModel>> fetchDailymotionVideos(int page) async {
    bool randomize = _shouldRandomize;
    int pageToUse = randomize ? random.nextInt(50) + 1 : page;
    String randomParam = randomize ? "&_r=${random.nextInt(100000)}" : "";
    final url = Uri.parse(
        "https://api.dailymotion.com/videos?fields=id,title,thumbnail_240_url&limit=10&page=$pageToUse$randomParam");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List videosList = data['list'];
      List<Future<VideoApiModel?>> futures =
          videosList.map<Future<VideoApiModel?>>((video) async {
        String videoId = video['id'];
        String title = video['title'] ?? 'Dailymotion Video';
        String thumbnail = video['thumbnail_240_url'] ?? '';
        final metaUrl = Uri.parse(
            "https://www.dailymotion.com/player/metadata/video/$videoId?embedder=");
        final metaResponse = await http.get(metaUrl);
        if (metaResponse.statusCode == 200) {
          final metaData = json.decode(metaResponse.body);
          if (metaData['qualities'] != null && metaData['qualities'] is Map) {
            Map qualities = metaData['qualities'];
            String directUrl = '';
            if (qualities.containsKey("auto")) {
              List autoQuality = qualities["auto"];
              if (autoQuality.isNotEmpty && autoQuality[0]['url'] != null) {
                directUrl = autoQuality[0]['url'];
              }
            } else {
              for (var key in qualities.keys) {
                List qualityList = qualities[key];
                if (qualityList.isNotEmpty && qualityList[0]['url'] != null) {
                  directUrl = qualityList[0]['url'];
                  break;
                }
              }
            }
            if (directUrl.isNotEmpty) {
              return VideoApiModel(
                title: title,
                description: "Dailymotion Video",
                thumbnail: thumbnail,
                url: directUrl,
              );
            }
          }
        }
        return null;
      }).toList();
      final results = await Future.wait(futures);
      var list = results.whereType<VideoApiModel>().toList();
      list.shuffle(random);
      return list;
    }
    return [];
  }

  /// Cập nhật search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Danh sách video đã được lọc theo search query
  List<VideoApiModel> get filteredVideoList {
    if (searchQuery.value.trim().isEmpty) return videoList;
    return videoList.where((video) {
      return _matchOrdered(video.title, searchQuery.value) ||
          _matchOrdered(video.description, searchQuery.value);
    }).toList();
  }

  /// Hàm so khớp các từ theo thứ tự
  bool _matchOrdered(String text, String query) {
    final words = query
        .toLowerCase()
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .toList();
    int lastIndex = 0;
    for (final word in words) {
      final index = text.toLowerCase().indexOf(word, lastIndex);
      if (index == -1) return false;
      lastIndex = index + word.length;
    }
    return true;
  }
}
