import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/sub_comment_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';

class ReplyCommentListSheet extends StatelessWidget {
  final CommentController commentController;
  final ScrollController scrollController;
  final UserModel currentUser;
  final String postId;
  final CommentModel commentModel;
  const ReplyCommentListSheet(
      {super.key,
      required this.scrollController,
      required this.currentUser,
      required this.postId,
      required this.commentModel,
      required this.commentController});

  @override
  Widget build(BuildContext context) {
    final SubCommentController subCommentController =
        Get.put(SubCommentController(postId, commentModel.id!));
    final UserModel commentUser = commentModel.commentUser!;
    final TextEditingController textEditingController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    RxString commentContent = "".obs;
    RxString replyCommentId = "".obs;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 30,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  const Text(
                    "Replies",
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(commentUser.image!),
                          radius: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    commentUser.name!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    TimeFunctions.timeAgo(
                                        now: DateTime.now(),
                                        createdAt: commentModel.createdAt!),
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 13,
                                    ),
                                  )
                                ],
                              ),
                              ExpandableContent(
                                content: commentModel.content!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                ),
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            commentModel.likedList != null
                                ? Obx(() {
                                    RxBool isLiked =
                                        commentController.isLikedComment(
                                            currentUser.id!, commentModel.id!);
                                    return !isLiked.value
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.favorite_border,
                                              size: 30,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              commentController.likeComment(
                                                  commentModel.id!,
                                                  currentUser.id!);
                                            },
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.favorite,
                                              size: 30,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              commentController.unlikeComment(
                                                  commentModel.id!,
                                                  currentUser.id!);
                                            },
                                          );
                                  })
                                : IconButton(
                                    icon: const Icon(
                                      Icons.favorite_border,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      commentController.likeComment(
                                          commentModel.id!, currentUser.id!);
                                    },
                                  ),
                            commentModel.likedList == null ||
                                    commentModel.likedList!.isEmpty
                                ? const Text(
                                    "0",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 17,
                                    ),
                                  )
                                : Text(
                                    "${commentModel.likedList!.length}",
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 17,
                                    ),
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.info_outline,
                size: 35,
              ),
            ),
          ],
        ),
        Expanded(
          child: Obx(() {
            if (subCommentController.subCommentsList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No replies yet", style: TextStyle(fontSize: 25)),
                    Text("Start the conversation...",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ],
                ),
              );
            } else {
              var comments = subCommentController.subCommentsList.toList();
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                    subCommentController.loadMoreSubComments();
                  }
                  return true;
                },
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      var commentUser = comment.commentUser!;
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      commentUser.image!),
                                  radius: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            commentUser.name!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            TimeFunctions.timeAgo(
                                                now: DateTime.now(),
                                                createdAt: comment.createdAt!),
                                            style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      ExpandableContent(
                                        content: comment.content!,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                        ),
                                        maxLines: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          replyCommentId.value = comment.id!;
                                          textEditingController.text =
                                              "@${commentUser.name!} ";
                                          textEditingController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset: textEditingController
                                                    .text.length),
                                          );
                                          focusNode.requestFocus();
                                        },
                                        child: const Text(
                                          "Reply",
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        size: 25,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {},
                                    ),
                                    comment.likedList == null ||
                                            comment.likedList!.isEmpty
                                        ? const Text(
                                            "0",
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 15,
                                            ),
                                          )
                                        : Text(
                                            "${comment.likedList!.length}",
                                            style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 15,
                                            ),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              );
            }
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Obx(() => replyCommentId.value.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      height: 50,
                      color: Colors.grey.shade400,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Replying to ${textEditingController.text} ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                replyCommentId.value = "";
                                textEditingController.clear();
                              },
                              child: const Text(
                                "X",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 25,
                                ),
                              ))
                        ],
                      ),
                    )
                  : const SizedBox()),
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(currentUser.image!),
                    radius: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: TextField(
                    focusNode: focusNode,
                    controller: textEditingController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        commentContent.value = value;
                      } else {
                        commentContent.value = "";
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade400,
                      hintStyle: const TextStyle(color: Colors.black54),
                      hintText:
                          "Reply a comment of @${commentModel.commentUser!.name!}",
                    ),
                  )),
                  Obx(
                    () => commentContent.value.isEmpty ||
                            commentContent.value == ""
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () async {
                              focusNode.unfocus();
                              await subCommentController.addSubComment(
                                  content: commentContent.value,
                                  currentUser: currentUser);
                              textEditingController.clear();
                              commentContent.value = "";
                            },
                            icon: const Icon(
                              Icons.arrow_outward_rounded,
                              size: 35,
                              color: Colors.blue,
                              weight: 10.0,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
