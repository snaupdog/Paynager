import 'package:flutter/material.dart';

class LabelSelector extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final Function(String) onSelected;

  const LabelSelector({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: labels.map((label) {
        return ChoiceChip(
          label: Text(label),
          selected: selected == label,
          onSelected: (_) => onSelected(label),
        );
      }).toList(),
    );
  }
}

