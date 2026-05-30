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
    final metodeBayar = transaksi['metode_bayar']?.toString() ?? '-';
    final statusBayar = transaksi['status_bayar']?.toString() ?? 'LUNAS';
    final sisaHutang = transaksi['sisa_hutang'] as int? ?? 0;
    final isTempo = metodeBayar == 'Tempo';

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
              rupiah(transaksi['total'] as int? ?? 0),
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
          value: metodeBayar,
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          label: 'Status',
          value: statusBayar,
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          label: 'Bayar',
          value: rupiah(transaksi['bayar'] as int? ?? 0),
        ),
        const SizedBox(height: 8),
        _SummaryRow(
          label: isTempo ? 'Sisa Hutang' : 'Kembalian',
          value: rupiah(
            isTempo
                ? sisaHutang
                : transaksi['kembalian'] as int? ?? 0,
          ),
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