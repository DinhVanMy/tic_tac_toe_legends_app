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
  bool? suspended;
  bool? verified;
  String? bio;
  Timestamp? createdAt;
  bool? isOnline;
  int? warningCount;

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
    this.suspended,
    this.verified,
    this.bio,
    this.createdAt,
    this.isOnline,
    this.warningCount,
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
    if (json["suspended"] is bool) {
      suspended = json["suspended"];
    }
    if (json["verified"] is bool) {
      verified = json["verified"];
    }
    if (json["bio"] is String) {
      bio = json["bio"];
    }
    if (json["createdAt"] is Timestamp) {
      createdAt = json["createdAt"];
    }
    if (json["isOnline"] is bool) {
      isOnline = json["isOnline"];
    }
    if (json["warningCount"] is int) {
      warningCount = json["warningCount"];
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
    data["suspended"] = suspended;
    data["verified"] = verified;
    data["bio"] = bio;
    data["createdAt"] = createdAt;
    data["isOnline"] = isOnline;
    data["warningCount"] = warningCount;
    return data;
  }

  // Add the copyWith method to fix the 'copyWith' isn't defined for the type 'UserModel' error
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? totalWins,
    String? role,
    String? totalCoins,
    String? quickMess,
    String? quickEmote,
    List<String>? friendsList,
    String? status,
    Timestamp? lastActive,
    GeoPoint? location,
    List<String>? avatarFrame,
    bool? suspended,
    bool? verified,
    String? bio,
    Timestamp? createdAt,
    bool? isOnline,
    int? warningCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      totalWins: totalWins ?? this.totalWins,
      role: role ?? this.role,
      totalCoins: totalCoins ?? this.totalCoins,
      quickMess: quickMess ?? this.quickMess,
      quickEmote: quickEmote ?? this.quickEmote,
      friendsList: friendsList ?? this.friendsList,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      avatarFrame: avatarFrame ?? this.avatarFrame,
      suspended: suspended ?? this.suspended,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      warningCount: warningCount ?? this.warningCount,
    );
  }
}
