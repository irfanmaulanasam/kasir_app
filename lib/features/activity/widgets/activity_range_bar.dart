import 'package:flutter/material.dart';

class ActivityRangeBar extends StatelessWidget {
  final VoidCallback onToday;
  final VoidCallback onLast7Days;
  final VoidCallback onLast30Days;
  const ActivityRangeBar({
    super.key,
    required this.onToday,
    required this.onLast7Days,
    required this.onLast30Days
  });

@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          ElevatedButton(
            onPressed: onToday,
            child: const Text('Hari Ini'),
          ),
          ElevatedButton(
            onPressed: onLast7Days,
            child: const Text('7 Hari'),
          ),
          ElevatedButton(
            onPressed: onLast30Days,
            child: const Text('30 Hari'),
          ),
        ],
      ),
    );
  }
}