import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tictactoe_gameapp/Configs/messages.dart';
import 'package:tictactoe_gameapp/Configs/theme/colors.dart';

class NotificationController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _initializeAwesomeNotifications();
    await _requestPermissions();
    _listenToNotificationActions();
  }

  Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/app_logo',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          ledColor: Colors.white,
        ),
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'Call notifications',
          channelDescription: 'Notification channel for call notifications',
          defaultColor: Colors.green,
          ledColor: Colors.lightGreenAccent,
          importance: NotificationImportance.Max,
          vibrationPattern: highVibrationPattern, //List<int> lowVibrationPattern = [0, 100, 200, 100];
          channelShowBadge: true,
          criticalAlerts: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'message_channel',
          channelName: 'Message notifications',
          channelDescription: 'Notification channel for message notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          vibrationPattern: lowVibrationPattern,
          channelShowBadge: true,
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

  Future<void> _requestIOSPermissions() async {}

  void _listenToNotificationActions() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction action) async {
        switch (action.buttonKeyPressed) {
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
        }
      },
    );
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
        notificationLayout: NotificationLayout.Default,
        // bigPicture: 'asset://assets/icons/appLogo.png',
        payload: payload, // Truyền payload đã được chuyển đổi
        // customSound: notifySamSung,
        color: Colors.white,
        backgroundColor: bgColor,
        // icon: 'resource://drawable/tic-tac-toe-x',
      ),
    );
    
  }

  Future<void> showCallNotification(
    String callerName,
    String callerImage,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueId(),
        channelKey: 'call_channel',
        title: callerName,
        body: '📞 You have a call from your friend: $callerName',
        notificationLayout: NotificationLayout.Default,
        roundedLargeIcon: true,
        largeIcon: callerImage,
        timeoutAfter: const Duration(seconds: 30),
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'decline_call',
          label: 'DECLINE',
          color: Colors.redAccent,
        ),
        NotificationActionButton(
          key: 'accept_call',
          label: 'ACCEPT',
          color: Colors.greenAccent,
        )
      ],
    );
  }

  Future<void> showMessageNotification(
      String senderName, String message) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _createUniqueId(),
          channelKey: 'message_channel',
          title: senderName,
          body: "📩 $message",
          notificationLayout: NotificationLayout.Messaging,
          payload: {
            'type': 'message',
            'sender': senderName,
            'message': message
          },
        ),
        actionButtons: [
          NotificationActionButton(
              key: 'dismiss_mess',
              label: 'DISMISS',
              actionType: ActionType.DismissAction),
          NotificationActionButton(
              key: 'reply_mess',
              label: 'REPLY',
              requireInputText: true,
              actionType: ActionType.SilentAction,
              isDangerousOption: true)
        ]);
  }

  Future<void> showFriendRequestNotification(
      String requesterName, String requesterImage) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueId(),
        channelKey: 'message_channel', // Có thể dùng chung với kênh tin nhắn
        title: "Friend Request",
        body: "📨 $requesterName has sent you a friend request!",
        notificationLayout: NotificationLayout.Default,
        largeIcon: requesterImage, // Ảnh đại diện của người gửi yêu cầu
        payload: {
          'type': 'friend_request',
          'requester': requesterName,
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'decline_friend',
          label: 'DECLINE',
          color: Colors.redAccent,
        ),
        NotificationActionButton(
          key: 'accept_friend',
          label: 'ACCEPT',
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  int _createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
