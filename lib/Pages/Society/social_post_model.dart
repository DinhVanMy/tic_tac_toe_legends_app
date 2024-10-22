import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class PostModel {
  String? postId;
  UserModel? postUser;
  String? content; // Nội dung bài viết
  List<Color>? backgroundPost;
  List<String>? imageUrls; // Danh sách URL ảnh đính kèm
  int? likeCount; // Số lượng lượt thích
  int? commentCount; // Số lượng bình luận
  int? shareCount;
  DateTime? createdAt; // Thời gian đăng bài
  List<String>? taggedUserIds; // Danh sách ID người dùng được gắn thẻ
  String? privacy; // Quyền riêng tư (public, friends, private)

  PostModel({
    this.postId,
    this.postUser,
    this.content,
    this.backgroundPost,
    this.imageUrls,
    this.likeCount,
    this.shareCount,
    this.commentCount,
    this.createdAt,
    this.taggedUserIds,
    this.privacy,
  });

  // Constructor để chuyển từ JSON sang PostModel
  PostModel.fromJson(Map<String, dynamic> json) {
    postId = json['postId'] as String?;
    if (json["postUser"] is Map) {
      postUser = json["postUser"] == null
          ? null
          : UserModel.fromJson(json["postUser"]);
    }
    content = json['content'] as String?;
    if (json["backgroundPost"] is List<Color>) {
      backgroundPost = List<Color>.from(json["backgroundPost"] ?? []);
    }
    if (json['imageUrls'] is List) {
      imageUrls = List<String>.from(json['imageUrls']);
    }
    likeCount = json['likeCount'] as int? ?? 0;
    commentCount = json['commentCount'] as int? ?? 0;
    shareCount = json['shareCount'] as int? ?? 0;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }
    if (json['taggedUserIds'] is List) {
      taggedUserIds = List<String>.from(json['taggedUserIds']);
    }
    privacy = json['privacy'] as String?;
  }

  // Phương thức để chuyển PostModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postId'] = postId;
    if (postUser != null) {
      data["postUser"] = postUser?.toJson();
    }
    data['content'] = content;
    data['backgroundPost'] = backgroundPost;
    data['imageUrls'] = imageUrls;
    data['likeCount'] = likeCount;
    data['commentCount'] = commentCount;
    data['shareCount'] = shareCount;
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }
    data['taggedUserIds'] = taggedUserIds;
    data['privacy'] = privacy;
    return data;
  }
}
