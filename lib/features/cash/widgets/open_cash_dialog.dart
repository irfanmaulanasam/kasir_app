import 'package:flutter/material.dart';

import '../../../core/widgets/currency_text_field.dart';

class OpenCashDialog extends StatefulWidget {
  const OpenCashDialog({super.key});

  @override
  State<OpenCashDialog> createState() => _OpenCashDialogState();
}

class _OpenCashDialogState extends State<OpenCashDialog> {
  final kasAwalController = TextEditingController();
  final catatanController = TextEditingController();

  @override
  void dispose() {
    kasAwalController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '').trim()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kas Awal Hari Ini'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyTextField(
            controller: kasAwalController,
            label: 'Kas Awal',
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
      actions: [
        ElevatedButton(
          onPressed: () {
            final kasAwal = parseCurrency(kasAwalController.text);

            Navigator.pop(context, {
              'kas_awal': kasAwal,
              'catatan': catatanController.text.trim(),
            });
          },
          child: const Text('Mulai Toko'),
        ),
      ],
    );
  }
}