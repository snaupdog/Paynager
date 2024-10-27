import 'package:flutter/material.dart';
import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final EasySmsReceiver easySmsReceiver = EasySmsReceiver.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _messageText = "Waiting for SMS...";

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
    _startListeningForSms();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(initSettings);
  }

  Future<void> _requestPermissions() async {
    var smsStatus = await Permission.sms.request();
    var notificationStatus = await Permission.notification.request();

    if (!smsStatus.isGranted) {
      print('SMS permission denied');
    }
    if (!notificationStatus.isGranted) {
      print('Notification permission denied');
    }
  }

  void _startListeningForSms() {
    easySmsReceiver.listenIncomingSms(onNewMessage: (message) {
      setState(() {
        _messageText = message.body ?? "No content";
      });
      _showNotification("New SMS", message.body ?? "No content");
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sms_channel', // Channel ID
      'SMS Notifications', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SMS Receiver")),
      body: Center(
        child: Text(
          _messageText,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
