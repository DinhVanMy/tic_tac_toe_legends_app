import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/comment_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/like_user_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';

class PostSectionWidget extends StatelessWidget {
  final ThemeData theme;
  final PostModel post;
  final UserModel postUser;

  final UserModel currentUser;
  const PostSectionWidget(
      {super.key,
      required this.theme,
      required this.post,
      required this.postUser,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.put(PostController());
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
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
                    Text(postUser.name!, style: theme.textTheme.bodyLarge!),
                    Row(
                      children: [
                        Text(
                          TimeFunctions.timeAgo(
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
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          post.backgroundPost != null && post.backgroundPost!.isNotEmpty
              ? Container(
                  width: double.maxFinite,
                  height: 200,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: post.backgroundPost!
                          .map((hex) =>
                              ColorStringReverseFunction.hexToColor(hex))
                          .toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: ExpandableContent(
                      content: post.content!,
                      isAligCenter: true,
                      style: theme.textTheme.titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                )
              : Align(
                  alignment: Alignment.topLeft,
                  child: ExpandableContent(
                      content: post.content!,
                      style: theme.textTheme.titleLarge!),
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
                Expanded(
                  child: Material(
                    child: InkWell(
                      onTap: () async {
                        if (post.likedList != null) {
                          var likeUsers = await postController
                              .fetchPostLikeUsers(post.likedList!);
                          await showFlexibleBottomSheet(
                            minHeight: 0,
                            initHeight: 0.8,
                            maxHeight: 1,
                            context: context,
                            builder: (context, scrollController, bottomSheet) {
                              return LikeUserListSheet(
                                likeUsers: likeUsers,
                                scrollController: scrollController,
                              );
                            },
                            duration: const Duration(milliseconds: 500),
                            bottomSheetColor: Colors.white,
                            bottomSheetBorderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            isSafeArea: true,
                          );
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 25,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          post.likedList != null
                              ? Text(
                                  "${post.likedList!.length}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )
                              : const Text(
                                  "0",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: post.commentCount == null
                      ? const Text(
                          "0 comments",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      : Text(
                          "${post.commentCount} comments",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${post.shareCount!.toString()} shares",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
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
              post.likedList != null
                  ? Obx(() {
                      RxBool isLiked = postController.isLikedPost(
                          currentUser.id!, post.postId!);
                      return !isLiked.value
                          ? Expanded(
                              child: Material(
                                child: InkWell(
                                  highlightColor: Colors.redAccent,
                                  onTap: () async {
                                    postController.likePost(post, currentUser);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        Icons.favorite_border_rounded,
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
                            )
                          : Expanded(
                              child: Material(
                                child: InkWell(
                                  highlightColor: Colors.redAccent,
                                  onTap: () async {
                                    postController.unlikePost(
                                        post.postId!, currentUser.id!);
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
                                        "UnLike",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                    })
                  : Expanded(
                      child: Material(
                        child: InkWell(
                          highlightColor: Colors.redAccent,
                          onTap: () async {
                            postController.likePost(post, currentUser);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.favorite_border_rounded,
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
              // ),
              Expanded(
                child: Material(
                  child: InkWell(
                    highlightColor: Colors.purpleAccent,
                    onTap: () async {
                      Get.delete<CommentController>();
                      await showFlexibleBottomSheet(
                        minHeight: 0,
                        initHeight: 0.9,
                        maxHeight: 1,
                        context: context,
                        builder: (context, scrollController, bottomSheet) {
                          return CommentListSheet(
                            scrollController: scrollController,
                            currentUser: currentUser,
                            postId: post.postId!,
                          );
                        },
                        duration: const Duration(milliseconds: 500),
                        bottomSheetColor: Colors.white,
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
              ),
              Expanded(
                child: Material(
                  child: InkWell(
                    highlightColor: Colors.blueAccent,
                    onTap: () async {
                      final result = await Share.share("Oh Hi!");
                      if (result.status == ShareResultStatus.success) {
                        successMessage("Done!");
                      }
                      await postController.incrementSharedCount(
                          post, currentUser);
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
                ),
              )
            ],
          )
        ],
      ),
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
