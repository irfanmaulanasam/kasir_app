import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';


class ActivityItemCard extends StatelessWidget{
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const ActivityItemCard({
    super.key,
    required this.item,
    this.onTap
  });

  String formatTime(dynamic timestamp) {
    final value = timestamp as int? ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(value);

    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  IconData iconForType(String tipe) {
    switch (tipe) {
      case 'PENJUALAN':
        return Icons.point_of_sale;
      case 'PENGELUARAN':
        return Icons.money_off;
      case 'MASUK':
        return Icons.add_box;
      case 'KELUAR':
        return Icons.indeterminate_check_box;
      case 'PEMBAYARAN_PIUTANG':
        return Icons.payments;
      case 'PEMBAYARAN_HUTANG_SUPPLIER':
        return Icons.local_shipping_outlined;
      default:
        return Icons.history;
    }
  }

  String titleForItem(Map<String, dynamic> item) {
    final tipe = item['tipe']?.toString() ?? '-';
    final nominal = item['nominal'] ?? 0;

    switch (tipe) {
      case 'PENJUALAN':
        return 'Penjualan ${CurrencyFormatter.format(nominal)}';
      case 'PENGELUARAN':
        return 'Pengeluaran ${CurrencyFormatter.format(nominal)}';
      case 'PEMBAYARAN_PIUTANG':
        return 'Pembayaran Piutang ${CurrencyFormatter.format(nominal)}';
      case 'MASUK':
        return 'Stok Masuk $nominal';
      case 'KELUAR':
        return 'Stok Keluar $nominal';
      case 'PEMBAYARAN_HUTANG_SUPPLIER':
        return 'Bayar Hutang Supplier ${CurrencyFormatter.format(nominal)}';
      default:
        return tipe;
    }
  }

  String subtitleForItem(Map<String, dynamic> item) {
    final catatan = item['catatan']?.toString() ?? '';

    if (catatan.trim().isEmpty) {
      return '-';
    }

    return catatan;
  }
  
    @override
    Widget build(BuildContext context) {
      final tipe = item['tipe']?.toString() ?? '-';
      
      return Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            child: Icon(
              iconForType(tipe),
              size: 20,
            ),
          ),
          title: Text(
            titleForItem(item),
          ),
          subtitle: Text(
            subtitleForItem(item),
          ),
          trailing: Text(
            formatTime(item['tanggal']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }