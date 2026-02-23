import 'package:flutter/material.dart';

class NoteInput extends StatelessWidget {
  final TextEditingController controller;

  const NoteInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: "Add note...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

