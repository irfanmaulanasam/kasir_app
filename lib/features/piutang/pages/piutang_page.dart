import 'package:flutter/material.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';
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
  
  List<Map<String, dynamic>> data = [];
  bool isLoading = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    loadData();
    _debugDb();
  }

  Future<void> _debugDb() async {
    await repo.debugPiutang();
  }

  Future<void> loadData() async {
    // Cegah jika sedang loading atau refreshing
    if (isLoading || isRefreshing) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await repo.getCustomerSummary();
      debugPrint('=====awal debug ====');
      debugPrint(result.toString());
      debugPrint('=====akhir debug====');

      if (!mounted){
        isLoading = false;
        return;
      } 

      setState(() {
        data = result;
        isLoading = false;
        isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) {
        isLoading = false;
        return;
      }

      setState(() {
        isLoading = false;
        isRefreshing = false;
      });

      await AppDialog.error(
        context,
        message: 'Gagal memuat data piutang: $e',
      );
    }
  }

  Future<void> refreshData() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    try {
      final result = await repo.getCustomerSummary();

      if (!mounted) return;

      setState(() {
        data = result;
        isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isRefreshing = false;
      });

      await AppDialog.error(
        context,
        message: 'Gagal refresh data: $e',
      );
    }
  }

  
  Future<void> showBayarDialog(Map<String, dynamic> item) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
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
                final nominal = int.tryParse(
                  controller.text.replaceAll('.', '').trim(),
                ) ?? 0;
                  
                final sisa = item['sisa'] as int? ?? 0;
                
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

                final id = item['id'];
                if (id == null) {
                  await AppDialog.error(
                    dialogContext,
                    message: 'Data piutang tidak valid',
                  );
                  return;
                }

                try {
                  await repo.bayarPiutang(
                    id: id as int,
                    nominal: nominal,
                  );

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);

                  if (!mounted) return;
                  await refreshData();

                  if (!mounted) return;
                  await AppDialog.info(
                    context,
                    message: 'Pembayaran piutang berhasil',
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await AppDialog.error(
                    dialogContext,
                    message: 'Gagal membayar piutang: $e',
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void navigateToCustomerDetail(int customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailPage(
          customerId: customerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piutang'),
        actions: [
          if (isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: refreshData,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: 'Piutang',
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada piutang',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final customer = data[index];
          
          // Validate customer data
          final customerId = customer['customer_id'];
          if (customerId == null || customerId is! int) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.red.shade50,
              child: const ListTile(
                title: Text('Data tidak valid'),
                subtitle: Text('Customer ID tidak ditemukan'),
              ),
            );
          }
          
          return CustomerDebtCard(
            customer: customer,
            rupiah: CurrencyFormatter.format,
            onTap: () => navigateToCustomerDetail(customerId),
          );
        },
      ),
    );
  }
}