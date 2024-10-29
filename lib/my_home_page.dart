import 'package:flutter/material.dart';
import 'package:easy_sms_receiver/easy_sms_receiver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final EasySmsReceiver easySmsReceiver = EasySmsReceiver.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String messageText = "Waiting for SMS...";
  String label = "";
  final List<String> buttonnames = [
    "Snacks",
    "Swiggy",
    "stationary",
    "grocery",
    "people",
    "travel"
  ];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
    _startListeningForSms();
  }

  Future<void> _addtodatabase() async {
    final transaction = <String, dynamic>{
      "message": messageText,
      "label": label,
    };

    try {
      final doc = await firestore.collection("transaction").add(transaction);
      print('DocumentSnapshot added with ID: ${doc.id}');
    } catch (e) {
      print('Error adding document: $e');
    }
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
      String messageBody = message.body ?? "No content";

      if (messageBody.contains("HDFC")) {
        setState(() {
          messageText = messageBody;
        });

        _showNotification("New HDFC SMS", messageBody);
      } else {
        print('Non-HDFC message received: $messageBody');
      }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'sms_channel',
      'SMS Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Button'),
          content:
              Text('Are you sure you want to delete "${buttonnames[index]}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  buttonnames.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Text("Add Label"),
        onPressed: () {
          addLabelDialog();
        },
      ),
      appBar: AppBar(title: const Text("SMS Receiver")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              messageText,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: buttonnames.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onLongPress: () {
                      _showDeleteDialog(index);
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          label = buttonnames[index];
                        });
                        print('Button ${buttonnames[index]} pressed');
                      },
                      child: Text(buttonnames[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              if (messageText != "Waiting for SMS...") {
                await _addtodatabase();
                setState(() {
                  messageText = "Submitted to Database!";
                  label = "";
                });
              } else {
                setState(() {
                  messageText = "Cannot submit without SMS";
                });
              }
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  label = "";
                  messageText = "Waiting for SMS...";
                });
              });
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<String?> addLabelDialog() async {
    String? label;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Label'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    label = value;
                  },
                  decoration: const InputDecoration(hintText: "Label"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  if (label != null && label!.isNotEmpty) {
                    buttonnames.add(label!);
                  }
                });
                Navigator.of(context).pop(label);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
