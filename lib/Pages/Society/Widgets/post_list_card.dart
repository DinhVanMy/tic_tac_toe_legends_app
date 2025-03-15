import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/display_gif_widget.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/Functions/color_string_reverse_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/fetch_firestore_data_functions.dart';
import 'package:tictactoe_gameapp/Models/Functions/general_bottomsheet_show_function.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/About/user_about_page.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/post_comment_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/post_comment_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/like_user_list_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_edit_sheet.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/share_sheet_custom.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/post_polls/post_polls_card.dart';
import 'package:tictactoe_gameapp/Components/gifphy/stack_image_widget.dart';

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
    return Obx(() {
      final isLiked =
          postController.isLikedPost(currentUser.id!, post.postId!).value;
      final likeCount = post.likedList?.length ?? 0;
      final commentCount = post.commentCount ?? 0;
      final shareCount = post.shareCount ?? 0;
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(
                    UserAboutPage(
                      unknownableUser: postUser,
                    ),
                    transition: Transition.leftToRightWithFade);
              },
              child: Row(
                children: [
                  AvatarUserWidget(
                    radius: 20,
                    imagePath: postUser.image!,
                    gradientColors: postUser.avatarFrame,
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
                        builder:
                            (context, scrollController, bottomSheetOffset) {
                          return PostEditSheet(
                            scrollController: scrollController,
                            onDeletePost: () async => postController.deletePost(
                                post: post, user: currentUser),
                            onSavePost: () async => await Clipboard.setData(
                              ClipboardData(text: post.content ?? ""),
                            ).then(
                              (value) => successMessage('Copied to Clipboard'),
                            ),
                            postType: PostType.post,
                          );
                        },
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
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: ExpandableContent(
                            content: post.content!,
                            style: theme.textTheme.titleLarge!.copyWith(
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                post.imageUrls != null
                    ? SizedBox(
                        height: 100,
                        width: MediaQuery.sizeOf(context).width / 2 - 25,
                        child: StackImageWidget(
                          imageUrls: post.imageUrls!,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 10,
                ),
                post.gif != null
                    ? SizedBox(
                        width: MediaQuery.sizeOf(context).width / 2 - 25,
                        child: DisplayGifWidget(gifUrl: post.gif!))
                    : const SizedBox(),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            post.postPolls != null
                ? PostPollWidget(
                    postPollsModel: post.postPolls!,
                    postController: postController,
                    postId: post.postId,
                    userId: currentUser.id,
                  )
                : const SizedBox.shrink(),
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
                            final FetchFirestoreDataFunctions
                                fetchFirestoreDataFunctions =
                                FetchFirestoreDataFunctions();
                            var likeUsers = await fetchFirestoreDataFunctions
                                .fetchPostLikeUsers(post.likedList!);
                            await showFlexibleBottomSheet(
                              minHeight: 0,
                              initHeight: 0.8,
                              maxHeight: 1,
                              context: context,
                              builder:
                                  (context, scrollController, bottomSheet) {
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
                            const SizedBox(width: 5),
                            Text(
                              "$likeCount",
                              style: const TextStyle(
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
                    child: Text(
                      "$commentCount comments",
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
                        "$shareCount shares",
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
                Expanded(
                  child: Material(
                    child: InkWell(
                      highlightColor: Colors.redAccent,
                      onTap: () async {
                        if (isLiked) {
                          await postController.unlikePost(
                              post.postId!, currentUser.id!);
                        } else {
                          await postController.likePost(post, currentUser);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isLiked ? "Unlike" : "Like",
                            style: TextStyle(
                              color: isLiked ? Colors.red : Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    child: InkWell(
                      highlightColor: Colors.purpleAccent,
                      onTap: () async {
                        Get.delete<PostCommentController>();
                        await showFlexibleBottomSheet(
                          minHeight: 0,
                          initHeight: 0.9,
                          maxHeight: 1,
                          context: context,
                          builder: (context, scrollController, bottomSheet) {
                            return PostCommentListSheet(
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
                            onPressed: () async {
                              await postController
                                  .incrementSharedCount(post, currentUser)
                                  .then((_) {
                                Get.back();
                                successMessage("Post shared successfully!");
                              });
                            },
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
    });
  }
}
