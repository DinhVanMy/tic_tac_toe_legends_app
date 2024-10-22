import 'package:flutter/material.dart';

class PostEditModel {
  IconData icon;
  String title;
  String description;

  PostEditModel({
    required this.icon,
    required this.title,
    required this.description,
  });

  static final List<PostEditModel> listPostEditModels = [
    PostEditModel(
      icon: Icons.add_circle_rounded,
      title: 'Interested',
      description: 'More suggested posts in your Feed will be like this',
    ),
    PostEditModel(
      icon: Icons.remove_circle,
      title: 'Not interested',
      description: 'Less suggested posts in your Feed will be like this',
    ),
    PostEditModel(
      icon: Icons.save_alt,
      title: 'Save Post',
      description: 'Add this to your saved feed',
    ),
    PostEditModel(
      icon: Icons.edit,
      title: 'Edit Post',
      description: 'Update the details of your post',
    ),
    PostEditModel(
      icon: Icons.delete,
      title: 'Delete Post',
      description: 'Delete your post forever',
    ),
    PostEditModel(
      icon: Icons.report_problem,
      title: 'Report Post',
      description: 'Submit a report about the post',
    ),
    PostEditModel(
      icon: Icons.add_circle,
      title: 'Add Image/Video',
      description: 'Attach images or videos to your post',
    ),
    PostEditModel(
      icon: Icons.text_format,
      title: 'Format Text',
      description: 'Format your text in different styles',
    ),
    PostEditModel(
      icon: Icons.reply,
      title: 'Reply to Comment',
      description: 'Reply to a comment on your post',
    ),
  ];
}
