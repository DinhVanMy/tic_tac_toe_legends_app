import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? image;
  String? totalWins;
  String? role;
  String? totalCoins;
  String? quickMess;
  String? quickEmote;
  List<String>? friendsList;
  String? status;
  Timestamp? lastActive;
  GeoPoint? location;
  List<String>? avatarFrame;

  UserModel({
    this.role,
    this.id,
    this.name,
    this.email,
    this.image,
    this.totalWins,
    this.totalCoins,
    this.quickMess,
    this.quickEmote,
    this.friendsList,
    this.status,
    this.lastActive,
    this.location,
    this.avatarFrame,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["name"] is String) {
      name = json["name"];
    }
    if (json["email"] is String) {
      email = json["email"];
    }
    if (json["image"] is String) {
      image = json["image"];
    }
    if (json["totalWins"] is String) {
      totalWins = json["totalWins"];
    }
    if (json["role"] is String) {
      role = json["role"];
    }
    if (json["totalCoins"] is String) {
      totalCoins = json["totalCoins"];
    }
    if (json["quickMess"] is String) {
      quickMess = json["quickMess"];
    }
    if (json["quickEmote"] is String) {
      quickEmote = json["quickEmote"];
    }
    if (json["friendsList"] is List) {
      friendsList = List<String>.from(json["friendsList"]);
    }
    if (json["status"] is String) {
      status = json["status"];
    }
    if (json["lastActive"] is Timestamp) {
      lastActive = json["lastActive"];
    }
    location = json["location"] as GeoPoint?;
    if (json["avatarFrame"] is List) {
      avatarFrame = List<String>.from(json["avatarFrame"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["email"] = email;
    data["image"] = image;
    data["totalWins"] = totalWins;
    data["role"] = role;
    data["totalCoins"] = totalCoins;
    data["quickMess"] = quickMess;
    data["quickEmote"] = quickEmote;
    data["friendsList"] = friendsList;
    data["status"] = status;
    data["lastActive"] = lastActive;
    data["location"] = location;
    data["avatarFrame"] = avatarFrame;
    return data;
  }
}
