import 'package:flutter/material.dart';

import '../../../../core/widgets/currency_text_field.dart';

class PaymentResult {
  final int total;
  final int bayar;
  final int kembalian;
  final String metodeBayar;

  const PaymentResult({
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.metodeBayar,
  });
}

class PaymentDialog extends StatefulWidget {
  final int total;
  final String Function(int value) formatRupiah;

  const PaymentDialog({
    super.key,
    required this.total,
    required this.formatRupiah,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final bayarController = TextEditingController();
  String metodeBayar = 'Cash';

  @override
  void dispose() {
    bayarController.dispose();
    super.dispose();
  }

  int get bayar {
    return int.tryParse(
          bayarController.text.replaceAll('.', '').trim(),
        ) ??
        0;
  }

  int get kembalian {
    return bayar - widget.total;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pembayaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text(
                widget.formatRupiah(widget.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: metodeBayar,
            items: ['Cash', 'QRIS', 'Transfer']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                metodeBayar = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Metode Bayar',
            ),
          ),
          const SizedBox(height: 16),
          CurrencyTextField(
            controller: bayarController,
            label: 'Uang Diterima',
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kembalian'),
              Text(
                widget.formatRupiah(
                  kembalian < 0 ? 0 : kembalian,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (metodeBayar == 'Cash' && bayar < widget.total) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Uang kurang'),
                ),
              );
              return;
            }

            Navigator.pop(
              context,
              PaymentResult(
                total: widget.total,
                bayar: bayar,
                kembalian: kembalian,
                metodeBayar: metodeBayar,
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}