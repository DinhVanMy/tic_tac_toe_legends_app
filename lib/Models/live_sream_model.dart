import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class LiveStreamModel {
  String? streamId; // ID của livestream
  String? channelId; // ID channel
  int? hostUid;
  UserModel? streamer; // Người tạo livestream
  String? title; // Tiêu đề livestream
  String? description; // Mô tả livestream
  String? thumbnailUrl; // Ảnh đại diện của livestream
  String? category;
  int? viewerCount; // Số lượng người xem hiện tại
  int? likeCount; // Tổng số lượt thích
  Map<String, Map<String, String>>? comments;
  List<String>? emotes;
  DateTime? createdAt; // Thời gian bắt đầu live

  LiveStreamModel({
    this.streamId,
    this.channelId,
    this.hostUid,
    this.streamer,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.category, // Thể loại livestream
    this.viewerCount,
    this.likeCount,
    this.comments,
    this.emotes,
    this.createdAt,
  });

  // Constructor để chuyển từ JSON sang LiveStreamModel
  LiveStreamModel.fromJson(Map<String, dynamic> json) {
    streamId = json['streamId'] as String?;
    channelId = json['channelId'] as String?;
    hostUid = json['hostUid'] as int?;
    if (json["streamer"] is Map) {
      streamer = json["streamer"] == null
          ? null
          : UserModel.fromJson(json["streamer"]);
    }
    title = json['title'] as String?;
    description = json['description'] as String?;
    thumbnailUrl = json['thumbnailUrl'] as String?;
    category = json['category'] as String?; // Thể loại livestream
    viewerCount = json['viewerCount'] as int? ?? 0;
    likeCount = json['likeCount'] as int? ?? 0;
    if (json['comments'] is Map) {
      comments = (json['comments'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value),
        ),
      );
    }
    if (json['emotes'] is List) {
      emotes = List<String>.from(json['emotes']);
    }
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }
  }

  // Phương thức để chuyển LiveStreamModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['streamId'] = streamId;
    data['channelId'] = channelId;
    data['hostUid'] = hostUid;
    if (streamer != null) {
      data["streamer"] = streamer?.toJson();
    }
    data['title'] = title;
    data['description'] = description;
    data['thumbnailUrl'] = thumbnailUrl;
    data['category'] = category; // Thể loại livestream
    data['viewerCount'] = viewerCount;
    data['likeCount'] = likeCount;
    if (comments != null) {
      data['comments'] = comments;
    }
    if (emotes!= null) {
      data['emotes'] = emotes;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }

    return data;
  }
}
