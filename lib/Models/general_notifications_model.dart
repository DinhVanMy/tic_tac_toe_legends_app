import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class GeneralNotificationsModel {
  String? id;
  String? senderId;
  UserModel? senderModel;
  String? receiverId;
  String? message;
  String? type;
  Timestamp? timestamp;
  bool? isReaded;
  String? roomId;
  String? postId;
  String? commentId;
  int count = 1;

  GeneralNotificationsModel({
    this.id,
    this.senderId,
    this.senderModel,
    this.receiverId,
    this.message,
    this.type,
    this.timestamp,
    this.isReaded,
    this.roomId,
    this.postId,
    this.commentId,
    this.count = 1,
  });

  GeneralNotificationsModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["senderId"] is String) {
      senderId = json["senderId"];
    }
    if (json["senderModel"] is Map) {
      senderModel = json["senderModel"] == null
          ? null
          : UserModel.fromJson(json["senderModel"]);
    }
    if (json["receiverId"] is String) {
      receiverId = json["receiverId"];
    }
    if (json["message"] is String) {
      message = json["message"];
    }
    if (json["type"] is String) {
      type = json["type"];
    }
    if (json["timestamp"] is Timestamp) {
      timestamp = json["timestamp"];
    }
    if (json["isReaded"] is bool) {
      isReaded = json["isReaded"];
    }
    if (json["roomId"] is String) {
      roomId = json["roomId"];
    }
    if (json["postId"] is String) {
      postId = json["postId"];
    }
    if (json["commentId"] is String) {
      commentId = json["commentId"];
    }
    count = json["count"]?? 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["senderId"] = senderId;
    if (senderModel != null) {
      data["senderModel"] = senderModel?.toJson();
    }
    data["receiverId"] = receiverId;
    data["message"] = message;
    data["type"] = type;
    data["timestamp"] = timestamp;
    data["isReaded"] = isReaded;
    data["roomId"] = roomId;
    data["postId"] = postId;
    data["commentId"] = commentId;
    data["count"] = count;
    return data;
  }
}
