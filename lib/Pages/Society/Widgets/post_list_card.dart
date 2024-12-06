import 'dart:convert';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/comment_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/like_user_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/share_sheet_custom.dart';
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
    var currentIndex = 0.obs;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(UserAboutPage(
                unknownableUser: postUser,
                intdexString: post.postId!,
              ));
            },
            child: Row(
              children: [
                Hero(
                  tag: "user_avatar_${post.postId}",
                  child: CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(postUser.image!),
                    radius: 20,
                  ),
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
                                now: DateTime.now(),
                                createdAt: post.createdAt!),
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
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                      )),
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
                            GestureDetector(
                              onTap: () {
                                currentIndex.value = index;
                                Get.dialog(
                                  Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(10),
                                    child: GestureDetector(
                                      onTap: () => Get.back(),
                                      child: PageView.builder(
                                        controller: PageController(
                                            initialPage: currentIndex.value),
                                        onPageChanged: (index) {
                                          currentIndex.value = index;
                                        },
                                        itemCount: post.imageUrls!.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: double.infinity,
                                            height: 200,
                                            alignment: Alignment.topCenter,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: MemoryImage(
                                                  base64Decode(
                                                    post.imageUrls![index],
                                                  ),
                                                ),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                            child: Text(
                                              "${index + 1} / ${post.imageUrls!.length}",
                                              style: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          );
                                          //  InteractiveViewer(
                                          //   boundaryMargin:
                                          //       const EdgeInsets.all(8),
                                          //   minScale: 1,
                                          //   maxScale: 3,
                                          //   child:
                                          //    ClipRRect(
                                          //     borderRadius:
                                          //         BorderRadius.circular(10),
                                          //     child: Image.memory(
                                          //       base64Decode(
                                          //         post.imageUrls![index],
                                          //       ),
                                          //       width: double.infinity,
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(
                                    post.imageUrls![index],
                                  ),
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
                            post: post,
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
                      await GeneralBottomsheetShowFunction
                          .showScrollableGeneralBottomsheet(
                        widgetBuilder: (context, controller) =>
                            ShareSheetCustom(
                          scrollController: controller,
                          currentUser: currentUser,
                          postController: postController,
                          post: post,
                        ),
                        context: context,
                        initHeight: 0.8,
                        color: Colors.transparent,
                      );
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
