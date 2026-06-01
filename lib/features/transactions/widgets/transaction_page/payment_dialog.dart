import 'package:flutter/material.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/currency_text_field.dart';
import '../../../../data/local/customer_repo.dart';
import '../../../../data/models/customer.dart';
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
  final customerRepo = CustomerRepo();
  List<Customer> customers = [];

  String metodeBayar = 'Cash';
  bool get isAutoPaid {
    return metodeBayar == 'QRIS' || metodeBayar == 'Transfer';
  }

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final result = await customerRepo.getAll();

    if (!mounted) return;

    setState(() {
      customers = result;
    });
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
              Autocomplete<Customer>(
                displayStringForOption: (customer) => customer.nama,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final query = textEditingValue.text.toLowerCase();

                  if (query.isEmpty) {
                    return const Iterable<Customer>.empty();
                  }

                  return customers.where((customer) {
                    return customer.nama.toLowerCase().contains(query);
                  });
                },
                onSelected: (Customer customer) {
                  namaPelangganController.text = customer.nama;
                },
                fieldViewBuilder: (
                  context,
                  textEditingController,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  textEditingController.text = namaPelangganController.text;

                  textEditingController.addListener(() {
                    namaPelangganController.text = textEditingController.text;
                  });

                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
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
          
        onPressed: () async {
          final isPaidMethod = !isTempo;

          if (isPaidMethod && bayar < widget.total) {
            await AppDialog.error(
              context,
              message: 'Pembayaran belum cukup. Gunakan Tempo jika belum lunas.',
            );
            return;
          }

          if (isTempo && bayar > widget.total) {
            await AppDialog.error(
              context,
              message: 'Pembayaran tempo tidak boleh melebihi total belanja.',
            );
            return;
          }

          if (isTempo && namaPelangganController.text.trim().isEmpty) {
            await AppDialog.error(
              context,
              message: 'Nama pelanggan wajib diisi untuk transaksi tempo.',
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