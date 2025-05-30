import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/api/fetch_url_api_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Reels/api/video_player_preview_page.dart';
import 'package:tictactoe_gameapp/Components/shimmers/urls_placeholder_widget.dart';

class VideoSelectionScreen extends StatelessWidget {
  const VideoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FetchUrlApiController controller = Get.put(FetchUrlApiController());
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick a Video", style: theme.textTheme.headlineMedium),
      ),
      body: Column(
        children: [
          // Search TextField
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
          // ListView hiển thị video kèm bottom loading indicator
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const UrlsPlaceholderWidget();
              } else {
                if (controller.videoList.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Video is unavailable? Retry",
                        style: theme.textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () => controller.fetchVideos(),
                        icon: const Icon(Icons.replay_circle_filled),
                        iconSize: 35,
                        color: Colors.blueAccent,
                      )
                    ],
                  );
                } else {
                  var videos = controller.filteredVideoList;
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      double remaining = scrollInfo.metrics.maxScrollExtent -
                          scrollInfo.metrics.pixels;
                      if (!controller.isLoading.value && remaining < 200) {
                        controller.fetchVideos();
                      }
                      return true;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await controller.refreshData();
                      },
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: videos.length +
                            (controller.isLoading.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Nếu index là cuối cùng, hiển thị bottom loading indicator
                          if (index == videos.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                color: Colors.white,
                              )),
                            );
                          }
                          final video = videos[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                video.thumbnail.isNotEmpty
                                    ? video.thumbnail
                                    : videoPlaceholder,
                                width: 100,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(GifsPath.loadingGif,
                                      width: 100,
                                      height: 80,
                                      fit: BoxFit.cover);
                                },
                              ),
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
                              final result = await Get.to(() =>
                                  VideoPlayerPreviewPage(videoUrl: video.url));
                              if (result != null && result is String) {
                                Get.back(result: result);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            }),
          ),
        ],
      ),
    );
  }
}
