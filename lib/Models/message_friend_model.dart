import 'package:cloud_firestore/cloud_firestore.dart';

class MessageFriendModel {
  String? messageId;
  String? senderId;
  String? receiverId;
  String? content;
  String? imagePath;
  String? gif;
  Timestamp? timestamp;
  String? status;
  String? replyTo;

  MessageFriendModel({
    this.messageId,
    this.senderId,
    this.receiverId,
    this.content,
    this.imagePath,
    this.gif,
    this.timestamp,
    this.status,
    this.replyTo,
  });

  MessageFriendModel.fromJson(Map<String, dynamic> json) {
    if (json['messageId'] is String) {
      messageId = json['messageId'];
    }
    if (json['senderId'] is String) {
      senderId = json['senderId'];
    }
    if (json['receiverId'] is String) {
      receiverId = json['receiverId'];
    }
    if (json['content'] is String) {
      content = json['content'];
    }
    if (json['imagePath'] is String) {
      imagePath = json['imagePath'];
    }
    if (json['gif'] is String) {
      gif = json['gif'];
    }
    if (json['timestamp'] is Timestamp) {
      timestamp = json['timestamp'];
    }
    if (json['status'] is String) {
      status = json['status'];
    }
    if (json['replyTo'] is String) {
      replyTo = json['replyTo'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['content'] = content;
    data['imagePath'] = imagePath;
    data['gif'] = gif;
    data['timestamp'] = timestamp;
    data['status'] = status;
    data['replyTo'] = replyTo;
    return data;
  }
}
