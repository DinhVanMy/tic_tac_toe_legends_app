import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  // Khởi tạo thông báo và yêu cầu quyền
  Future<void> _initializeNotifications() async {
    await _initializeFlutterLocalNotifications();
    await _requestPermissions();
    _listenToNotificationActions();
  }

  // Khởi tạo flutter_local_notifications
  Future<void> _initializeFlutterLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('branding');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          // Xử lý payload dựa trên dữ liệu
          switch (response.payload) {
            case "accept_call":
              Get.offAllNamed("/mainHome");
              break;
            case "decline_call":
              errorMessage("Hmmm...");
              break;
            case "dismiss_mess":
              errorMessage("Hmmm...");
              break;
            default:
              Get.toNamed('/mainHome');
          }
        }
      },
    );
  }

  // Yêu cầu quyền thông báo
  Future<void> _requestPermissions() async {
    if (GetPlatform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (GetPlatform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    bool? isGranted = await androidPlugin?.requestNotificationsPermission();
    if (isGranted != null && !isGranted) {
      // Xử lý khi người dùng từ chối quyền
      errorMessage("Quyền thông báo bị từ chối!");
    }
  }

  Future<void> _requestIOSPermissions() async {
    final iosPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Lắng nghe tương tác với thông báo
  void _listenToNotificationActions() {
    // Xử lý tương tác được thực hiện trong onDidReceiveNotificationResponse
  }

  // Hiển thị thông báo chung
  Future<void> showNotification(
      String title, String body, Map<String, dynamic> data) async {
    Map<String, String?> payload =
        data.map((key, value) => MapEntry(key, value.toString()));
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'basic_channel_v2',
      'Basic notifications',
      channelDescription: 'Notification channel for basic notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.lightBlueAccent,
      largeIcon: DrawableResourceAndroidBitmap('notification_logo'),
      ledColor: Colors.white,
      ledOnMs: 1000, // Đèn LED bật trong 1 giây
      ledOffMs: 1000, // Đèn LED tắt trong 1 giây
      styleInformation: DefaultStyleInformation(true, true),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      _createUniqueId(),
      title,
      body,
      notificationDetails,
      payload: payload.toString(), // Chuyển payload thành chuỗi
    );
  }

  // Hiển thị thông báo cuộc gọi
  Future<void> showCallNotification(
      String callerName, String callerImage) async {
    final Uint8List largeIconBytes = await _loadNetworkImage(callerImage);
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'call_channel_v2',
      'Call notifications',
      channelDescription: 'Notification channel for call notifications',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.green,
      largeIcon: ByteArrayAndroidBitmap(largeIconBytes),
      ledColor: Colors.lightGreenAccent,
      ledOnMs: 1000, // Đèn LED bật trong 1 giây
      ledOffMs: 1000, // Đèn LED tắt trong 1 giây
      vibrationPattern: Int64List.fromList(
          [0, 1000, 500, 1000]), // Mô phỏng highVibrationPattern
      fullScreenIntent: true,
      timeoutAfter: 30000, // Hết hạn sau 30 giây
      actions: [
        const AndroidNotificationAction('decline_call', 'DECLINE',
            showsUserInterface: true),
        const AndroidNotificationAction('accept_call', 'ACCEPT',
            showsUserInterface: true),
      ],
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('call_sound'),
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      _createUniqueId(),
      callerName,
      '📞 You have a call from your friend: $callerName',
      notificationDetails,
      payload: 'accept_call', // Payload mặc định, có thể thay đổi theo logic
    );
  }

  // Hiển thị thông báo tin nhắn
  Future<void> showMessageNotification(
      String senderName, String message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'message_channel',
      'Message notifications',
      channelDescription: 'Notification channel for message notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
      vibrationPattern: Int64List.fromList([0, 100, 200, 100]),
      groupKey: 'message_group_$senderName', // Nhóm theo người gửi
      setAsGroupSummary: false, // Thông báo chi tiết
      actions: [
        const AndroidNotificationAction('dismiss_mess', 'DISMISS'),
        const AndroidNotificationAction('reply_mess', 'REPLY',
            showsUserInterface: true, allowGeneratedReplies: true),
      ],
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('message_sound'),
    );

    // Tạo thông báo tổng hợp cho nhóm
    final AndroidNotificationDetails groupSummaryDetails =
        AndroidNotificationDetails(
      'message_channel',
      'Message notifications',
      channelDescription: 'Notification channel for message notifications',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: 'message_group_$senderName',
      setAsGroupSummary: true, // Thông báo tổng hợp
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    final NotificationDetails summaryDetails =
        NotificationDetails(android: groupSummaryDetails);

    await flutterLocalNotificationsPlugin.show(
      _createUniqueId(),
      senderName,
      '📩 $message',
      notificationDetails,
      payload: 'dismiss_mess',
    );

    // Hiển thị thông báo tổng hợp
    await flutterLocalNotificationsPlugin.show(
      0, // ID cố định cho thông báo tổng hợp
      'New Messages',
      'You have new messages from $senderName',
      summaryDetails,
    );
  }

  // Hiển thị thông báo yêu cầu kết bạn
  Future<void> showFriendRequestNotification(
      String requesterName, String requesterImage) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'friend_channel',
      'Friend Request notifications',
      channelDescription:
          'Notification channel for friend request notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
      vibrationPattern: Int64List.fromList([0, 100, 200, 100]),
      styleInformation: BigPictureStyleInformation(
        FilePathAndroidBitmap(requesterImage), // Đường dẫn ảnh đại diện
        largeIcon: FilePathAndroidBitmap(requesterImage),
      ),
      actions: [
        const AndroidNotificationAction('decline_friend', 'DECLINE',
            showsUserInterface: true),
        const AndroidNotificationAction('accept_friend', 'ACCEPT',
            showsUserInterface: true),
      ],
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('friend_request_sound'),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      _createUniqueId(),
      'Friend Request',
      '📨 $requesterName has sent you a friend request!',
      notificationDetails,
      payload: 'accept_friend',
    );
  }

  // Tạo ID duy nhất cho thông báo
  int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

// Hàm tải ảnh từ assets
  Future<Uint8List> _loadAssetImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> _loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes; // Trả về dữ liệu byte của ảnh
      } else {
        throw Exception(
            'Failed to load image from URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading network image: $e');
    }
  }
}
