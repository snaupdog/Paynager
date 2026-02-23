import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../widgets/transaction_card.dart';
import '../widgets/label_selector.dart';
import '../widgets/note_input.dart';
import '../widgets/submit_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final sms = SmsService();
  final firestore = FirestoreService();
  final notifications = NotificationService();

  final TextEditingController noteController = TextEditingController();

  String messageText = "Waiting for SMS...";
  String label = "";
  String? amount;

  final List<String> labels = [
    "Snacks",
    "Swiggy",
    "Stationary",
    "Grocery",
    "People",
    "Travel"
  ];

  @override
  void initState() {
    super.initState();
    notifications.init();

    sms.listen((msg) async {
      if (msg.toLowerCase().contains("hdfc")) {
        setState(() => messageText = msg);
        await notifications.show("Label Transaction", msg);
      }
    });
  }

  Future<void> save() async {
    await firestore.saveTransaction({
      "message": messageText,
      "label": label,
      "note": noteController.text,
      "timestamp": DateTime.now(),
    });

    setState(() {
      messageText = "Saved!";
      label = "";
    });

    noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paynager")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TransactionCard(message: messageText, amount: amount),
              const SizedBox(height: 16),
              LabelSelector(
                labels: labels,
                selected: label,
                onSelected: (v) => setState(() => label = v),
              ),
              const SizedBox(height: 16),
              NoteInput(controller: noteController),
              const Spacer(),
              SubmitButton(onPressed: save),
            ],
          ),
        ),
      ),
    );
  }
}

