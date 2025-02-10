import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/display_gif_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/preview_gif_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/comment_post_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/sub_comment_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Components/emotes_picker_widget.dart';

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
    final TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    RxString commentContent = "".obs;
    RxString replyCommentId = "".obs;
    RxBool isEmojiPickerVisible = false.obs;
    var selectedGif = Rx<GiphyGif?>(null);
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AvatarUserWidget(
                            radius: 30, imagePath: commentUser.image!),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                commentUser.name!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                              ExpandableContent(
                                content: commentModel.content!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                ),
                                maxLines: 5,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AvatarUserWidget(radius: 20, imagePath: commentUser.image!),
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
                                      comment.gif != null
                                          ? DisplayGifWidget(
                                              gifUrl: comment.gif!)
                                          : const SizedBox(),
                                      GestureDetector(
                                        onTap: () {
                                          replyCommentId.value = comment.id!;
                                          textController.text =
                                              "@${commentUser.name!} ";
                                          textController.selection =
                                              TextSelection.fromPosition(
                                            TextPosition(
                                                offset:
                                                    textController.text.length),
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
                      )
                          .animate()
                          .scale(duration: duration750)
                          .fadeIn(duration: duration750);
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
                              "Replying to ${textController.text} ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                replyCommentId.value = "";
                                textController.clear();
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
              PreviewGifWidget(selectedGif: selectedGif),
              CustomEmojiPicker(
                onEmojiSelected: (emoji) {
                  textController.text += emoji;
                  commentContent.value = textController.text;
                  textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: textController.text.length),
                  );
                },
                onBackspacePressed: () {
                  final text = textController.text;
                  if (text.isNotEmpty) {
                    // Xóa ký tự cuối (bao gồm cả emoji)
                    textController.text =
                        text.characters.skipLast(1).toString();
                    commentContent.value = textController.text;
                    textController.selection = TextSelection.fromPosition(
                      TextPosition(offset: textController.text.length),
                    );
                  }
                },
                isEmojiPickerVisible: isEmojiPickerVisible,
                backgroundColor: const [
                  Colors.blueGrey,
                  Colors.blueGrey,
                ],
              ),
              Row(
                children: [
                  AvatarUserWidget(radius: 25, imagePath: currentUser.image!),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: TextField(
                    focusNode: focusNode,
                    controller: textController,
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
                      prefixIcon: IconButton(
                        icon: const Icon(
                          Icons.gif_box_outlined,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        onPressed: () async {
                          final gif = await GiphyPicker.pickGif(
                            context: context,
                            apiKey: apiGifphy,
                            showPreviewPage: false,
                            showGiphyAttribution: false,
                            loadingBuilder: (context) {
                              return Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    GifsPath.loadingGif,
                                    height: 200,
                                    width: 200,
                                  ),
                                ),
                              );
                            },
                          );

                          if (gif != null) {
                            selectedGif.value = gif;
                          }
                        },
                      ),
                      suffixIcon: Obx(() => IconButton(
                          onPressed: () {
                            isEmojiPickerVisible.toggle();
                          },
                          icon: isEmojiPickerVisible.value
                              ? const Icon(
                                  Icons.emoji_emotions,
                                  color: Colors.blue,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: Colors.blue,
                                  size: 30,
                                ))),
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
                              textController.clear();
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
