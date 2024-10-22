import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/daily_reward_storage.dart';
import 'package:tictactoe_gameapp/Components/daily_gift/reward_model.dart';

class DailyRewardController extends GetxController {
  final rewards = <Reward>[].obs;
  final today = DateTime.now().obs;
  final RewardStorage rewardStorage = RewardStorage(); // Sử dụng RewardStorage

  @override
  void onInit() {
    super.onInit();
    rewardStorage
        .checkAndClearOldRewards(today.value); // Kiểm tra và xóa phần thưởng cũ
    loadRewards();
    ever(today, (_) => loadRewards()); // Tải lại phần thưởng khi ngày thay đổi
    updateToday(); // Cập nhật ngày hiện tại ngay khi init
  }

  // Tải trạng thái phần thưởng
  void loadRewards() {
    final currentMonth = today.value.month;
    final currentYear = today.value.year;

    // Nếu danh sách chưa có dữ liệu, tạo phần thưởng theo tháng
    if (rewards.isEmpty) {
      rewards.value = generateMonthlyRewards(currentYear, currentMonth);
    }

    // Lấy danh sách ngày đã nhận phần thưởng trong tháng
    final collectedRewards =
        rewardStorage.loadCollectedRewards(currentMonth, currentYear);

    // Cập nhật trạng thái phần thưởng đã nhận
    for (var reward in rewards) {
      reward.isCollected = collectedRewards.contains(reward.date);
    }
  }

  // Hàm cập nhật ngày hiện tại
  void updateToday() {
    final now = DateTime.now();
    if (now.day != today.value.day ||
        now.month != today.value.month ||
        now.year != today.value.year) {
      today.value = now; // Chỉ cập nhật khi ngày thay đổi
      rewardStorage
          .checkAndClearOldRewards(today.value); // Xóa phần thưởng cũ nếu cần
      loadRewards(); // Tải lại phần thưởng cho tháng mới
    }
  }

  // Hàm nhận phần thưởng
  Future<void> collectReward(int index) async {
    final reward = rewards[index];
    if (isToday(reward.date) && !reward.isCollected) {
      reward.isCollected = true;
      rewardStorage.saveRewardCollected(reward.date); // Lưu phần thưởng đã nhận
      rewards.refresh(); // Cập nhật lại danh sách phần thưởng
    }
  }

  // Kiểm tra xem ngày hiện tại có trùng với ngày phần thưởng hay không
  bool isToday(DateTime date) {
    final now = today.value;
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  // Kiểm tra nếu ngày thuộc về quá khứ
  bool isPast(DateTime date) {
    return date.isBefore(today.value);
  }

  // Kiểm tra nếu ngày thuộc về tương lai
  bool isFuture(DateTime date) {
    return date.isAfter(today.value);
  }

  // Tạo danh sách phần thưởng theo tháng
  List<Reward> generateMonthlyRewards(int year, int month) {
    int daysInMonth = DateTime(year, month + 1, 0).day;

    // Tạo danh sách phần thưởng cho mỗi ngày trong tháng
    return List.generate(daysInMonth, (index) {
      late final RewardType type;

      // Cứ mỗi ngày thứ 7, 14, 21, 28 thì phần thưởng sẽ là hero, còn lại là coin
      if ((index + 1) % 7 == 0) {
        type = RewardType.hero;
      } else {
        type = RewardType.coin;
      }

      return Reward(
        date: DateTime(year, month, index + 1),
        rewardType: type,
      );
    });
  }
}
