class ChatFriendSettingsModel {
  String? id;
  List<String>? themeColors;
  bool? isNotified;

  ChatFriendSettingsModel({
    this.id,
    this.themeColors,
    this.isNotified,
  });

  ChatFriendSettingsModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["themeColors"] is List) {
      themeColors = List<String>.from(json["themeColors"]);
    }
    if (json["isNotified"] is bool) {
      isNotified = json["isNotified"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["themeColors"] = themeColors;
    data["isNotified"] = isNotified;
    return data;
  }
}
