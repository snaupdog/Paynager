// ignore_for_file: avoid_print
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

  final TextEditingController noteController = TextEditingController();

  String messageText = "Waiting for SMS...";
  String label = "";
  String? amount = "";
  String? recipient = "";
  String? date = "";
  String? refNumber = "";

  final List<String> buttonnames = [
    "Snacks",
    "Swiggy",
    "Stationary",
    "Grocery",
    "People",
    "Travel"
  ];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestPermissions();
    _startListeningForSms();
  }

  // ---------------- NOTIFICATIONS ----------------

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'sms_channel',
      'SMS Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  // ---------------- PERMISSIONS ----------------

  Future<void> _requestPermissions() async {
    await Permission.sms.request();
    await Permission.notification.request();
  }

  // ---------------- SMS ----------------

  void extractinfo(String msg) {
    final amountReg =
        RegExp(r'rs\.?\s?(\d+(\.\d{1,2})?)', caseSensitive: false);
    final recipientReg = RegExp(r'to ([a-zA-Z ]+)');
    final dateReg = RegExp(r'on (\d{2}-\d{2}(?:-\d{4})?)');
    final refNumberReg = RegExp(r'ref (\d+)');

    amount = amountReg.firstMatch(msg)?.group(1);
    recipient = recipientReg.firstMatch(msg)?.group(1);
    date = dateReg.firstMatch(msg)?.group(1);
    refNumber = refNumberReg.firstMatch(msg)?.group(1);

    print('Amount: Rs.$amount');
    print('Recipient: $recipient');
    print('Date: $date');
    print('Ref: $refNumber');
  }

  void _startListeningForSms() {
    easySmsReceiver.listenIncomingSms(
      onNewMessage: (message) async {
        final messageBody = message.body ?? "";

        if (messageBody.toLowerCase().contains("hdfc")) {
          setState(() => messageText = messageBody);

          extractinfo(messageBody);

          await _showNotification("Label transaction", messageBody);
        }
      },
    );
  }

  // ---------------- FIRESTORE ----------------

  Future<void> _addtodatabase() async {
    final transaction = <String, dynamic>{
      "message": messageText,
      "label": label,
      "amount": amount,
      "recipient": recipient,
      "date": date,
      "refNumber": refNumber,
      "note": noteController.text.isNotEmpty ? noteController.text : null,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await firestore.collection("transaction").add(transaction);
      print('Saved to Firestore');
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SMS Transaction Logger")),
      floatingActionButton: FloatingActionButton(
        child: const Text("Add"),
        onPressed: () => addLabelDialog(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              messageText,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onLongPress: () => _showDeleteDialog(index),
                    onPressed: () => setState(() => label = buttonnames[index]),
                    child: Text(buttonnames[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: "Add Note",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (messageText != "Waiting for SMS...") {
                await _addtodatabase();
                setState(() {
                  messageText = "Saved!";
                  label = "";
                });
                noteController.clear();
              }
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "${buttonnames[index]}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                setState(() => buttonnames.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text('Delete')),
        ],
      ),
    );
  }

  Future<String?> addLabelDialog() async {
    String? label;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Label'),
        content: TextField(
          onChanged: (v) => label = v,
          decoration: const InputDecoration(hintText: "Label"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (label != null && label!.isNotEmpty) {
                setState(() => buttonnames.add(label!));
              }
              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
