import 'package:flutter/material.dart';
import '../../../../core/widgets/currency_text_field.dart';

class PaymentResult {
  final int total;
  final int bayar;
  final int kembalian;
  final String metodeBayar;
  final String? namaPelanggan;
  final String? catatan;

  const PaymentResult({
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.metodeBayar,
    this.namaPelanggan,
    this.catatan,
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
  final namaPelangganController = TextEditingController();
  final catatanController = TextEditingController();

  String metodeBayar = 'Cash';
  bool get isAutoPaid {
    return metodeBayar == 'QRIS' || metodeBayar == 'Transfer';
  }

  @override
  void dispose() {
    bayarController.dispose();
    namaPelangganController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  int get bayar {
    if(isAutoPaid) return widget.total;
    return int.tryParse(
          bayarController.text.replaceAll('.', '').trim(),
        ) ??
        0;
  }

  int get kembalian {
    final result = bayar - widget.total;
    return result < 0 ? 0 : result;
  }

  bool get isTempo {
    return metodeBayar == 'Tempo';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pembayaran'),
      content: SingleChildScrollView(
        child: Column(
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
              items: ['Cash', 'QRIS', 'Transfer', 'Tempo']
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
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            if(!isAutoPaid) ...[
              CurrencyTextField(
                controller: bayarController,
                label: isTempo ? 'Dibayar Sekarang' : 'Uang Diterima',
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ],

            if (isTempo) ...[
              const SizedBox(height: 16),
              TextField(
                controller: namaPelangganController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isTempo ? 'Sisa Hutang' : 'Kembalian'),
                Text(
                  widget.formatRupiah(
                    isTempo
                        ? (widget.total - bayar < 0 ? 0 : widget.total - bayar)
                        : (kembalian < 0 ? 0 : kembalian),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          final isPaidMethod = !isTempo;

          if (isPaidMethod && bayar < widget.total) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pembayaran belum cukup'),
              ),
            );
            return;
          }

          if (isTempo && namaPelangganController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nama pelanggan wajib diisi untuk tempo'),
              ),
            );
            return;
          }
          if (isTempo && bayar > widget.total) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dibayar sekarang tidak boleh melebihi total belanja'),
              ),
            );
            return;
          }

          Navigator.pop(
            context,
            PaymentResult(
              total: widget.total,
              bayar: bayar,
              kembalian: isTempo ? 0 : kembalian,
              metodeBayar: metodeBayar,
              namaPelanggan: namaPelangganController.text.trim(),
              catatan: catatanController.text.trim(),
            ),
          );
        },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}