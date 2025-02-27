import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class FetchFirestoreDataFunctions{
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   Future<UserModel?> fetchUserByName(String name) async {
    try {
      // Tìm kiếm trong collection "users" với field "name"
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: name)
          .limit(1) // Giới hạn kết quả để chỉ lấy 1 user
          .get();

      // Nếu có kết quả, chuyển đổi document đầu tiên thành UserModel
      if (querySnapshot.docs.isNotEmpty) {
        final Map<String, dynamic> userData = querySnapshot.docs.first.data();
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      // Xử lý lỗi (nếu có)
      errorMessage('Error fetching user by name: $e');
    }
    return null; // Trả về null nếu không tìm thấy hoặc xảy ra lỗi
  }
   Future<List<UserModel>> fetchPostLikeUsers(List<String> likeUserIds) async {
    try {
      // Tạo danh sách các futures để tải dữ liệu của từng user ID
      List<Future<DocumentSnapshot>> userSnapshotsFutures = likeUserIds
          .map(
            (userId) => _firestore.collection('users').doc(userId).get(),
          )
          .toList();

      // Chờ tất cả futures hoàn thành
      List<DocumentSnapshot> userSnapshots =
          await Future.wait(userSnapshotsFutures);

      // Lọc ra các user đã tồn tại và chuyển thành UserModel
      List<UserModel> likeUsers = userSnapshots
          .where((snapshot) => snapshot.exists)
          .map((snapshot) =>
              UserModel.fromJson(snapshot.data() as Map<String, dynamic>))
          .toList();

      return likeUsers;
    } catch (e) {
      errorMessage("Error fetching post like users: $e");
      return [];
    }
  }
}