import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ReelModel {
  String? reelId;
  UserModel? reelUser;
  String? videoUrl; // URL video
  String? thumbnailUrl; // Ảnh thumbnail
  String? description; // Mô tả video
  List<String>? likedList; // Danh sách người đã like
  int? commentCount; // Số lượng comment
  int? shareCount; // Số lần chia sẻ
  DateTime? createdAt; // Ngày đăng
  List<String>? taggedUserIds; // Người được gắn thẻ
  String? privacy; // Quyền riêng tư (public, friends, private)
  bool? isNotified; // Thông báo khi có tương tác

  ReelModel({
    this.reelId,
    this.reelUser,
    this.videoUrl,
    this.thumbnailUrl,
    this.description,
    this.likedList,
    this.commentCount,
    this.shareCount,
    this.createdAt,
    this.taggedUserIds,
    this.privacy,
    this.isNotified,
  });

  // Constructor chuyển từ JSON sang ReelModel
  ReelModel.fromJson(Map<String, dynamic> json) {
    reelId = json['reelId'] as String?;
    if (json["reelUser"] is Map) {
      reelUser = json["reelUser"] == null
          ? null
          : UserModel.fromJson(json["reelUser"]);
    }
    videoUrl = json['videoUrl'] as String?;
    thumbnailUrl = json['thumbnailUrl'] as String?;
    description = json['description'] as String?;
    if (json['likedList'] is List) {
      likedList = List<String>.from(json['likedList']);
    }
    commentCount = json['commentCount'] as int? ?? 0;
    shareCount = json['shareCount'] as int? ?? 0;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }
    if (json['taggedUserIds'] is List) {
      taggedUserIds = List<String>.from(json['taggedUserIds']);
    }
    privacy = json['privacy'] as String?;
    isNotified = json["isNotified"] as bool? ?? false;
  }

  // Chuyển ReelModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reelId'] = reelId;
    if (reelUser != null) {
      data["reelUser"] = reelUser?.toJson();
    }
    data['videoUrl'] = videoUrl;
    data['thumbnailUrl'] = thumbnailUrl;
    data['description'] = description;
    data['likedList'] = likedList;
    data['commentCount'] = commentCount;
    data['shareCount'] = shareCount;
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }
    data['taggedUserIds'] = taggedUserIds;
    data['privacy'] = privacy;
    data["isNotified"] = isNotified;
    return data;
  }

  // Phương thức cập nhật các trường cần thiết từ JSON mới
  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('likedList') && json['likedList'] is List) {
      likedList = List<String>.from(json['likedList']);
    }
    if (json.containsKey('commentCount')) {
      commentCount = json['commentCount'] as int? ?? commentCount;
    }
    if (json.containsKey('shareCount')) {
      shareCount = json['shareCount'] as int? ?? shareCount;
    }
    // Nếu có các trường khác cần cập nhật, bạn có thể thêm ở đây
  }
}
