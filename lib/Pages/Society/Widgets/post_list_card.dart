import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/comment_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/content_advance_widget.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';

class PostListCard extends StatelessWidget {
  final PostModel post;
  final UserModel postUser;
  final UserModel currentUser;
  final ThemeData theme;
  final PostController postController;
  const PostListCard({
    super.key,
    required this.post,
    required this.postUser,
    required this.theme,
    required this.postController,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(postUser.image!),
                radius: 20,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      postUser.name!,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Row(
                      children: [
                        Text(
                          postController.timeAgo(
                              now: DateTime.now(), createdAt: post.createdAt!),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (post.privacy == "Public")
                          const Icon(
                            Icons.public,
                            size: 23,
                            color: Colors.blueGrey,
                          ),
                        if (post.privacy == "Friends")
                          const Icon(
                            Icons.people_outline_outlined,
                            size: 23,
                            color: Colors.blueGrey,
                          ),
                        if (post.privacy == "Private")
                          const Icon(
                            Icons.lock,
                            size: 23,
                            color: Colors.blueGrey,
                          )
                      ],
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await showFlexibleBottomSheet(
                    minHeight: 0,
                    initHeight: 0.8,
                    maxHeight: 1,
                    context: context,
                    builder: _buildPostEditSheet,
                    duration: const Duration(milliseconds: 500),
                    bottomSheetColor:
                        theme.colorScheme.primary.withOpacity(0.4),
                    bottomSheetBorderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    anchors: [0, 1],
                    isSafeArea: true,
                  );
                },
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 35,
                  color: Colors.blueGrey,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await postController.deletePost(
                    post: post,
                    user: currentUser,
                  );
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 35,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          //todo customize content of post
          Align(
            alignment: Alignment.topLeft,
            child: ExpandableContent(content: post.content!, theme: theme),
          ),
          const SizedBox(
            height: 10,
          ),
          post.imageUrls != null
              ? SizedBox(
                  height: 100,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.imageUrls!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(
                                  post.imageUrls![index],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        );
                      }),
                )
              : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 25,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      post.likeCount!.toString(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${post.commentCount!.toString()} comments",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "${post.shareCount!.toString()} shares",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => postController.isLiked.value
                    ? Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            postController.isLiked.value = false;
                            await postController.toggleLikePost(post.postId!);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.favorite,
                                size: 30,
                                color: Colors.redAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Like",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            postController.isLiked.value = true;
                            await postController.toggleLikePost(post.postId!);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.favorite_border,
                                size: 30,
                                color: Colors.redAccent,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Like",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await showFlexibleBottomSheet(
                      minHeight: 0,
                      initHeight: 0.9,
                      maxHeight: 1,
                      context: context,
                      builder: _buildCommentSheet,
                      duration: const Duration(milliseconds: 500),
                      bottomSheetColor: Colors.grey.withOpacity(0.7),
                      bottomSheetBorderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      isSafeArea: true,
                    );
                  },
                  child: const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_rounded,
                          size: 30,
                          color: Colors.purpleAccent,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Comment",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Share.share("Oh Hi!");
                    if (result.status == ShareResultStatus.success) {
                      successMessage("Done!");
                    }
                    await postController.incrementSharedCount(post.postId!);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        size: 30,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Share",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommentSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
  ) {
    return CommentListSheet(
      scrollController: scrollController,
    );
  }

  Widget _buildPostEditSheet(
    BuildContext context,
    ScrollController scrollController,
    double bottomSheetOffset,
  ) {
    return PostEditSheet(
      scrollController: scrollController,
    );
  }
}
