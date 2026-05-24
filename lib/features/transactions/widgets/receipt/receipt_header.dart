import 'package:flutter/material.dart';

import '../../../../../core/formatters/date_formatter.dart';

class ReceiptHeader extends StatelessWidget {
  final Map<String, dynamic>? settings;
  final int timestamp;

  const ReceiptHeader({
    super.key,
    required this.settings,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          settings?['nama_toko'] ?? 'TOKO',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          settings?['alamat'] ?? '',
          textAlign: TextAlign.center,
        ),
        Text(
          settings?['telepon'] ?? '',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          DateFormatter.receiptDate(timestamp),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}