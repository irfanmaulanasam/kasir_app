import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_app/features/supplier/widgets/pay_supplier_debt_dialog.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/info_row.dart';
import '../../../data/local/supplier_debt_repo.dart';

class SupplierDetailPage extends StatefulWidget {
  final int supplierId;

  const SupplierDetailPage({
    super.key,
    required this.supplierId,
  });

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

List<Map<String, dynamic>> paymentList = [];

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  final repo = SupplierDebtRepo();

  Map<String, dynamic>? detail;
  List<Map<String, dynamic>> debtList = [];

  bool isLoading = true;
  bool isPaying = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final detailResult = await repo.getSupplierDebtDetail(widget.supplierId);
    final listResult = await repo.getSupplierDebtList(widget.supplierId);
    final paymentResult = await repo.getSupplierPaymentList(widget.supplierId);
    await repo.debugSupplierDebt();
    if (!mounted) return;

    setState(() {
      detail = detailResult;
      debtList = listResult;
      paymentList = paymentResult;
      isLoading = false;
    });
  }

  Future<void> showPayDialog() async {
    final sisa = detail?['sisa_hutang'] as int? ?? 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaySupplierDebtDialog(
        supplierId: widget.supplierId,
        sisaHutang: sisa,
      ),
    );

    if (result != true) return;

    await loadData();

    if (!mounted) return;

    AppDialog.success(
      context,
      message: 'Pembayaran hutang supplier berhasil',
    );
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || detail == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final nama = detail!['nama']?.toString() ?? 'Supplier';
    final noHp = detail!['no_hp']?.toString() ?? '';
    final totalHutang = detail!['total_hutang'] as int? ?? 0;
    final totalBayar = detail!['total_bayar'] as int? ?? 0;
    final sisaHutang = detail!['sisa_hutang'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(nama),
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (noHp.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(noHp),
                    ],
                    const Divider(height: 28),
                    InfoRow(
                      label: 'Total Hutang',
                      value: CurrencyFormatter.format(totalHutang),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Total Dibayar',
                      value: CurrencyFormatter.format(totalBayar),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Sisa Hutang',
                      value: CurrencyFormatter.format(sisaHutang),
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: sisaHutang <= 0 || isPaying
                            ? null
                            : showPayDialog,
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Bayar Hutang Supplier'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daftar Hutang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (debtList.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Belum ada hutang'),
                  ),
                ),
              )
            else
              ...debtList.map((item) {
                final total = item['total'] as int? ?? 0;
                final dibayar = item['dibayar'] as int? ?? 0;
                final sisa = item['sisa'] as int? ?? 0;
                final status = item['status']?.toString() ?? '-';
                final tanggal = item['tanggal'] as int? ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      formatDate(tanggal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: $status'),
                        Text('Total: ${CurrencyFormatter.format(total)}'),
                        Text('Dibayar: ${CurrencyFormatter.format(dibayar)}'),
                        Text('Sisa: ${CurrencyFormatter.format(sisa)}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Text(
                'Riwayat Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (paymentList.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Belum ada pembayaran'),
                    ),
                  ),
                )
              else
                ...paymentList.map((item) {
                  final nominal = item['nominal'] as int? ?? 0;
                  final catatan = item['catatan']?.toString() ?? '-';
                  final tanggal = item['tanggal'] as int? ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(
                        CurrencyFormatter.format(nominal),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(catatan),
                      trailing: Text(
                        formatDate(tanggal),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}