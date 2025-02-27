import 'package:flutter/material.dart';

/// Các loại hành động
enum PostEditActionType {
  interested,
  notInterested,
  savePost,
  editPost,
  deletePost,
  reportPost,
  addImageOrVideo,
  formatText,
  replyToComment,
}

/// Enum để xác định kiểu nội dung: post hoặc reel
enum PostType {
  post,
  reel,
}

class PostEditModel {
  final IconData icon;
  final String title;
  final String description;
  final PostEditActionType actionType;
  final VoidCallback? callback;

  PostEditModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionType,
    this.callback,
  });

  /// Phương thức copyWith để gán callback mới khi cần.
  PostEditModel copyWith({VoidCallback? callback}) {
    return PostEditModel(
      icon: icon,
      title: title,
      description: description,
      actionType: actionType,
      callback: callback ?? this.callback,
    );
  }

  /// Danh sách model dành cho Post (mặc định)
  static final List<PostEditModel> listPostEditModels = [
    PostEditModel(
      icon: Icons.add_circle_rounded,
      title: 'Interested',
      description: 'More suggested posts in your Feed will be like this',
      actionType: PostEditActionType.interested,
    ),
    PostEditModel(
      icon: Icons.remove_circle,
      title: 'Not interested',
      description: 'Less suggested posts in your Feed will be like this',
      actionType: PostEditActionType.notInterested,
    ),
    PostEditModel(
      icon: Icons.save_alt,
      title: 'Save Post',
      description: 'Add this to your saved posts',
      actionType: PostEditActionType.savePost,
    ),
    PostEditModel(
      icon: Icons.edit,
      title: 'Edit Post',
      description: 'Update the details of your post',
      actionType: PostEditActionType.editPost,
    ),
    PostEditModel(
      icon: Icons.delete,
      title: 'Delete Post',
      description: 'Delete your post forever',
      actionType: PostEditActionType.deletePost,
    ),
    PostEditModel(
      icon: Icons.report_problem,
      title: 'Report Post',
      description: 'Submit a report about the post',
      actionType: PostEditActionType.reportPost,
    ),
    PostEditModel(
      icon: Icons.add_circle,
      title: 'Add Image/Video',
      description: 'Attach images or videos to your post',
      actionType: PostEditActionType.addImageOrVideo,
    ),
    PostEditModel(
      icon: Icons.text_format,
      title: 'Format Text',
      description: 'Format your text in different styles',
      actionType: PostEditActionType.formatText,
    ),
    PostEditModel(
      icon: Icons.reply,
      title: 'Reply to Comment',
      description: 'Reply to a comment on your post',
      actionType: PostEditActionType.replyToComment,
    ),
  ];

  /// Danh sách model dành cho Reel với các text được chuyển đổi (post -> reel)
  static final List<PostEditModel> listReelEditModels = [
    PostEditModel(
      icon: Icons.add_circle_rounded,
      title: 'Interested',
      description: 'More suggested reels in your Feed will be like this',
      actionType: PostEditActionType.interested,
    ),
    PostEditModel(
      icon: Icons.remove_circle,
      title: 'Not interested',
      description: 'Less suggested reels in your Feed will be like this',
      actionType: PostEditActionType.notInterested,
    ),
    PostEditModel(
      icon: Icons.save_alt,
      title: 'Save Reel',
      description: 'Add this to your saved reels',
      actionType: PostEditActionType.savePost,
    ),
    PostEditModel(
      icon: Icons.edit,
      title: 'Edit Reel',
      description: 'Update the details of your reel',
      actionType: PostEditActionType.editPost,
    ),
    PostEditModel(
      icon: Icons.delete,
      title: 'Delete Reel',
      description: 'Delete your reel forever',
      actionType: PostEditActionType.deletePost,
    ),
    PostEditModel(
      icon: Icons.report_problem,
      title: 'Report Reel',
      description: 'Submit a report about the reel',
      actionType: PostEditActionType.reportPost,
    ),
    PostEditModel(
      icon: Icons.add_circle,
      title: 'Add Image/Video',
      description: 'Attach images or videos to your reel',
      actionType: PostEditActionType.addImageOrVideo,
    ),
    PostEditModel(
      icon: Icons.text_format,
      title: 'Format Text',
      description: 'Format your text in different styles',
      actionType: PostEditActionType.formatText,
    ),
    PostEditModel(
      icon: Icons.reply,
      title: 'Reply to Comment',
      description: 'Reply to a comment on your reel',
      actionType: PostEditActionType.replyToComment,
    ),
  ];
}
