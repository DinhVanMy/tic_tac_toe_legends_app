import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:ui' as ui;
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
        AndroidInitializationSettings('app_logo');
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
    // Yêu cầu quyền thông báo (Android 13+)
    bool? notificationGranted =
        await androidPlugin?.requestNotificationsPermission();
    if (notificationGranted != null && !notificationGranted) {
      errorMessage("Quyền thông báo bị từ chối!");
    }

    // Yêu cầu quyền full-screen intent (API 34+)
    bool? fullScreenGranted =
        await androidPlugin?.requestFullScreenIntentPermission();
    if (fullScreenGranted != null && !fullScreenGranted) {
      errorMessage("Quyền full-screen intent bị từ chối!");
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
      largeIcon: DrawableResourceAndroidBitmap('branding'),
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
    Uint8List largeIconBytes = await _loadNetworkImage(callerImage);
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
      timeoutAfter: 35000, // Hết hạn sau 30 giây
      visibility: NotificationVisibility.public,
      actions: [
        const AndroidNotificationAction(
          'decline_call',
          'DECLINE',
          showsUserInterface: true,
          titleColor: Colors.redAccent,
        ),
        const AndroidNotificationAction(
          'accept_call',
          'ACCEPT',
          showsUserInterface: true,
          titleColor: Colors.greenAccent,
        ),
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
      String senderName, String message, String senderImage) async {
    Uint8List largeIconBytes = await _loadNetworkImage(senderImage);
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'message_channel_v2',
      'Message notifications',
      channelDescription: 'Notification channel for message notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.blue,
      largeIcon: ByteArrayAndroidBitmap(largeIconBytes),
      ledColor: Colors.lightBlueAccent,
      ledOnMs: 1000, // Đèn LED bật trong 1 giây
      ledOffMs: 1000, // Đèn LED tắt trong 1 giây
      vibrationPattern: Int64List.fromList([0, 100, 200, 100]),
      groupKey: 'message_group_$senderName', // Nhóm theo người gửi
      setAsGroupSummary: false, // Thông báo chi tiết
      actions: [
        const AndroidNotificationAction('dismiss_mess', 'DISMISS'),
        const AndroidNotificationAction('reply_mess', 'REPLY',
            showsUserInterface: true, allowGeneratedReplies: true),
      ],
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification_sound'),
    );

    // Tạo thông báo tổng hợp cho nhóm
    final AndroidNotificationDetails groupSummaryDetails =
        AndroidNotificationDetails(
      'message_channel_v2',
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
      // Kiểm tra cache bằng DefaultCacheManager
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null) {
        // Nếu ảnh đã có trong cache, đọc byte từ file cache
        return await fileInfo.file.readAsBytes();
      } else {
        // Nếu không có trong cache, tải từ mạng và lưu vào cache
        final file = await DefaultCacheManager().getSingleFile(url);
        return await file.readAsBytes();
      }
    } catch (e) {
      throw Exception('Error loading network image: $e');
    }
  }

  Future<Uint8List> _processImageWithCanvas(Uint8List imageBytes,
      {int borderWidth = 2, Color borderColor = Colors.blueAccent}) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(uiImage.width.toDouble() + borderWidth * 2,
        uiImage.height.toDouble() + borderWidth * 2);

    // Vẽ viền
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paintBorder);

    // Vẽ ảnh bo tròn
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth.toDouble(), borderWidth.toDouble(),
          uiImage.width.toDouble(), uiImage.height.toDouble()),
      Radius.circular(uiImage.width / 2),
    ));
    canvas.drawImage(uiImage,
        Offset(borderWidth.toDouble(), borderWidth.toDouble()), Paint());
    canvas.restore();

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
