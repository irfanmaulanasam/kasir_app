import 'package:flutter/material.dart';

class ReceiptItemList extends StatelessWidget {
  final List items;
  final String Function(int value) rupiah;

  const ReceiptItemList({
    super.key,
    required this.items,
    required this.rupiah,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        final qty = item['qty'] as int? ?? 0;
        final harga = item['harga'] as int? ?? 0;
        final subtotal = qty * harga;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama']?.toString() ?? 'produk',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$qty x ${rupiah(harga)}'),
                  Text(rupiah(subtotal)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}