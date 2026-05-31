import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/widgets/currency_text_field.dart';
import '../../../data/local/piutang_repo.dart';

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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> showBayarCustomerDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
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
                    ) ??
                    0;

                final sisa = detail?['sisa_hutang'] as int? ?? 0;

                if (nominal <= 0) {
                  return;
                }

                if (nominal > sisa) {
                  return;
                }

                await repo.bayarCustomerPiutang(
                  customerId: widget.customerId,
                  nominal: nominal,
                );

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!mounted) return;
                await loadData();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData() async {
    final detailResult = await repo.getCustomerDebtDetail(widget.customerId);
    final listResult = await repo.getCustomerPiutangList(widget.customerId);

    if (!mounted) return;

    setState(() {
      detail = detailResult;
      piutangList = listResult;
      isLoading = false;
    });
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
    final totalHutang = detail!['total_hutang'] ?? 0;
    final totalBayar = detail!['total_bayar'] ?? 0;
    final sisaHutang = detail!['sisa_hutang'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(nama),
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
                    _InfoRow(
                      label: 'Total Hutang',
                      value: CurrencyFormatter.format(totalHutang),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Total Dibayar',
                      value: CurrencyFormatter.format(totalBayar),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Sisa Hutang',
                      value: CurrencyFormatter.format(sisaHutang),
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: sisaHutang <= 0
                            ? null
                            : () {
                                showBayarCustomerDialog();
                              },
                        icon: const Icon(Icons.payments_outlined),
                        label: const Text('Bayar Hutang'),
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
                child: ListTile(
                  title: Text('Belum ada bon'),
                ),
              )
            else
              ...piutangList.map((item) {
                final total = item['total'] ?? 0;
                final dibayar = item['dibayar'] ?? 0;
                final sisa = item['sisa'] ?? 0;
                final status = item['status']?.toString() ?? '-';

                return Card(
                  child: ListTile(
                    title: Text(
                      'Bon #${item['id']}',
                    ),
                    subtitle: Text(
                      'Status: $status\n'
                      'Total: ${CurrencyFormatter.format(total)}\n'
                      'Dibayar: ${CurrencyFormatter.format(dibayar)}\n'
                      'Sisa: ${CurrencyFormatter.format(sisa)}',
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
        Text(value, style: style),
      ],
    );
  }
}