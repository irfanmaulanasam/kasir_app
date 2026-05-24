import 'package:flutter/material.dart';

import '../../models/cart_item.dart';

class CartSection extends StatelessWidget {
  final Map<int, CartItem> cart;
  final String Function(int value) formatRupiah;
  final void Function(int productId) onDecrease;

  const CartSection({
    super.key,
    required this.cart,
    required this.formatRupiah,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return const Center(
        child: Text('Cart masih kosong'),
      );
    }

    return ListView(
      children: cart.values.map((item) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: ListTile(
            title: Text(item.nama),
            subtitle: Text(
              '${formatRupiah(item.harga)} x ${item.qty} = ${formatRupiah(item.subtotal)}',
            ),
            trailing: Text(
              'x${item.qty}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => onDecrease(item.id),
          ),
        );
      }).toList(),
    );
  }
}