import 'package:flutter/material.dart';

import '../../../services/pdf_services.dart';
import '../widgets/receipt/receipt_footer.dart';
import '../widgets/receipt/receipt_header.dart';
import '../widgets/receipt/receipt_item_list.dart';
import '../widgets/receipt/receipt_payment_summary.dart';

class ReceiptPreviewPage extends StatelessWidget {
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
                ReceiptHeader(
                  settings: settings,
                  timestamp: transaksi['tanggal'],
                ),
                const Divider(height: 30),
                ReceiptItemList(
                  items: items,
                  rupiah: rupiah,
                ),
                const Divider(height: 30),
                ReceiptPaymentSummary(
                  transaksi: transaksi,
                  rupiah: rupiah,
                ),
                const SizedBox(height: 30),
                ReceiptFooter(
                  settings: settings,
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