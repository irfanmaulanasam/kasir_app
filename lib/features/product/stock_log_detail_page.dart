import 'package:flutter/material.dart';

import '../../../data/local/produk_repo.dart';

class StockLogDetailPage extends StatefulWidget {
  final int stockLogId;

  const StockLogDetailPage({
    super.key,
    required this.stockLogId,
  });

  @override
  State<StockLogDetailPage> createState() => _StockLogDetailPageState();
}

class _StockLogDetailPageState extends State<StockLogDetailPage> {
  final repo = ProdukRepo();

  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await repo.getStockLogById(widget.stockLogId);

    if (!mounted) return;

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text('Data stok tidak ditemukan')),
      );
    }

    final namaProduk = data!['nama_produk']?.toString() ?? '-';
    final tipe = data!['tipe']?.toString() ?? '-';
    final qty = data!['qty'] ?? 0;
    final catatan = data!['catatan']?.toString() ?? '-';
    final tanggal = data!['tanggal'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Stok'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaProduk,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _InfoRow(
                      label: 'Tanggal',
                      value: formatDate(tanggal),
                    ),

                    const Divider(height: 28),

                    _InfoRow(
                      label: 'Tipe',
                      value: tipe,
                      bold: true,
                    ),

                    const SizedBox(height: 8),

                    _InfoRow(
                      label: 'Qty',
                      value: qty.toString(),
                      bold: true,
                    ),

                    const SizedBox(height: 8),

                    _InfoRow(
                      label: 'Catatan',
                      value: catatan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
    );
  }
}