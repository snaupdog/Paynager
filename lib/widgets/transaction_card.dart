import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String message;
  final String? amount;

  const TransactionCard({
    super.key,
    required this.message,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Latest Transaction",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(message),
            if (amount != null && amount!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "₹$amount",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]
          ],
        ),
      ),
    );
  }
}

