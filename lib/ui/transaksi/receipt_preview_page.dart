import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pdf_services.dart';

class ReceiptPreviewPage extends StatelessWidget {
  // DISESUAIKAN: Tipe data disamakan dengan PdfService
  final Map<String, dynamic> transaksi;
  final List items;
  final Map<String, dynamic>? settings;

  const ReceiptPreviewPage({
    super.key,
    required this.transaksi,
    required this.items,
    required this.settings,
  });

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  String formatTanggal(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Nota'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    settings?['nama_toko'] ?? 'TOKO',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    settings?['alamat'] ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    settings?['telepon'] ?? '',
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    formatTanggal(transaksi['tanggal']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(height: 30),
                ...items.map((item) {
                  final subtotal = item['qty'] * item['harga'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nama']?.toString() ?? 'produk',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['qty']} x ${rupiah(item['harga'])}',
                            ),
                            Text(
                              rupiah(subtotal),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      rupiah(transaksi['total']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Metode'),
                    Text(
                      transaksi['metode_bayar']?.toString() ?? '-',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bayar'),
                    Text(
                      rupiah(transaksi['bayar'] ?? 0),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian'),
                    Text(
                      rupiah(transaksi['kembalian'] ?? 0),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    settings?['footer'] ?? 'Terima kasih',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () async {
              // Sekarang sudah aman dipanggil karena tipe data parameter sudah sama
              await PdfService.printReceipt(
                transaksi: transaksi,
                items: items,
                settings: settings ?? {}, 
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print PDF'),
          ),
        ),
      ),
    );
  }
}