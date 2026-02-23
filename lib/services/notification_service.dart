import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool get supported => Platform.isAndroid || Platform.isIOS;

  Future<void> init() async {
    if (!supported) return;

    const settings = InitializationSettings(

        android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    await _plugin.initialize(settings: settings);
  }

  Future<void> show(String title, String body) async {
    if (!supported) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'sms_channel',
        'SMS Alerts',
        importance: Importance.max,
        priority: Priority.max,
      ),
    );

    await _plugin.show(
        id: 0, title: title, body: body, notificationDetails: details);
  }
}

