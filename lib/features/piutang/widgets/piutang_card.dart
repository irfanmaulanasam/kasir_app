import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';

class PiutangCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onBayar;

  const PiutangCard({
    super.key,
    required this.item,
    required this.onBayar,
  });

  @override
  Widget build(BuildContext context) {
    final id = item['id'] ?? '-';
    final transaksiId = item['transaksi_id'] ?? '-';
    final tanggal = item['tanggal'] ?? 0;
    final nama = item['nama_pelanggan']?.toString() ?? 'Pelanggan';
    final total = item['total'] ?? 0;
    final dibayar = item['dibayar'] ?? 0;
    final sisa = item['sisa'] ?? 0;
    final status = item['status']?.toString() ?? 'BELUM_LUNAS';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        title: Text(nama),
        subtitle: Text(
          'Piutang #$id - Transaksi #$transaksiId\n'
          'Tanggal: $tanggal \n'
          'Status: $status\n'
          'Total: ${CurrencyFormatter.format(total)}\n'
          'Dibayar: ${CurrencyFormatter.format(dibayar)}\n'
          'Sisa: ${CurrencyFormatter.format(sisa)}',
        ),
        isThreeLine: true,
        trailing: status == 'LUNAS'
            ? const Chip(
                label: Text('LUNAS'),
              )
            : ElevatedButton(
                onPressed: onBayar,
                child: const Text('Bayar'),
              ),
      ),
    );
  }
}