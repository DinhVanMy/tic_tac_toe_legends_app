import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class CommentModel {
  String? id;
  UserModel? commentUser; // Người bình luận
  String? content; // Nội dung bình luận
  List<String>? likedList;
  DateTime? createdAt; // Thời gian bình luận
  String? postId; // Bài viết mà bình luận thuộc về
  int? countReplies;
  List<String>? taggedUserIds;

  CommentModel({
    this.id,
    this.commentUser,
    this.content,
    this.likedList,
    this.createdAt,
    this.postId,
    this.countReplies,
    this.taggedUserIds,
  });

  // Constructor để chuyển từ JSON sang CommentModel
  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['commentId'] as String?;

    // Parse user data
    if (json['commentUser'] is Map) {
      commentUser = json['commentUser'] == null
          ? null
          : UserModel.fromJson(json['commentUser']);
    }

    content = json['content'] as String?;
    if (json['likedList'] is List) {
      likedList = List<String>.from(json['likedList']);
    }

    // Parse timestamp to DateTime
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }

    postId = json['postId'] as String?;
    countReplies = json['countReplies'] as int? ?? 0;

    // Parse tagged user IDs
    if (json['taggedUserIds'] is List) {
      taggedUserIds = List<String>.from(json['taggedUserIds']);
    }
  }

  // Phương thức để chuyển CommentModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['commentId'] = id;

    if (commentUser != null) {
      data['commentUser'] =
          commentUser?.toJson(); // Convert commentUser to JSON
    }

    data['content'] = content;
    if (likedList != null) {
      data['likedList'] = likedList;
    }

    // Convert createdAt to UTC
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }

    data['postId'] = postId;
    data['countReplies'] = countReplies; 

    if (taggedUserIds != null) {
      data['taggedUserIds'] = taggedUserIds;
    }

    return data;
  }
}
