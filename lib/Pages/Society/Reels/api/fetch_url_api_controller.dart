import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/api/video_api_model.dart';

/// Ngưỡng làm mới dữ liệu mỗi ngày
const Duration randomizationThreshold = Duration(days: 1);
const String lastRandomizationKey = 'last_randomization_time';

class FetchUrlApiController extends GetxController {
  var videoList = <VideoApiModel>[].obs;
  var isLoading = false.obs;
  int page = 1; // Sử dụng cho chế độ pagination khi không refresh toàn bộ
  var searchQuery = ''.obs;

  final GetStorage storage = GetStorage();
  final Random random = Random();

  @override
  void onInit() {
    super.onInit();
    _checkAndRefreshData();
  }

  /// Kiểm tra xem đã đủ thời gian làm mới (1 ngày) chưa.
  bool get _shouldRandomize {
    int? lastRandomMillis = storage.read(lastRandomizationKey);
    if (lastRandomMillis == null) return true;
    final lastRandom = DateTime.fromMillisecondsSinceEpoch(lastRandomMillis);
    return DateTime.now().difference(lastRandom) >= randomizationThreshold;
  }

  /// Làm mới dữ liệu khi đủ thời gian
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

  /// Kiểm tra khi khởi tạo: nếu chưa có dữ liệu hoặc đã đủ thời gian refresh, fetch mới.
  Future<void> _checkAndRefreshData() async {
    if (_shouldRandomize) {
      clearData();
      await fetchVideos();
      storage.write(
          lastRandomizationKey, DateTime.now().millisecondsSinceEpoch);
    } else if (videoList.isEmpty) {
      await fetchVideos();
    }
  }

  /// Xóa dữ liệu cũ và reset biến page
  void clearData() {
    videoList.clear();
    page = 1;
  }

  /// Fetch dữ liệu từ Pexels và Pixabay cùng lúc.
  /// Mỗi lần fetch, gọi 5 trang (pagesToFetch = 5).
  Future<void> fetchVideos() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      const int pagesToFetch = 5; // Số trang fetch mỗi lần gọi
      List<Future<List<VideoApiModel>>> pexelsFutures = List.generate(
          pagesToFetch,
          (i) => _shouldRandomize
              ? fetchPexelsVideos(_randomPage())
              : fetchPexelsVideos(page + i));
      List<Future<List<VideoApiModel>>> pixabayFutures = List.generate(
          pagesToFetch,
          (i) => _shouldRandomize
              ? fetchPixabayVideos(_randomPage())
              : fetchPixabayVideos(page + i));

      var results = await Future.wait([...pexelsFutures, ...pixabayFutures]);
      var newVideos = results.expand((list) => list).toList();
      newVideos.shuffle(random); // Trộn danh sách để đảm bảo ngẫu nhiên
      videoList.addAll(newVideos);
      // Nếu không làm mới toàn bộ, tăng page; nếu làm mới, ta không cần dựa vào page
      if (!_shouldRandomize) {
        page += pagesToFetch;
      }
    } catch (e) {
      print("Error fetching videos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Hàm sinh số trang ngẫu nhiên dựa trên giới hạn của API (ví dụ: 1 đến 50)
  int _randomPage() {
    return random.nextInt(50) + 1;
  }

  /// Fetch video từ Pexels theo trang
  Future<List<VideoApiModel>> fetchPexelsVideos(int page) async {
    final url = Uri.parse("https://api.pexels.com/videos/popular?page=$page");
    final response =
        await http.get(url, headers: {'Authorization': pexelsApiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(
        (data['videos'] as List).map((video) => VideoApiModel(
              title: video['user']['name'] ?? 'Pexels Video',
              description: video['url'] ?? '',
              thumbnail: video['image'] ?? '',
              url: video['video_files'][0]['link'] ?? '',
            )),
      );
    }
    return [];
  }

  /// Fetch video từ Pixabay theo trang
  Future<List<VideoApiModel>> fetchPixabayVideos(int page) async {
    final url = Uri.parse(
        "https://pixabay.com/api/videos/?key=$pixabayApiKey&page=$page");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(
        (data['hits'] as List).map((video) => VideoApiModel(
              title: video['tags'] ?? 'Pixabay Video',
              description: "Pixabay Video",
              thumbnail: video['picture_id'] != null
                  ? "https://i.vimeocdn.com/video/${video['picture_id']}_295x166.jpg"
                  : videoPlaceholder,
              url: video['videos']['medium']['url'] ?? '',
            )),
      );
    }
    return [];
  }

  /// Cập nhật query tìm kiếm
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Lọc danh sách video theo query nhập từ người dùng
  List<VideoApiModel> get filteredVideoList {
    if (searchQuery.value.trim().isEmpty) return videoList;
    return videoList.where((video) {
      return _matchOrdered(video.title, searchQuery.value) ||
          _matchOrdered(video.description, searchQuery.value);
    }).toList();
  }

  /// Hàm so khớp từ khóa theo thứ tự (ordered matching)
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
