import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/currency_text_field.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/local/piutang_repo.dart';
import '../../widgets/app_drawer.dart';
import '../widgets/customer_debt_card.dart';
import '../pages/cutomer_detail_page.dart';

class PiutangPage extends StatefulWidget {
  const PiutangPage({super.key});

  @override
  State<PiutangPage> createState() => _PiutangPageState();
}

class _PiutangPageState extends State<PiutangPage> {
  final PiutangRepo repo = PiutangRepo();
  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await repo.getCustomerSummary();

    if (!mounted) return;

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  Future<void> showBayarDialog(Map<String, dynamic> item) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bayar Piutang'),
          content: CurrencyTextField(
            controller: controller,
            label: 'Nominal Bayar'
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
                final nominal =
                  int.tryParse(
                    controller.text
                        .replaceAll('.', '')
                        .trim(),
                  ) ?? 0;
                  
                final sisa = item['sisa'] as int? ?? 0;
                
                if (nominal <= 0) {
                  await AppDialog.error(
                    context,
                    message: 'Nominal harus lebih dari 0',
                  );
                  return;
                }
                if (nominal > sisa) {
                  await AppDialog.error(
                    context,
                    message: 'Nominal bayar melebihi sisa hutang',
                  );
                  return;
                }

                await repo.bayarPiutang(
                  id: item['id'] as int,
                  nominal: nominal,
                );

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!mounted) return;
                await loadData();

                if (!mounted) return;
                await AppDialog.error(
                  context,
                  message: 'Pembayaran piutang berhasil',
                );
                return;
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piutang'),
         actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: 'Piutang',
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : data.isEmpty
                ? const Center(
                    child: Text('Belum ada piutang'),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return CustomerDebtCard(
                        customer: data[index],
                        rupiah: formatRupiah,
                        onTap: () {
                         final customerId = data[index]['customer_id'];

                          if (customerId == null) {
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailPage(
                                customerId: customerId as int,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}