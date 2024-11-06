import 'package:cloud_firestore/cloud_firestore.dart';

class TimeFunctions {
  static String timeAgo({required DateTime now, required DateTime createdAt}) {
    Duration difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'a few seconds ago'; // Dưới 1 phút
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""} ago'; // Dưới 1 giờ
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago'; // Dưới 1 ngày
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago'; // Dưới 1 tuần
    }
    if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? "s" : ""} ago'; // Dưới 1 tháng
    }
    if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? "s" : ""} ago'; // Dưới 1 năm
    }

    int years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? "s" : ""} ago'; // Lâu hơn 1 năm
  }

  static String displayTimeDefault(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String hours = dateTime.hour.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  static String displayTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    // Lấy giờ theo định dạng 12 giờ
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String minutes = dateTime.minute.toString().padLeft(2, '0');

    // Xác định AM hay PM
    String period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return "$hour:$minutes $period";
  }

  static String displayDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    return "$day/$month/$year";
  }
}
