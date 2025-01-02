import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

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

  static String displayTimeCount(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return "${_padZero(dateTime.day)}/${_padZero(dateTime.month)}/${dateTime.year} - "
        "${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}";
  }

  /// Hàm thêm số 0 phía trước nếu số nhỏ hơn 10
  static String _padZero(int value) {
    return value < 10 ? "0$value" : value.toString();
  }

  // Hiển thị DatePicker với điều kiện thời gian chọn phải lớn hơn hiện tại
  static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    final currentDate = DateTime.now();
    initialDate ??= currentDate;

    if (initialDate.isBefore(
        DateTime(currentDate.year, currentDate.month, currentDate.day))) {
      initialDate = currentDate;
    }

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: DateTime(currentDate.year + 5),
      selectableDayPredicate: (DateTime day) {
        // Chỉ cho phép chọn các ngày hôm nay hoặc sau đó
        return !day.isBefore(
            DateTime(currentDate.year, currentDate.month, currentDate.day));
      },
    );
  }

  /// Hiển thị TimePicker
  static Future<TimeOfDay?> pickTime(
      {required BuildContext context, TimeOfDay? initialTime}) async {
    initialTime ??= TimeOfDay.now();

    return showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  /// Hiển thị DateTime Picker với điều kiện thời gian lớn hơn hiện tại
  static Future<DateTime?> pickDateTime(BuildContext context,
      {DateTime? initialDateTime}) async {
    DateTime now = DateTime.now();
    initialDateTime ??= now;

    // Chọn ngày
    DateTime? selectedDate = await pickDate(
      context: context,
      initialDate: initialDateTime,
    );
    if (selectedDate == null) return null; // Người dùng hủy chọn ngày

    // Chọn giờ
    TimeOfDay? selectedTime = await pickTime(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (selectedTime == null) return null; // Người dùng hủy chọn thời gian

    // Kết hợp ngày và giờ
    DateTime selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Kiểm tra nếu thời gian chọn nhỏ hơn hiện tại
    if (selectedDateTime.isBefore(now)) {
      errorMessage("Please select a deadline before the current");
      return null;
    }

    return selectedDateTime;
  }
}
