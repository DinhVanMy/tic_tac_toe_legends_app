import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  String? userId;
  bool? isSearching;
  DateTime? createdAt;
  String? userEmail;

  QueueModel({
    this.userId,
    this.isSearching,
    required this.createdAt,
    this.userEmail,
  });

  QueueModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    isSearching = json['isSearching'];
    createdAt = (json['createdAt'] as Timestamp).toDate();
    userEmail = json['userEmail'];
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isSearching': isSearching,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'userEmail': userEmail,
    };
  }
}
