import 'package:flutter/material.dart';

class ActivityFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const ActivityFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  static const filters = [
    'SEMUA',
    'PENJUALAN',
    'PENGELUARAN',
    'PEMBAYARAN_PIUTANG',
    'STOK MASUK',
    'STOK KELUAR',
    'PEMBAYARAN HUTANG SUPPLIER'
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selectedFilter == filter,
              onSelected: (_) {
                onChanged(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}