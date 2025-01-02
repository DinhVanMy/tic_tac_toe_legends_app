import 'package:cloud_firestore/cloud_firestore.dart';

class PostPollsModel {
  String? pollId; // ID của poll
  String? question; // Câu hỏi trong poll
  DateTime? endDate; // Ngày kết thúc poll
  List<OptionalPolls>? options; // Các lựa chọn trong poll
  List<String>? voterList;

  PostPollsModel({
    this.pollId,
    this.question,
    this.endDate,
    this.options,
    this.voterList,
  });

  // Constructor để chuyển từ JSON sang PostPollsModel
  PostPollsModel.fromJson(Map<String, dynamic> json) {
    pollId = json['pollId'] as String?;
    question = json['question'] as String?;
    if (json['endDate'] is Timestamp) {
      endDate = (json['endDate'] as Timestamp).toDate();
    }
    if (json['options'] is List) {
      options = (json['options'] as List)
          .map((option) => OptionalPolls.fromJson(option))
          .toList();
    }
    if (json['voterList'] is List) {
      voterList = List<String>.from(json['voterList']);
    }
  }

  // Phương thức để chuyển PostPollsModel thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pollId'] = pollId;
    data['question'] = question;
    if (endDate != null) {
      data['endDate'] = Timestamp.fromDate(endDate!);
    }
    if (options != null) {
      data['options'] = options?.map((option) => option.toJson()).toList();
    }
    data['voterList'] = voterList;

    return data;
  }
}

class OptionalPolls {
  int? id; // ID của lựa chọn
  String? title; // Nội dung của lựa chọn
  int? votes; // Số lượng votes của lựa chọn
    List<String>? votedUserIds;

  OptionalPolls({
    this.id,
    this.title,
    this.votes,
    this.votedUserIds,
  });

  // Constructor để chuyển từ JSON sang PollOption
  OptionalPolls.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    title = json['title'] as String?;
    votes = json['votes'] as int? ?? 0;
    if (json['votedUserIds'] is List) {
      votedUserIds = List<String>.from(json['votedUserIds']);
    }
  }

  // Phương thức để chuyển PollOption thành JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['votes'] = votes;
    if (votedUserIds!= null) {
      data['votedUserIds'] = votedUserIds;
    }

    return data;
  }
}
