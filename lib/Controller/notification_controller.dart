import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _initializeAwesomeNotifications();
    await _requestPermissions();
    await _registerDeviceToken();
    _listenToMessages();
    _listenToNotificationActions();
    await showNotification(
      'Welcome!',
      'Win a game today!${Emojis.computer_desktop_computer} ${Emojis.building_sunset} ${Emojis.flag_Vietnam} ${Emojis.hand_victory_hand}',
      {'screen': 'SplacePage'},
    );
  }

  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          // soundSource: notifySamSung,
        ),
      ],
    );
  }

  Future<void> _requestPermissions() async {
    if (GetPlatform.isAndroid) {
      await _requestAndroidPermissions();
    } else if (GetPlatform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _requestIOSPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {}
  }

  Future<void> _registerDeviceToken() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      // Optionally, send the token to your server for further processing.
    }
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageOpenedApp(message);
    });
  }

  void _listenToNotificationActions() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _handleNotificationAction,
    );
  }

  void _handleMessage(RemoteMessage message) {
    String? title = message.notification?.title ?? 'No title';
    String? body = message.notification?.body ?? 'No body';
    Map<String, dynamic> data = message.data;

    showNotification(title, body, data);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Chuyển đổi kiểu dữ liệu từ Map<String, dynamic> sang Map<String, String?>
    Map<String, String?> convertedData =
        message.data.map((key, value) => MapEntry(key, value.toString()));
    _navigateToScreen(convertedData);
  }

  static Future<void> _handleNotificationAction(
      ReceivedAction receivedAction) async {
    _navigateToScreen(receivedAction.payload);
  }

  Future<void> showNotification(
      String title, String body, Map<String, dynamic> data) async {
    // Chuyển đổi data từ Map<String, dynamic> sang Map<String, String?>
    Map<String, String?> payload =
        data.map((key, value) => MapEntry(key, value.toString()));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigPicture,
        bigPicture: 'asset://assets/icons/appLogo.png',
        payload: payload, // Truyền payload đã được chuyển đổi
        // customSound: notifySamSung,
        color: Colors.white,
        backgroundColor: bgColor,
        // icon: 'resource://drawable/tic-tac-toe-x',
      ),
      // schedule: NotificationInterval(
      //   interval: 5,
      //   timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      //   preciseAlarm: true,
      // ),
    );
  }

  static void _navigateToScreen(Map<String, String?>? data) {
    if (data != null && data['screen'] == 'SplacePage') {
      Get.offAllNamed("/splace");
    } else {}
  }

  int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
