import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class FirestoreController extends GetxController {
  // Tạo một observable để lưu trữ danh sách người dùng
  var usersList = <UserModel>[].obs;
  final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  // Fetch dữ liệu từ Firestore
  Future<void> fetchUsers() async {
    try {
      // Lấy tất cả dữ liệu từ collection 'users'
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Chuyển đổi document thành đối tượng UserModel và cập nhật danh sách observable
      usersList.value = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  // Hàm cập nhật totalCoins và totalWins
  Future<void> incrementCoinsAndWins() async {
    try {
      String userId = authController.getCurrentUserId();
      int userIndex = usersList.indexWhere((user) => user.id == userId);

      // Tăng totalCoins lên 10 và totalWins lên 1
      int newCoins = int.parse(usersList[userIndex].totalCoins ?? "0") + 10;
      int newWins = int.parse(usersList[userIndex].totalWins ?? "0") + 1;

      // Cập nhật dữ liệu trong Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'totalCoins': newCoins.toString(),
        'totalWins': newWins.toString(),
      }).catchError((e) => errorMessage(e.toString()));

      // Cập nhật danh sách người dùng trong ứng dụng
      if (userIndex != -1) {
        usersList[userIndex].totalCoins = newCoins.toString();
        usersList[userIndex].totalWins = newWins.toString();
        usersList.refresh(); // Cập nhật giao diện
      }
    } catch (e) {
      errorMessage(e.toString());
    }
  }
}
