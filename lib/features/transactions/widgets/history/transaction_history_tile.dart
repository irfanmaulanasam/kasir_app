import 'package:flutter/material.dart';

import '../../../../core/formatters/currency_formatter.dart';
import '../../../../core/formatters/date_formatter.dart';

class TransactionHistoryTile extends StatelessWidget {
  final Map<String, dynamic> transaksi;
  final VoidCallback onTap;

  const TransactionHistoryTile({
    super.key,
    required this.transaksi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final id = transaksi['id'] as int? ?? 0;
    final total = transaksi['total'] ?? 0;
    final tanggal = transaksi['tanggal'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(id.toString()),
        ),
        title: Text(
          CurrencyFormatter.format(total),
        ),
        subtitle: Text(
          DateFormatter.transactionDate(tanggal),
        ),
      ),
    );
  }
}