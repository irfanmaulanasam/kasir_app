import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/currency_text_field.dart';

import '../../../data/local/piutang_repo.dart';
import '../../widgets/app_drawer.dart';
import '../widgets/piutang_card.dart';

class PiutangPage extends StatefulWidget {
  const PiutangPage({super.key});

  @override
  State<PiutangPage> createState() => _PiutangPageState();
}

class _PiutangPageState extends State<PiutangPage> {
  final PiutangRepo repo = PiutangRepo();

  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await repo.getPiutangWithCustomer();

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nominal harus lebih dari 0'),
                    ),
                  );
                  return;
                }
                if (nominal > sisa) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Nominal bayar melebihi sisa hutang'),
                    ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran piutang berhasil'),
                  ),
                );
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
                      return PiutangCard(
                        item: data[index],
                        onBayar: () {
                          showBayarDialog(data[index]);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}