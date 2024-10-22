import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Models/message_friend_model.dart';
import 'package:uuid/uuid.dart';

class ChatFriendController extends GetxController {
  var messages = <MessageFriendModel>[].obs;
  var searchText = ''.obs; // Text tìm kiếm từ người dùng
  var filtermessages = <MessageFriendModel>[].obs;
  StreamSubscription? messageSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var uuid = const Uuid();
  final ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  var isFocused = false.obs;
  var isLoadingMore = false.obs;
  var hasMoreMessages = true.obs;
  var isEmptyMessage = false.obs;
  var isSearching = false.obs;
  final int pageSize = 10;
  DocumentSnapshot? lastDocument;

  final String currentUserId;
  final String friendId;
  ChatFriendController(this.currentUserId, this.friendId);

  @override
  void onInit() {
    super.onInit();
    deleteOldMessages();
    listenToMessages();
    setupSearchListener();
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
    scrollController.addListener(() {
      _onScroll();
    });
  }

  // Hàm lắng nghe tin nhắn theo thời gian thực cho tin nhắn mới
  void listenToMessages() {
    messageSubscription = _firestore
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((QuerySnapshot snapshot) {
      // Xử lý từng thay đổi trong snapshot
      if (snapshot.docs.isNotEmpty) {
        isEmptyMessage.value = false;
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            // Khi có tin nhắn mới
            var newMessage = MessageFriendModel.fromJson(
              change.doc.data() as Map<String, dynamic>,
            );

            // Kiểm tra xem tin nhắn này đã tồn tại chưa, nếu chưa thì thêm vào đầu danh sách
            if (!messages.any((msg) => msg.messageId == newMessage.messageId)) {
              messages.insert(
                  0, newMessage); // Thêm tin nhắn mới vào đầu danh sách
            }
          } else if (change.type == DocumentChangeType.modified) {
            // Khi có tin nhắn được chỉnh sửa
            var updatedMessage = MessageFriendModel.fromJson(
              change.doc.data() as Map<String, dynamic>,
            );

            // Tìm tin nhắn đã tồn tại và cập nhật
            final index = messages
                .indexWhere((msg) => msg.messageId == updatedMessage.messageId);
            if (index != -1) {
              messages[index] = updatedMessage; // Cập nhật tin nhắn đã sửa
            }
          } else if (change.type == DocumentChangeType.removed) {
            // Khi có tin nhắn bị xóa
            final messageId = change.doc.id;

            // Xóa tin nhắn khỏi danh sách
            messages.removeWhere((msg) => msg.messageId == messageId);
          }
        }
        filterMessages();
      } else {
        isEmptyMessage.value = true;
      }
    });
  }

  // Hàm thiết lập lắng nghe sự thay đổi của searchText
  void setupSearchListener() {
    debounce(searchText, (_) => filterMessages(),
        time: const Duration(milliseconds: 300));
  }

  // Hàm lọc friendRequests dựa trên searchText
  void filterMessages() {
    // Nếu không có nội dung tìm kiếm, hiển thị toàn bộ friendRequests
    if (searchText.isEmpty) {
      filtermessages.assignAll(messages);
    } else {
      final searchLower = searchText.value.toLowerCase();

      // Lọc danh sách theo nội dung tìm kiếm
      filtermessages.assignAll(messages.where((message) {
        final content = message.content ?? ".".toLowerCase();
        return content.contains(searchLower);
      }).toList());
    }
  }

  // Hàm cập nhật nội dung tìm kiếm khi người dùng nhập text
  void updateSearchText(String text) {
    searchText.value =
        text.toLowerCase(); // Chuyển sang chữ thường khi cập nhật
  }

  void loadMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value) return;

    isLoadingMore.value = true;

    try {
      QuerySnapshot snapshot;

      if (lastDocument != null) {
        snapshot = await _firestore
            .collection('chats')
            .doc(_getChatRoomId())
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .startAfterDocument(lastDocument!)
            .limit(pageSize)
            .get();
      } else {
        snapshot = await _firestore
            .collection('chats')
            .doc(_getChatRoomId())
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(pageSize)
            .get();
      }

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;

        // Tối ưu hóa kiểm tra trùng lặp bằng Set
        Set<String?> existingMessageIds =
            messages.map((msg) => msg.messageId).toSet();

        // Lọc và thêm các tin nhắn mới vào danh sách, tránh trùng lặp
        var newMessages = snapshot.docs
            .map((doc) =>
                MessageFriendModel.fromJson(doc.data() as Map<String, dynamic>))
            .where((newMessage) =>
                !existingMessageIds.contains(newMessage.messageId))
            .toList();

        if (newMessages.isNotEmpty) {
          messages
              .addAll(newMessages); // Thêm tất cả tin nhắn mới vào danh sách
        }
      }

      if (snapshot.docs.length < pageSize) {
        hasMoreMessages.value = false;
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Hàm gửi tin nhắn lên Firestore
  Future<void> sendMessage(
    String content,
  ) async {
    if (content.trim().isEmpty) {
      errorMessage("Please enter a message");
    }
    String id = _getChatRoomId() + uuid.v4().substring(0, 8);
    final message = MessageFriendModel(
      messageId: id,
      senderId: currentUserId,
      receiverId: friendId,
      content: content,
      timestamp: Timestamp.now(),
      status: 'sent',
    );

    await _firestore
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .doc(id)
        .set(message.toJson())
        .catchError(
            (e) => errorMessage("Please enter a message with lighter content"));
  }

  // Hàm gửi tin nhắn lên Firestore
  Future<void> sendImageMessage(
    String? content,
    XFile imageFile,
  ) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String? base64String = base64Encode(imageBytes);

    // Kiểm tra kích thước của chuỗi Base64
    int base64Size = calculateBase64Size(base64String);
    if (base64Size > 999999) {
      errorMessage("Please pick a image which is lighter than 1 mega byte");
    }

    String id = _getChatRoomId() + uuid.v4().substring(0, 8);
    final message = MessageFriendModel(
      messageId: id,
      senderId: currentUserId,
      receiverId: friendId,
      content: content,
      imagePath: base64String,
      timestamp: Timestamp.now(),
      status: 'sent',
    );

    await _firestore
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .doc(id)
        .set(message.toJson())
        .catchError((e) => errorMessage("Please, pick another image"));
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .doc(messageId)
        .delete()
        .catchError((e) => errorMessage(e));
  }

  //todo function for reply message
  Future<void> shareMessage(String content, String targetUserId) async {
    String id = _getChatRoomId() + uuid.v4().substring(0, 8);
    final message = MessageFriendModel(
      messageId: id,
      senderId: currentUserId,
      receiverId: targetUserId,
      content: content,
      timestamp: Timestamp.now(),
      // status: 'sent',
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(_getChatRoomId())
        .collection('messages')
        .doc(id)
        .set(message.toJson())
        .catchError((e) => errorMessage("Please, pick another image"));
  }

  //auto delete message after time out
  Future<void> deleteOldMessages() async {
    final Timestamp sevenDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .doc(_getChatRoomId())
          .collection('messages')
          .where('timestamp', isLessThan: sevenDaysAgo)
          .get();

      for (var doc in snapshot.docs) {
        await _firestore
            .collection('chats')
            .doc(_getChatRoomId())
            .collection('messages')
            .doc(doc.id)
            .delete()
            .catchError((e) => errorMessage('Error deleting old messages: $e'));
        print('Deleted messages 7 days ago');
      }
    } catch (e) {
      errorMessage('Error deleting old messages: $e');
    }
  }

  // Tạo ID phòng chat dựa trên userId và friendId
  String _getChatRoomId() {
    return currentUserId.hashCode <= friendId.hashCode
        ? '$currentUserId-$friendId'
        : '$friendId-$currentUserId';
  }

  int calculateBase64Size(String base64String) {
    int padding = base64String.endsWith('==')
        ? 2
        : base64String.endsWith('=')
            ? 1
            : 0;
    int size = (base64String.length * 3 / 4).floor() - padding;
    return size; // Kích thước tính bằng byte
  }

  Timer? _scrollStopTimer;
  // Hàm xử lý khi có sự kiện cuộn
  void _onScroll() {
    // Khi người dùng cuộn, đặt isSearching thành true
    isSearching.value = true;

    // Nếu Timer đang chạy thì hủy bỏ
    _scrollStopTimer?.cancel();

    // Tạo Timer mới: chờ 3 giây sau khi ngừng cuộn
    _scrollStopTimer = Timer(const Duration(seconds: 30), () {
      isSearching.value = false;
    });
  }

  @override
  void onClose() {
    messageSubscription?.cancel();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}

  // Hàm lắng nghe tin nhắn theo thời gian thực
  // void listenToMessages() {
  //   messageSubscription = _firestore
  //       .collection('chats')
  //       .doc(_getChatRoomId())
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) {
  //     messages.value = snapshot.docs
  //         .map((doc) =>
  //             MessageFriendModel.fromJson(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   });
  // }

  // for (var doc in snapshot.docs) {
  //         MessageFriendModel newMessage =
  //             MessageFriendModel.fromJson(doc.data() as Map<String, dynamic>);

  //         // Kiểm tra xem messageId đã tồn tại trong danh sách chưa
  //         if (!messages.any((msg) => msg.messageId == newMessage.messageId)) {
  //           messages.add(newMessage); // Thêm tin nhắn vào danh sách
  //         }
  //       }


// Future<List<int>> compressImageIfNecessary(XFile imageFile) async {
//   File file = File(imageFile.path);
//   int fileSize = await file.length(); // Kích thước file ban đầu
  
//   // Kiểm tra nếu file quá 1MB
//   if (fileSize > 1048576) {
//     int quality = getQualityBasedOnSize(fileSize); // Tính quality dựa vào kích thước file

//     List<int>? compressedImage = await FlutterImageCompress.compressWithFile(
//       imageFile.path,
//       quality: quality, // Nén với mức chất lượng thích hợp
//     );
//     if (compressedImage != null) {
//       print("Compressed from ${fileSize / 1024} KB to ${compressedImage.length / 1024} KB");
//       return compressedImage;
//     } else {
//       print("Compression failed. Returning original image bytes.");
//       return await imageFile.readAsBytes(); // Trả về file gốc nếu nén thất bại
//     }
//   } else {
//     print("Image size is under 1MB, no compression needed.");
//     return await imageFile.readAsBytes(); // Không cần nén
//   }
// }

// // Hàm tính toán quality dựa vào kích thước file
// int getQualityBasedOnSize(int fileSize) {
//   // Ví dụ logic: càng lớn thì quality càng thấp
//   if (fileSize > 5000000) {
//     return 30; // Nếu > 5MB thì nén với chất lượng 30%
//   } else if (fileSize > 3000000) {
//     return 50; // Nếu > 3MB thì nén với chất lượng 50%
//   } else if (fileSize > 2000000) {
//     return 70; // Nếu > 2MB thì nén với chất lượng 70%
//   } else {
//     return 85; // Nếu > 1MB thì nén với chất lượng 85%
//   }
// }
