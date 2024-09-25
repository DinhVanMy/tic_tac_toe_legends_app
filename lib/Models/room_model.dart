import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class RoomModel {
  String? id;
  String? winningPrize;
  UserModel? player1;
  UserModel? player2;
  String? gameStatus;
  String? player1Status;
  String? player2Status;
  List<String>? gameValue;
  bool? isXturn;
  DateTime? createdAt;
  String? pickedMap;
  String? winnerVariable;
  String? champX;
  String? champO;
  int? initialMode;
  int? winLengthMode;
  String? imageMode;
  RoomModel({
    this.id,
    this.winningPrize,
    this.player1,
    this.player2,
    this.gameStatus,
    this.player1Status,
    this.player2Status,
    this.gameValue,
    this.isXturn,
    required this.createdAt,
    this.pickedMap,
    this.winnerVariable,
    this.champX,
    this.champO,
    this.initialMode,
    this.winLengthMode,
    this.imageMode,
  });

  RoomModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["winningPrize"] is String) {
      winningPrize = json["winningPrize"];
    }
    if (json["player1"] is Map) {
      player1 =
          json["player1"] == null ? null : UserModel.fromJson(json["player1"]);
    }
    if (json["player2"] is Map) {
      player2 =
          json["player2"] == null ? null : UserModel.fromJson(json["player2"]);
    }
    if (json["gameStatus"] is String) {
      gameStatus = json["gameStatus"];
    }
    if (json["player1Status"] is String) {
      player1Status = json["player1Status"];
    }
    if (json["player2Status"] is String) {
      player2Status = json["player2Status"];
    }
    if (json["gameValue"] != null) {
      gameValue = List<String>.from(json["gameValue"]);
    }
    if (json["isXturn"] is bool) {
      isXturn = json["isXturn"];
    }
    createdAt = json['createdAt'] != null
        ? (json['createdAt'] as Timestamp).toDate()
        : null;
    if (json["pickedMap"] is String) {
      pickedMap = json["pickedMap"];
    }
    if (json["winnerVariable"] is String) {
      winnerVariable = json["winnerVariable"];
    }
    if (json["champX"] is String) {
      champX = json["champX"];
    }
    if (json["champO"] is String) {
      champO = json["champO"];
    }
    if (json["initialMode"] is int) {
      initialMode = json["initialMode"];
    }
    if (json["winLengthMode"] is int) {
      winLengthMode = json["winLengthMode"];
    }
    if (json["imageMode"] is String) {
      imageMode = json["imageMode"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["winningPrize"] = winningPrize;
    if (player1 != null) {
      data["player1"] = player1?.toJson();
    }
    if (player2 != null) {
      data["player2"] = player2?.toJson();
    }
    data["gameStatus"] = gameStatus;
    data["player1Status"] = player1Status;
    data["player2Status"] = player2Status;
    if (gameValue != null) {
      data["gameValue"] = gameValue;
    }
    data["isXturn"] = isXturn;
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    data["pickedMap"] = pickedMap;
    data["winnerVariable"] = winnerVariable;
    data["champX"] = champX;
    data["champO"] = champO;
    data["initialMode"] = initialMode;
    data["winLengthMode"] = winLengthMode;
    data["imageMode"] = imageMode;
    return data;
  }
}
