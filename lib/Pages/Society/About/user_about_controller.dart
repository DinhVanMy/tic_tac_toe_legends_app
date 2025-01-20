import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';
import 'package:tictactoe_gameapp/Pages/Society/social_post_model.dart';

class UserAboutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var friendsList = <UserModel>[].obs;
  var postsList = <PostModel>[].obs;

  final String userId;
  UserAboutController({required this.userId});

  @override
  void onInit() async {
    super.onInit();
    fetchFriendsList();
    fetchPostsList();
  }

  // Tải danh sách bạn bè từ Firestore khi khởi tạo
  Future<void> fetchFriendsList() async {
    try {
      friendsList.clear();

      // Lấy thông tin của người dùng hiện tại
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        List<dynamic> friendsIds = userSnapshot['friendsList'] ?? [];

        // Tạo danh sách các futures để tải dữ liệu của từng friend ID
        List<Future<DocumentSnapshot>> friendSnapshotsFutures = friendsIds
            .map(
              (friendId) => _firestore.collection('users').doc(friendId).get(),
            )
            .toList();

        // Chờ tất cả futures hoàn thành
        List<DocumentSnapshot> friendSnapshots =
            await Future.wait(friendSnapshotsFutures);

        // Lọc ra các bạn bè đã tồn tại và chuyển thành UserModel
        friendsList.addAll(friendSnapshots
            .where((snapshot) => snapshot.exists)
            .map((snapshot) =>
                UserModel.fromJson(snapshot.data() as Map<String, dynamic>))
            .toList());
      }
    } catch (e) {
      errorMessage(e.toString());
    }
  }

  // Hàm lấy danh sách bài đăng của người dùng hiện tại từ Firestore
  Future<void> fetchPostsList() async {
    try {
      // Query các tài liệu trong collection 'posts' với điều kiện postUserId == currentUserId
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .where('postUser.id', isEqualTo: userId)
          .get();

      // Chuyển đổi danh sách tài liệu thành danh sách PostModel
      List<PostModel> posts = querySnapshot.docs.map((doc) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      postsList.value = posts;
    } catch (e) {
      errorMessage("Error fetching posts by current user: $e");
    }
  }
}
