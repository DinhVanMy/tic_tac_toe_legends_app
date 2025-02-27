import 'package:flutter/material.dart';
import 'post_edit_model.dart';

class PostEditSheet extends StatelessWidget {
  final ScrollController scrollController;
  final PostType postType;

  // Các callback cho từng hành động (có thể null)
  final VoidCallback? onInterested;
  final VoidCallback? onNotInterested;
  final VoidCallback? onSavePost;
  final VoidCallback? onEditPost;
  final VoidCallback? onDeletePost;
  final VoidCallback? onReportPost;
  final VoidCallback? onAddImageOrVideo;
  final VoidCallback? onFormatText;
  final VoidCallback? onReplyToComment;

  const PostEditSheet({
    super.key,
    required this.scrollController,
    required this.postType,
    this.onInterested,
    this.onNotInterested,
    this.onSavePost,
    this.onEditPost,
    this.onDeletePost,
    this.onReportPost,
    this.onAddImageOrVideo,
    this.onFormatText,
    this.onReplyToComment,
  });

  /// Tùy chọn danh sách model theo kiểu post hoặc reel
  List<PostEditModel> get updatedModels {
    List<PostEditModel> baseList = postType == PostType.reel
        ? PostEditModel.listReelEditModels
        : PostEditModel.listPostEditModels;
    return baseList.map((model) {
      switch (model.actionType) {
        case PostEditActionType.interested:
          return model.copyWith(callback: onInterested);
        case PostEditActionType.notInterested:
          return model.copyWith(callback: onNotInterested);
        case PostEditActionType.savePost:
          return model.copyWith(callback: onSavePost);
        case PostEditActionType.editPost:
          return model.copyWith(callback: onEditPost);
        case PostEditActionType.deletePost:
          return model.copyWith(callback: onDeletePost);
        case PostEditActionType.reportPost:
          return model.copyWith(callback: onReportPost);
        case PostEditActionType.addImageOrVideo:
          return model.copyWith(callback: onAddImageOrVideo);
        case PostEditActionType.formatText:
          return model.copyWith(callback: onFormatText);
        case PostEditActionType.replyToComment:
          return model.copyWith(callback: onReplyToComment);
        default:
          // Nếu có trường hợp nào không được xử lý, trả về model ban đầu.
          return model;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final models = updatedModels;
    return ListView.builder(
      controller: scrollController,
      itemCount: models.length,
      itemBuilder: (context, index) {
        final option = models[index];
        return Material(
          child: InkWell(
            onTap: option.callback,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    option.icon,
                    size: 35,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          option.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.blueGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
