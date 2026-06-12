import 'package:flutter/material.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';

class ActivitySummaryCard extends StatelessWidget{
  final Map <String, dynamic >? summary;

  const ActivitySummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Uang Masuk',
              value: CurrencyFormatter.format(summary!['uang_masuk']),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Penjualan tunai',
              value: CurrencyFormatter.format(summary!['penjualan_tunai']),
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Bayar Piutang',
              value: CurrencyFormatter.format(summary!['bayar_piutang']),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Uang Keluar',
              value: CurrencyFormatter.format(summary!['uang_keluar']),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Kas Bersih',
              value: CurrencyFormatter.format(summary!['kas_bersih']),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}