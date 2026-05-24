import 'package:flutter/material.dart';

import '../../../core/widgets/currency_text_field.dart';

class QuickAddProductResult {
  final String nama;
  final int harga;
  final int stok;

  const QuickAddProductResult({
    required this.nama,
    required this.harga,
    required this.stok,
  });
}

class QuickAddProductDialog extends StatefulWidget {
  final String initialName;

  const QuickAddProductDialog({
    super.key,
    required this.initialName,
  });

  @override
  State<QuickAddProductDialog> createState() => _QuickAddProductDialogState();
}

class _QuickAddProductDialogState extends State<QuickAddProductDialog> {
  late final TextEditingController namaController;
  final hargaController = TextEditingController();
  final stokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(
      text: widget.initialName.trim(),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    super.dispose();
  }

  int parseCurrency(String value) {
    return int.tryParse(
          value.replaceAll('.', '').trim(),
        ) ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Produk Baru'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
              ),
            ),
            const SizedBox(height: 12),
            CurrencyTextField(
              controller: hargaController,
              label: 'Harga Jual',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok Awal',
              ),
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
            final nama = namaController.text.trim();
            final harga = parseCurrency(hargaController.text);
            final stok = int.tryParse(stokController.text.trim()) ?? 0;

            if (nama.isEmpty || harga <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nama dan harga wajib diisi'),
                ),
              );
              return;
            }

            Navigator.pop(
              context,
              QuickAddProductResult(
                nama: nama,
                harga: harga,
                stok: stok,
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}