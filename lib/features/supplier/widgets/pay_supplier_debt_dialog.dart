import 'package:flutter/material.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/currency_text_field.dart';
import '../../../data/local/supplier_debt_repo.dart';

class PaySupplierDebtDialog extends StatefulWidget {
  final int supplierId;
  final int sisaHutang;

  const PaySupplierDebtDialog({
    super.key,
    required this.supplierId,
    required this.sisaHutang,
  });

  @override
  State<PaySupplierDebtDialog> createState() => _PaySupplierDebtDialogState();
}

class _PaySupplierDebtDialogState extends State<PaySupplierDebtDialog> {
  final repo = SupplierDebtRepo();
  final controller = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '').trim()) ?? 0;
  }

  Future<void> save() async {
    final nominal = parseCurrency(controller.text);

    if (nominal <= 0) {
      await AppDialog.error(
        context,
        message: 'Nominal harus lebih dari 0',
      );
      return;
    }

    if (nominal > widget.sisaHutang) {
      await AppDialog.error(
        context,
        message: 'Nominal melebihi sisa hutang supplier',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await repo.paySupplierDebt(
        supplierId: widget.supplierId,
        nominal: nominal,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      await AppDialog.error(
        context,
        message: 'Gagal membayar hutang supplier: $e',
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
      title: const Text('Bayar Hutang Supplier'),
      content: CurrencyTextField(
        controller: controller,
        label: 'Nominal Bayar',
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