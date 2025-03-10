import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/auth_controller.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class FirestoreController extends GetxController {
  // Tạo một observable để lưu trữ danh sách người dùng
  var usersList = <UserModel>[].obs;
  // Danh sách bạn bè của user
  var friendsList = <UserModel>[].obs;
  var filterfriendsList = <UserModel>[].obs;
  var searchText = ''.obs;
  var isLoadingFriends = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = Get.find<AuthController>().getCurrentUserId();

  // Đăng ký subscription cho dữ liệu thời gian thực
  late StreamSubscription usersSubscription;
  late StreamSubscription friendsSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    loadFriendsLive();
    setupSearchListener();
  }

  // Fetch dữ liệu từ Firestore theo thời gian thực
  void fetchUsers() {
    try {
      usersSubscription =
          _firestore.collection('users').snapshots().listen((snapshot) {
        usersList.value =
            snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      }, onError: (e) {
        errorMessage(e.toString());
      });
    } catch (e) {
      errorMessage('Failed to fetch users: $e');
    }
  }

  // Thêm bạn vào danh sách
  Future<void> addFriend(String friendId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'friendsList': FieldValue.arrayUnion([friendId])
      }).catchError((e) => errorMessage(e.toString()));
      // await loadFriends();
    } catch (e) {
      errorMessage('Failed to add friend: $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'friendsList': FieldValue.arrayRemove([friendId])
      }).catchError((e) => errorMessage(e.toString()));
      // await loadFriends();
    } catch (e) {
      errorMessage('Failed to remove friend: $e');
    }
  }

  Future<void> loadFriendsLive() async {
    isLoadingFriends.value = true;
    try {
      friendsSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((DocumentSnapshot userSnapshot) async {
        if (userSnapshot.exists) {
          friendsList.clear(); // Xóa danh sách bạn bè hiện tại để cập nhật
          List<dynamic> friendsIds = userSnapshot['friendsList'] ?? [];

          // Nếu có bạn bè, tải thông tin bạn bè
          if (friendsIds.isNotEmpty) {
            List<UserModel> updatedFriends = [];
            for (String friendId in friendsIds) {
              DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(friendId)
                  .get();

              if (friendSnapshot.exists) {
                UserModel friend = UserModel.fromJson(
                    friendSnapshot.data() as Map<String, dynamic>);
                updatedFriends.add(friend);
              }
            }
            friendsList.value = updatedFriends; // Cập nhật danh sách bạn bè
          } else {
            friendsList.clear(); // Nếu không có bạn bè, danh sách sẽ rỗng
          }
        }
        isLoadingFriends.value = false;
        filterFriends();
      }, onError: (e) {
        errorMessage(e.toString());
        isLoadingFriends.value = false;
      });
    } catch (e) {
      errorMessage(e.toString());
      isLoadingFriends.value = false;
    }
  }

  RxBool isFriend(String friendId) {
    return RxBool(friendsList.any((friend) => friend.id == friendId));
  }

  // Hàm thiết lập lắng nghe sự thay đổi của searchText
  void setupSearchListener() {
    debounce(searchText, (_) => filterFriends(),
        time: const Duration(milliseconds: 300));
  }

  // Hàm lọc friendRequests dựa trên searchText
  void filterFriends() {
    // Nếu không có nội dung tìm kiếm, hiển thị toàn bộ friendRequests
    if (searchText.isEmpty) {
      filterfriendsList.assignAll(friendsList);
    } else {
      final searchLower = searchText.value.toLowerCase();

      // Lọc danh sách theo nội dung tìm kiếm
      filterfriendsList.assignAll(friendsList.where((friends) {
        final name = friends.name!.toLowerCase();
        return name.contains(searchLower);
      }).toList());
    }
  }

  // Hàm cập nhật nội dung tìm kiếm khi người dùng nhập text
  void updateSearchText(String text) {
    searchText.value =
        text.toLowerCase(); // Chuyển sang chữ thường khi cập nhật
  }

  // Hàm cập nhật totalCoins và totalWins
  Future<void> incrementCoinsAndWins() async {
    try {
      int userIndex = usersList.indexWhere((user) => user.id == userId);

      // Tăng totalCoins lên 10 và totalWins lên 1
      int newCoins = int.parse(usersList[userIndex].totalCoins ?? "0") + 10;
      int newWins = int.parse(usersList[userIndex].totalWins ?? "0") + 1;

      // Cập nhật dữ liệu trong Firestore
      await _firestore.collection('users').doc(userId).update({
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

  late LatLng latlng;
  Future<void> fetchUserLocation() async {
    await _firestore.collection('users').doc(userId).get().then((value) {
      UserModel user = UserModel.fromJson(value.data()!);
      if (user.location != null) {
        latlng = LatLng(user.location!.latitude, user.location!.longitude);
      } else {
        latlng = const LatLng(21.0000992, 105.8399243);
      }
    });
  }

  @override
  void onClose() {
    usersSubscription.cancel();
    friendsSubscription.cancel();
    super.onClose();
  }
}
