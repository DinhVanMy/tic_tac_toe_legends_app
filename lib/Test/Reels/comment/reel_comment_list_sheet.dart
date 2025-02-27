import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:tictactoe_gameapp/Components/belong_to_users/avatar_user_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/display_gif_widget.dart';
import 'package:tictactoe_gameapp/Components/gifphy/preview_gif_widget.dart';
import 'package:tictactoe_gameapp/Configs/assets_path.dart';
import 'package:tictactoe_gameapp/Configs/constants.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Models/Functions/time_functions.dart';
import 'package:tictactoe_gameapp/Pages/Society/Comment/post_reply_comment_controller.dart';
import 'package:tictactoe_gameapp/Pages/Society/Widgets/expandable_text_custom.dart';
import 'package:tictactoe_gameapp/Components/emotes_picker_widget.dart';
import 'package:tictactoe_gameapp/Test/Reels/comment/reel_comment_controller.dart';
import 'package:tictactoe_gameapp/Test/Reels/comment/reel_reply_comment_controller.dart';
import 'package:tictactoe_gameapp/Test/Reels/comment/reel_reply_comment_list_sheet.dart';
import 'package:tictactoe_gameapp/Test/Reels/reel_model.dart';

class ReelCommentListSheet extends StatelessWidget {
  final ScrollController scrollController;
  final UserModel currentUser;
  final ReelModel reel; // Giả sử bạn đã có ReelModel

  const ReelCommentListSheet({
    super.key,
    required this.scrollController,
    required this.currentUser,
    required this.reel,
  });

  @override
  Widget build(BuildContext context) {
    final ReelCommentController commentController = Get.put(
        ReelCommentController(reel.reelId!)); // Giả sử reelId là trường ID
    final TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    RxString commentContent = "".obs;
    RxString commentId = "".obs;
    RxBool isEmojiPickerVisible = false.obs;
    var selectedGif = Rx<GiphyGif?>(null);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
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
                  const Text("Comments", style: TextStyle(fontSize: 20)),
                  Obx(() => DropdownButton<String>(
                        value: commentController.selectedOption.value,
                        icon: const Icon(Icons.radio_button_checked_rounded),
                        iconSize: 24,
                        iconEnabledColor: Colors.blue,
                        elevation: 16,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            commentController.updateSelectedOption(newValue);
                          }
                        },
                        items: commentController.options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
            IconButton(
              onPressed: () => commentController.fetchInitialComments(),
              icon: const Icon(Icons.refresh_outlined,
                  size: 35, color: Colors.blue),
            ),
          ],
        ),
        Expanded(
          child: Obx(() {
            if (commentController.commentsList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No comments yet", style: TextStyle(fontSize: 25)),
                    Text("Start the conversation...",
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                  ],
                ),
              );
            } else {
              var comments = commentController.commentsList.toList();
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                    commentController.fetchMoreFilteredComments();
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
                              AvatarUserWidget(
                                  radius: 20, imagePath: commentUser.image!),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          commentUser.name!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purpleAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          TimeFunctions.timeAgo(
                                              now: DateTime.now(),
                                              createdAt: comment.createdAt!),
                                          style: const TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 12,
                                          ),
                                        ),
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
                                        ? DisplayGifWidget(gifUrl: comment.gif!)
                                        : const SizedBox(),
                                    GestureDetector(
                                      onTap: () {
                                        commentId.value = comment.id!;
                                        textController.text =
                                            "@${commentUser.name!} ";
                                        textController.selection =
                                            TextSelection.fromPosition(
                                                TextPosition(
                                                    offset: textController
                                                        .text.length));
                                        focusNode.requestFocus();
                                      },
                                      child: const Text(
                                        "Reply",
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  comment.likedList != null
                                      ? Obx(() {
                                          RxBool isLiked =
                                              commentController.isLikedComment(
                                                  currentUser.id!, comment.id!);
                                          return !isLiked.value
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.favorite_border,
                                                    size: 25,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () async {
                                                    commentController
                                                        .likeComment(
                                                            comment.id!,
                                                            currentUser.id!);
                                                  },
                                                )
                                              : IconButton(
                                                  icon: const Icon(
                                                    Icons.favorite,
                                                    size: 25,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    commentController
                                                        .unlikeComment(
                                                            comment.id!,
                                                            currentUser.id!);
                                                  },
                                                );
                                        })
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.favorite_border,
                                            size: 25,
                                            color: Colors.black,
                                          ),
                                          onPressed: () async {
                                            commentController.likeComment(
                                                comment.id!, currentUser.id!);
                                          },
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
                              ),
                            ],
                          ),
                          comment.countReplies == null ||
                                  comment.countReplies == 0
                              ? const SizedBox()
                              : Row(
                                  children: [
                                    const SizedBox(width: 40),
                                    Container(
                                      height: 2,
                                      width: 50,
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Get.delete<
                                            PostReplyCommentController>();
                                        await showFlexibleBottomSheet(
                                          minHeight: 0,
                                          initHeight: 0.8,
                                          maxHeight: 1,
                                          context: context,
                                          builder: (context, scrollController,
                                              bottomSheet) {
                                            return ReelReplyCommentListSheet(
                                              scrollController:
                                                  scrollController,
                                              currentUser: currentUser,
                                              reelId: reel.reelId!,
                                              commentModel: comment,
                                              commentController:
                                                  commentController,
                                            );
                                          },
                                          duration:
                                              const Duration(milliseconds: 500),
                                          bottomSheetColor: Colors.white,
                                          bottomSheetBorderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          isSafeArea: true,
                                        );
                                      },
                                      child: Text(
                                        "View ${comment.countReplies} more replies",
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    )
                        .animate()
                        .scale(duration: duration750)
                        .fadeIn(duration: duration750);
                  },
                ),
              );
            }
          }),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Obx(() => commentId.value.isNotEmpty
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
                              commentId.value = "";
                              textController.clear();
                            },
                            child: const Text(
                              "X",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 25,
                              ),
                            ),
                          ),
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
                      TextPosition(offset: textController.text.length));
                },
                onBackspacePressed: () {
                  final text = textController.text;
                  if (text.isNotEmpty) {
                    textController.text =
                        text.characters.skipLast(1).toString();
                    commentContent.value = textController.text;
                    textController.selection = TextSelection.fromPosition(
                        TextPosition(offset: textController.text.length));
                  }
                },
                isEmojiPickerVisible: isEmojiPickerVisible,
                backgroundColor: const [Colors.blueGrey, Colors.blueGrey],
              ),
              Row(
                children: [
                  AvatarUserWidget(radius: 25, imagePath: currentUser.image!),
                  const SizedBox(width: 10),
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
                        hintText: "Write a comment...",
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
                            onPressed: () => isEmojiPickerVisible.toggle(),
                            icon: isEmojiPickerVisible.value
                                ? const Icon(Icons.emoji_emotions,
                                    color: Colors.blue, size: 30)
                                : const Icon(Icons.emoji_emotions_outlined,
                                    color: Colors.blue, size: 30))),
                      ),
                    ),
                  ),
                  Obx(() =>
                      commentContent.value.isEmpty || commentContent.value == ""
                          ? const SizedBox()
                          : Obx(() => commentId.value.isNotEmpty
                              ? IconButton(
                                  onPressed: () async {
                                    focusNode.unfocus();
                                    Get.delete<ReelReplyCommentController>();
                                    ReelReplyCommentController
                                        subCommentController =
                                        Get.put(ReelReplyCommentController(
                                      reel.reelId!, // Sử dụng reelId
                                      commentId.value,
                                    ));
                                    await subCommentController.addSubComment(
                                        content: commentContent.value,
                                        gifUrl: selectedGif
                                            .value?.images.original!.url!,
                                        currentUser: currentUser);
                                    textController.clear();
                                    commentContent.value = "";
                                    selectedGif.value = null;
                                    commentId.value = "";
                                  },
                                  icon: const Icon(
                                    Icons.reply_all_rounded,
                                    size: 35,
                                    color: Colors.blue,
                                  ),
                                )
                              : IconButton(
                                  onPressed: () async {
                                    focusNode.unfocus();
                                    await commentController.addComment(
                                      content: commentContent.value,
                                      currentUser: currentUser,
                                      receiverId: reel.reelUser!
                                          .id!, // Giả sử reelUser là trường
                                      gifUrl: selectedGif
                                          .value?.images.original!.url!,
                                    );
                                    textController.clear();
                                    selectedGif.value = null;
                                    commentContent.value = "";
                                  },
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    size: 35,
                                    color: Colors.blue,
                                  ),
                                ))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
