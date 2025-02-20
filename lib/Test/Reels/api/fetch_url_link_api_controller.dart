import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Test/Reels/api/video_api_model.dart';
import 'package:tictactoe_gameapp/Test/Reels/api/video_player_preview_page.dart';

class VideoSelectionScreen extends StatelessWidget {
  const VideoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoController controller = Get.put(VideoController());
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        "Pick a Video",
        style: theme.textTheme.headlineMedium,
      )),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search video by title or description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (query) {
                  controller.updateSearchQuery(query);
                },
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.videoList.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        GifsPath.transitionGif,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              var videos = controller.filteredVideoList;
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!controller.isLoading.value &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    controller.fetchVideos();
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                            video.thumbnail.isNotEmpty
                                ? video.thumbnail
                                : videoPlaceholder,
                            errorBuilder: (context, error, stackTrace) {
                          return Image.asset(GifsPath.loadingGif,
                              width: 100, height: 80, fit: BoxFit.cover);
                        }, width: 100, height: 80, fit: BoxFit.cover),
                      ),
                      title: Text(
                        video.title,
                        style: theme.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        video.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      onTap: () async {
                        final result = await Get.to(
                            () => VideoPlayerPreviewPage(videoUrl: video.url));
                        if (result != null && result is String) {
                          Get.back(result: result);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class VideoController extends GetxController {
  var videoList = <VideoApiModel>[].obs;
  var isLoading = false.obs;
  int page = 1;

  // Biến lưu query tìm kiếm từ người dùng
  var searchQuery = ''.obs;

  @override
  void onInit() {
    fetchVideos();
    super.onInit();
  }

  Future<void> fetchVideos() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      var results = await Future.wait([
        fetchPexelsVideos(page),
        fetchPixabayVideos(page),
        fetchDailymotionVideos(page),
        fetchVimeoVideos(page),
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
    final url = Uri.parse("https://api.pexels.com/videos/popular?page=$page");
    final response =
        await http.get(url, headers: {'Authorization': pexelsApiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(
          data['videos'].map((video) => VideoApiModel(
                title: video['user']['name'],
                description: video['url'],
                thumbnail: video['image'],
                url: video['video_files'][0]['link'],
              )));
    }
    return [];
  }

  Future<List<VideoApiModel>> fetchPixabayVideos(int page) async {
    final url = Uri.parse(
        "https://pixabay.com/api/videos/?key=$pixabayApiKey&page=$page");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(data['hits'].map((video) => VideoApiModel(
            title: video['tags'],
            description: "Pixabay Video",
            thumbnail: video['picture_id'] != null
                ? "https://i.vimeocdn.com/video/${video['picture_id']}_295x166.jpg"
                : videoPlaceholder,
            url: video['videos']['medium']['url'],
          )));
    }
    return [];
  }

  Future<List<VideoApiModel>> fetchDailymotionVideos(int page) async {
    final url = Uri.parse(
        "https://api.dailymotion.com/videos?fields=title,thumbnail_240_url,url&limit=10&page=$page");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(data['list'].map((video) => VideoApiModel(
            title: video['title'],
            description: "Dailymotion Video",
            thumbnail: video['thumbnail_240_url'],
            url: video['url'],
          )));
    }
    return [];
  }

  /// Fetch video từ Vimeo
  Future<List<VideoApiModel>> fetchVimeoVideos(int page) async {
    final url =
        Uri.parse("https://api.vimeo.com/videos?page=$page&per_page=10");
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $vimeoApiKey',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<VideoApiModel>.from(data['data'].map((video) => VideoApiModel(
            title: video['name'] ?? 'Vimeo Video',
            description: video['description'] ?? 'Vimeo Video',
            thumbnail: video['pictures'] != null &&
                    video['pictures']['sizes'] != null &&
                    (video['pictures']['sizes'] as List).isNotEmpty
                ? video['pictures']['sizes'][0]['link']
                : '',
            url: video['link'] ?? '',
          )));
    }
    return [];
  }

  /// Fetch video từ api.video (giả định dùng sandbox endpoint)
  Future<List<VideoApiModel>> fetchApiVideoVideos(int page) async {
    final url =
        Uri.parse("https://sandbox.api.video/videos?page=$page&limit=10");
    final response =
        await http.get(url, headers: {'Authorization': apiVideoApiKey});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Giả sử response trả về dạng list của video
      return List<VideoApiModel>.from(
          (data as List).map((video) => VideoApiModel(
                title: video['title'] ?? 'api.video Video',
                description: video['description'] ?? 'api.video Video',
                thumbnail: video['thumbnail'] ?? '',
                url: video['playerUrl'] ?? '',
              )));
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

  /// Hàm hỗ trợ so khớp các từ theo thứ tự (ordered matching)
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
