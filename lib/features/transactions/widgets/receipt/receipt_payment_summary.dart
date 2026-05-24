import 'package:flutter/material.dart';

class ReceiptPaymentSummary extends StatelessWidget {
  final Map<String, dynamic> transaksi;
  final String Function(int value) rupiah;

  const ReceiptPaymentSummary({
    super.key,
    required this.transaksi,
    required this.rupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOTAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              rupiah(transaksi['total'] ?? 0),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SummaryRow(
          label: 'Metode',
          value: transaksi['metode_bayar']?.toString() ?? '-',
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          label: 'Bayar',
          value: rupiah(transaksi['bayar'] ?? 0),
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          label: 'Kembalian',
          value: rupiah(transaksi['kembalian'] ?? 0),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}