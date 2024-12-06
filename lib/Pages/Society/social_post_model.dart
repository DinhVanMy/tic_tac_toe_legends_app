import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class PostModel {
  String? postId;
  UserModel? postUser;
  String? content; // Nội dung bài viết
  List<String>? backgroundPost;
  List<String>? imageUrls; // Danh sách URL ảnh đính kèm
  List<String>? likedList;
  int? commentCount;
  int? shareCount;
  DateTime? createdAt; // Thời gian đăng bài
  List<String>? taggedUserIds; // Danh sách ID người dùng được gắn thẻ
  String? privacy; // Quyền riêng tư (public, friends, private)
  bool? isNotified;

  PostModel({
    this.postId,
    this.postUser,
    this.content,
    this.backgroundPost,
    this.imageUrls,
    this.likedList,
    this.shareCount,
    this.commentCount,
    this.createdAt,
    this.taggedUserIds,
    this.privacy,
    this.isNotified,
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
    if (json["backgroundPost"] is List) {
      backgroundPost = List<String>.from(json["backgroundPost"]);
    }
    if (json['imageUrls'] is List) {
      imageUrls = List<String>.from(json['imageUrls']);
    }
    if (json['likedList'] is List) {
      likedList = List<String>.from(json['likedList']);
    }
    shareCount = json['shareCount'] as int? ?? 0;
    if (json['commentCount'] is int) {
      commentCount = json['commentCount'];
    }
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }
    if (json['taggedUserIds'] is List) {
      taggedUserIds = List<String>.from(json['taggedUserIds']);
    }
    privacy = json['privacy'] as String?;
    if (json["isNotified"] is bool) {
      isNotified = json["isNotified"];
    }
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
    data['likedList'] = likedList;
    data['shareCount'] = shareCount;
    data['commentCount'] = commentCount;
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }
    data['taggedUserIds'] = taggedUserIds;
    data['privacy'] = privacy;
    data["isNotified"] = isNotified;
    return data;
  }
}
