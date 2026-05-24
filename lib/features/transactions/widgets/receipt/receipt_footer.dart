import 'package:flutter/material.dart';

class ReceiptFooter extends StatelessWidget {
  final Map<String, dynamic>? settings;

  const ReceiptFooter({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        settings?['footer'] ?? 'Terima kasih',
        textAlign: TextAlign.center,
      ),
    );
  }
}