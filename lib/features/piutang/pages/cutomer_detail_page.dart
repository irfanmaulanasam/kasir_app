import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/info_row.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/widgets/currency_text_field.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/local/piutang_repo.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({
    super.key,
    required this.customerId,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final repo = PiutangRepo();

  Map<String, dynamic>? detail;
  List<Map<String, dynamic>> piutangList = [];
  bool isLoading = true;
  bool isPaying = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> showBayarCustomerDialog() async {
    if (isPaying) return;
    
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bayar Hutang'),
          content: CurrencyTextField(
            controller: controller,
            label: 'Nominal Bayar',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nominal = int.tryParse(
                  controller.text.replaceAll('.', '').trim(),
                ) ?? 0;

                final sisa = detail?['sisa_hutang'] as int? ?? 0;

                if (nominal <= 0) {
                  await AppDialog.error(
                    dialogContext,
                    message: 'Nominal harus lebih dari 0',
                  );
                  return;
                }

                if (nominal > sisa) {
                  await AppDialog.error(
                    dialogContext,
                    message: 'Nominal bayar melebihi sisa hutang',
                  );
                  return;
                }

                setState(() {
                  isPaying = true;
                });

                try {
                  await repo.bayarCustomerPiutang(
                    customerId: widget.customerId,
                    nominal: nominal,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);

                  if (!mounted) return;
                  await loadData();
                  
                  if (!mounted) return;
                  await AppDialog.info(
                    context,
                    message: 'Pembayaran hutang berhasil',
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await AppDialog.error(
                    dialogContext,
                    message: 'Gagal membayar hutang: $e',
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      isPaying = false;
                    });
                  }
                }
              },
              child: isPaying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final detailResult = await repo.getCustomerDebtDetail(widget.customerId);
      final listResult = await repo.getCustomerPiutangList(widget.customerId);

      if (!mounted) return;

      setState(() {
        detail = detailResult;
        piutangList = listResult;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      await AppDialog.error(
        context,
        message: 'Gagal memuat data: $e',
      );
      
      if (!mounted) return;
      Navigator.pop(context);
    }
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

    final nama = detail!['nama']?.toString() ?? 'Pelanggan';
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
          padding: const EdgeInsets.all(16),
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
                        onPressed: (sisaHutang <= 0 || isPaying) 
                            ? null 
                            : showBayarCustomerDialog,
                        icon: isPaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.payments_outlined),
                        label: isPaying 
                            ? const Text('Memproses...')
                            : const Text('Bayar Hutang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Daftar Bon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (piutangList.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Belum ada bon'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...piutangList.map((item) {
                final total = item['total'] as int? ?? 0;
                final dibayar = item['dibayar'] as int? ?? 0;
                final sisa = item['sisa'] as int? ?? 0;
                final status = item['status']?.toString() ?? '-';
                final tanggal = item['tanggal'] as int? ?? 0;
                final date = DateTime.fromMillisecondsSinceEpoch(tanggal);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      DateFormat('dd MMM yyyy • HH:mm').format(date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${date.toString().split(' ')[0]}'),
                        const SizedBox(height: 4),
                        _getStatusBadge(status),
                        Text('Total: ${CurrencyFormatter.format(total)}'),
                        Text('Dibayar: ${CurrencyFormatter.format(dibayar)}'),
                        Text('Sisa: ${CurrencyFormatter.format(sisa)}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    final isLunas = status.toUpperCase() == 'LUNAS';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isLunas ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}