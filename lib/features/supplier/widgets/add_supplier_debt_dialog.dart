import 'package:flutter/material.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/currency_text_field.dart';
import '../../../data/local/supplier_debt_repo.dart';
import '../../../data/local/supplier_repo.dart';
import '../../../data/models/supplier.dart';

class AddSupplierDebtDialog extends StatefulWidget {
  const AddSupplierDebtDialog({super.key});

  @override
  State<AddSupplierDebtDialog> createState() => _AddSupplierDebtDialogState();
}

class _AddSupplierDebtDialogState extends State<AddSupplierDebtDialog> {
  final supplierRepo = SupplierRepo();
  final debtRepo = SupplierDebtRepo();

  final namaController = TextEditingController();
  final totalController = TextEditingController();
  final dibayarController = TextEditingController();
  final catatanController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    namaController.dispose();
    totalController.dispose();
    dibayarController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '').trim()) ?? 0;
  }

  Future<void> save() async {
    final nama = namaController.text.trim();
    final total = parseCurrency(totalController.text);
    final dibayar = parseCurrency(dibayarController.text);
    final catatan = catatanController.text.trim();

    if (nama.isEmpty) {
      await AppDialog.error(
        context,
        message: 'Nama supplier wajib diisi',
      );
      return;
    }

    if (total <= 0) {
      await AppDialog.error(
        context,
        message: 'Total hutang wajib lebih dari 0',
      );
      return;
    }

    if (dibayar > total) {
      await AppDialog.error(
        context,
        message: 'Dibayar tidak boleh melebihi total hutang',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final existingSupplier = await supplierRepo.findByName(nama);

      final supplierId = existingSupplier?.id ??
          await supplierRepo.insert(
            Supplier(
              nama: nama,
            ),
          );

      await debtRepo.insertDebt(
        supplierId: supplierId,
        total: total,
        dibayar: dibayar,
        catatan: catatan,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      await AppDialog.error(
        context,
        message: 'Gagal menambah hutang supplier: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Hutang Supplier'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Supplier',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CurrencyTextField(
              controller: totalController,
              label: 'Total Hutang',
            ),
            const SizedBox(height: 12),
            CurrencyTextField(
              controller: dibayarController,
              label: 'Sudah Dibayar',
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : save,
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}