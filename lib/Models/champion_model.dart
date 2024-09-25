class ChampionModel {
  final String? image;
  final String? name;

  ChampionModel({this.image, this.name});

  static String capitalize(String s) {
    if (s.isEmpty) return s; // Kiểm tra chuỗi rỗng
    return s[0].toUpperCase() + s.substring(1);
  }

  static String capitalizeEachWord(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
