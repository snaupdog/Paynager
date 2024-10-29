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

  /// Function to add a user to Firestore
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

      // Filter messages that contain "HDFC"
      if (messageBody.contains("HDFC")) {
        setState(() {
          messageText = messageBody;
        });

        // Show notification for HDFC messages
        _showNotification("New HDFC SMS", messageBody);
      } else {
        print('Non-HDFC message received: $messageBody');
      }
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
      floatingActionButton: FloatingActionButton(
        child: const Text("add Label"),
        onPressed: () {
          addLabelDialog();
        },
      ),
      appBar: AppBar(title: const Text("SMS Receiver")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SMS Message Display

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
          // Horizontal Scrolling List of Buttons
          SizedBox(
            height: 50, // Height of the button container

            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Horizontal scrolling
              itemCount: buttonnames.length, // Number of buttons
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        label = buttonnames[index];
                      });
                      print('Button ${buttonnames[index]} pressed');
                    },
                    child: Text(buttonnames[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: () async {
                if (messageText.isNotEmpty) {
                  await _addtodatabase();
                  setState(() {
                    messageText = "Submitted to Database!";
                    label = "";
                  });
                } else {
                  messageText = "Cannot submit without sms";
                }
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    label = "";
                    messageText = "Waiting for SMS...";
                  });
                });
              },
              child: const Text("Submit"))
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
                    buttonnames
                        .add(label!); // Use label! to assert it's non-null
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
