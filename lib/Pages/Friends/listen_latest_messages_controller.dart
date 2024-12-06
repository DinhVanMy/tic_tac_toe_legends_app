import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Controller/profile_controller.dart';
import 'package:tictactoe_gameapp/Models/message_friend_model.dart';
import 'package:tictactoe_gameapp/Models/user_model.dart';

class ListenLatestMessagesController extends GetxController {
  final ProfileController profileController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<MessageFriendModel> latestMessages = <MessageFriendModel>[].obs;
  late final UserModel currentUser;
  final Map<String, StreamSubscription> _listeners = {};

  @override
  void onInit() async {
    super.onInit();
    currentUser = profileController.user!;
    await fetchLatestMessages(); // Lấy dữ liệu nhanh ban đầu
  }

  // Tạo ID phòng chat dựa trên userId và friendId
  String _getChatRoomId(String friendId) {
    return currentUser.id.hashCode <= friendId.hashCode
        ? '${currentUser.id}-$friendId'
        : '$friendId-${currentUser.id}';
  }

  // Hàm lấy tin nhắn gần nhất cho từng bạn bè
  Future<void> fetchLatestMessages() async {
    List<MessageFriendModel> initialMessages =
        await getLatestMessagesFromFriends();
    latestMessages.value =
        initialMessages; // Cập nhật danh sách tin nhắn ban đầu
    listenToLatestMessages(initialMessages.map((m) => m.senderId!).toList());
  }

  // Hàm lấy tin nhắn mới nhất của bạn bè (không bao gồm listener)
  Future<List<MessageFriendModel>> getLatestMessagesFromFriends() async {
    List<Future<MessageFriendModel?>> futures = [];

    if (currentUser.friendsList != null) {
      for (String friendId in currentUser.friendsList!) {
        String chatId = _getChatRoomId(friendId);

        futures.add(
          _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final messageData = querySnapshot.docs.first.data();
              return MessageFriendModel.fromJson(messageData);
            }
            return null;
          }).catchError((e) {
            errorMessage("Error fetching message for friend $friendId: $e");
            return null;
          }),
        );
      }
    }
    // Chờ tất cả Futures hoàn tất và lọc kết quả
    List<MessageFriendModel?> results = await Future.wait(futures);
    return results
        .where((message) => message != null)
        .cast<MessageFriendModel>()
        .toList();
  }

  // Lắng nghe thay đổi real-time cho từng friend
  void listenToLatestMessages(List<String> friendIds) {
    // Hủy bỏ các listener cũ nếu tồn tại
    for (var listener in _listeners.values) {
      listener.cancel();
    }
    _listeners.clear();

    for (String friendId in friendIds) {
      String chatId = _getChatRoomId(friendId);

      _listeners[friendId] = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          //     .listen((snapshot) {
          //   for (var change in snapshot.docChanges) {
          //     if (change.type == DocumentChangeType.added) {
          //       // Xử lý tin nhắn mới được thêm vào
          //       var newMessage = MessageFriendModel.fromJson(
          //         change.doc.data() as Map<String, dynamic>,
          //       );

          //       // Kiểm tra xem tin nhắn đã tồn tại chưa, nếu chưa thì thêm vào đầu danh sách
          //       if (!latestMessages
          //           .any((msg) => msg.messageId == newMessage.messageId)) {
          //         latestMessages.insert(
          //             0, newMessage); // Thêm tin nhắn mới vào đầu danh sách
          //       }
          //     } else if (change.type == DocumentChangeType.modified) {
          //       // Xử lý tin nhắn đã được chỉnh sửa
          //       var updatedMessage = MessageFriendModel.fromJson(
          //         change.doc.data() as Map<String, dynamic>,
          //       );

          //       // Tìm và cập nhật tin nhắn trong danh sách
          //       final index = latestMessages
          //           .indexWhere((msg) => msg.messageId == updatedMessage.messageId);
          //       if (index != -1) {
          //         latestMessages[index] = updatedMessage;
          //       }
          //     } else if (change.type == DocumentChangeType.removed) {
          //       // Xử lý khi tin nhắn bị xóa
          //       final messageId = change.doc.id;

          //       // Xóa tin nhắn khỏi danh sách nếu tồn tại
          //       latestMessages.removeWhere((msg) => msg.messageId == messageId);
          //     }
          //   }
          // });
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final messageData = snapshot.docs.first.data();
          final message = MessageFriendModel.fromJson(messageData);

          int index = latestMessages
              .indexWhere((m) => m.messageId == message.messageId);
          if (index != -1) {
            latestMessages[index] = message;
          } else {
            latestMessages.add(message);
          }
        }
      });
    }
  }

  @override
  void onClose() {
    for (var listener in _listeners.values) {
      listener.cancel();
    }
    super.onClose();
  }
}
