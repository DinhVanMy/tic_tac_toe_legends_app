import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class CallModel {
  String? id;
  UserModel? callerUser;
  UserModel? receiverUser;
  String? status;
  DateTime? createdAt;

  CallModel({
    this.id,
    this.callerUser,
    this.receiverUser,
    this.status,
    this.createdAt,
  });

  CallModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["callerUser"] is Map) {
      callerUser = json["callerUser"] == null
          ? null
          : UserModel.fromJson(json["callerUser"]);
    }
    if (json["receiverUser"] is Map) {
      receiverUser = json["receiverUser"] == null
          ? null
          : UserModel.fromJson(json["receiverUser"]);
    }
    if (json["status"] is String) {
      status = json["status"];
    }
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    if (callerUser != null) {
      data["callerUser"] = callerUser?.toJson();
    }
    if (receiverUser != null) {
      data["receiverUser"] = receiverUser?.toJson();
    }
    if (status != null) {
      data["status"] = status;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt?.toUtc();
    }
    return data;
  }
}
