import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/info_row.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../data/local/pengeluaran_repo.dart';

class PengeluaranDetailPage extends StatefulWidget {
  final int pengeluaranId;

  const PengeluaranDetailPage({
    super.key,
    required this.pengeluaranId,
  });

  @override
  State<PengeluaranDetailPage> createState() => _PengeluaranDetailPageState();
}

class _PengeluaranDetailPageState extends State<PengeluaranDetailPage> {
  final repo = PengeluaranRepo();

  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await repo.getById(widget.pengeluaranId);

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
        body: Center(child: Text('Data pengeluaran tidak ditemukan')),
      );
    }

    final kategori = data!['kategori']?.toString() ?? '-';
    final nominal = data!['nominal'] as int? ?? 0;
    final catatan = data!['catatan']?.toString() ?? '-';
    final tanggal = data!['tanggal'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengeluaran'),
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
                      kategori,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Tanggal',
                      value: formatDate(tanggal),
                    ),
                    const Divider(height: 28),
                    InfoRow(
                      label: 'Nominal',
                      value: CurrencyFormatter.format(nominal),
                      bold: true,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
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