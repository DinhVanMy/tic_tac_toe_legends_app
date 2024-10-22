import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String name;
  String description;
  String type;
  int reward;
  int progress;
  int goal;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deadline;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.reward,
    required this.progress,
    required this.goal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deadline,
  });

  // Convert Firestore document to TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      reward: json['reward'],
      progress: json['progress'],
      goal: json['goal'],
      status: json['status'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      deadline: (json['deadline'] as Timestamp).toDate(),
    );
  }

  // Convert TaskModel to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name': name,
      'description': description,
      'type': type,
      'reward': reward,
      'progress': progress,
      'goal': goal,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deadline': deadline,
    };
  }
}
