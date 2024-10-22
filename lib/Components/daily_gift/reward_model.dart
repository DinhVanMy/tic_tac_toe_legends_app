class Reward {
  final DateTime date;
  bool isCollected;
  final RewardType rewardType;

  Reward({
    required this.date,
    required this.rewardType,
    this.isCollected = false,
  });
}

enum RewardType {
  coin,
  hero,
  diamond,
}
