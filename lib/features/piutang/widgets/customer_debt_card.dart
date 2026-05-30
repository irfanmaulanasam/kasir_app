import 'package:flutter/material.dart';

class CustomerDebtCard extends StatelessWidget {
  final Map<String, dynamic> customer;
  final String Function(int) rupiah;
  final VoidCallback onTap;

  const CustomerDebtCard({
    super.key,
    required this.customer,
    required this.rupiah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          customer['nama'] ?? '-',
        ),
        subtitle: Text(
          'Bon: ${customer['jumlah_bon']}',
        ),
        trailing: Text(
          rupiah(
            customer['sisa_hutang'] ?? 0,
          ),
        ),
      ),
    );
  }
}