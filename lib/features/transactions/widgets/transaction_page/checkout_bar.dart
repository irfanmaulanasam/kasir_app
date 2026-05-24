import 'package:flutter/material.dart';

class CheckoutBar extends StatelessWidget {
  final int total;
  final bool isCartEmpty;
  final String Function(int value) formatRupiah;
  final VoidCallback onCheckout;

  const CheckoutBar({
    super.key,
    required this.total,
    required this.isCartEmpty,
    required this.formatRupiah,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 14),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total: ${formatRupiah(total)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isCartEmpty ? null : onCheckout,
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }
}