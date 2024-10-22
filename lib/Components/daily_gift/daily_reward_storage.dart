import 'package:get_storage/get_storage.dart';

class RewardStorage {
  final GetStorage _box = GetStorage();

  // Lưu trạng thái đã nhận phần thưởng trong ngày hôm nay
  void saveRewardCollected(DateTime date) {
    final key = 'reward_${date.day}_${date.month}_${date.year}';
    _box.write(key, true);
    _box.write('last_saved_month', date.month); // Lưu tháng hiện tại để theo dõi
  }

  // Kiểm tra trạng thái đã nhận phần thưởng của ngày
  bool isRewardCollected(DateTime date) {
    final key = 'reward_${date.day}_${date.month}_${date.year}';
    return _box.read(key) ?? false;
  }

  // Tải tất cả các phần thưởng đã nhận trong tháng
  Set<DateTime> loadCollectedRewards(int month, int year) {
    Set<DateTime> collectedDates = {};
    for (int day = 1; day <= DateTime(year, month + 1, 0).day; day++) {
      final date = DateTime(year, month, day);
      if (isRewardCollected(date)) {
        collectedDates.add(date);
      }
    }
    return collectedDates;
  }

  // Xóa tất cả các phần thưởng đã lưu của tháng trước
  void clearPreviousMonthRewards(int currentMonth, int currentYear) {
    // Lấy tháng đã lưu cuối cùng
    final lastSavedMonth = _box.read('last_saved_month') ?? currentMonth;

    // Nếu tháng mới khác với tháng cuối cùng đã lưu, xóa dữ liệu của tháng trước
    if (lastSavedMonth != currentMonth) {
      // Xóa phần thưởng của tháng trước
      for (int day = 1; day <= DateTime(currentYear, lastSavedMonth + 1, 0).day; day++) {
        final oldKey = 'reward_${day}_${lastSavedMonth}_$currentYear';
        _box.remove(oldKey); // Xóa các phần thưởng đã lưu của tháng trước
      }
      _box.write('last_saved_month', currentMonth); // Cập nhật lại tháng hiện tại sau khi xóa
    }
  }

  // Hàm kiểm tra và xóa phần thưởng của tháng trước nếu cần
  void checkAndClearOldRewards(DateTime currentDate) {
    clearPreviousMonthRewards(currentDate.month, currentDate.year);
  }
}
