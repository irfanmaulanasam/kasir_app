import 'package:flutter/material.dart';
import 'package:kasir_app/features/activity/widgets/activity_item_card.dart';
import 'package:kasir_app/features/activity/widgets/activity_summary_card.dart';

import '../../../../data/local/activity_repo.dart';
import '../../widgets/app_drawer.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final repo = ActivityRepo();

  List<Map<String, dynamic>> activities = [];
  Map<String, dynamic>? summary;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final activityResult = await repo.getTodayActivity();
    final summaryResult = await repo.getTodayCashSummary();

    if (!mounted) return;

    setState(() {
      activities = activityResult;
      summary = summaryResult;
      isLoading = false;
    });
  }

  // String formatTime(dynamic timestamp) {
  //   final value = timestamp as int? ?? 0;
  //   final date = DateTime.fromMillisecondsSinceEpoch(value);

  //   return DateFormat('HH:mm', 'id_ID').format(date);
  // }

  // IconData iconForType(String tipe) {
  //   switch (tipe) {
  //     case 'PENJUALAN':
  //       return Icons.point_of_sale;
  //     case 'PENGELUARAN':
  //       return Icons.money_off;
  //     case 'MASUK':
  //       return Icons.add_box;
  //     case 'KELUAR':
  //       return Icons.indeterminate_check_box;
  //     case 'PEMBAYARAN_PIUTANG':
  //       return Icons.payments;
  //     default:
  //       return Icons.history;
  //   }
  // }

  // String titleForItem(Map<String, dynamic> item) {
  //   final tipe = item['tipe']?.toString() ?? '-';
  //   final nominal = item['nominal'] ?? 0;

  //   switch (tipe) {
  //     case 'PENJUALAN':
  //       return 'Penjualan ${CurrencyFormatter.format(nominal)}';
  //     case 'PENGELUARAN':
  //       return 'Pengeluaran ${CurrencyFormatter.format(nominal)}';
  //     case 'PEMBAYARAN_PIUTANG':
  //       return 'Pembayaran Piutang ${CurrencyFormatter.format(nominal)}';
  //     case 'MASUK':
  //       return 'Stok Masuk $nominal';
  //     case 'KELUAR':
  //       return 'Stok Keluar $nominal';
  //     default:
  //       return tipe;
  //   }
  // }

  // String subtitleForItem(Map<String, dynamic> item) {
  //   final catatan = item['catatan']?.toString() ?? '';

  //   if (catatan.trim().isEmpty) {
  //     return '-';
  //   }

  //   return catatan;
  // }

  // Widget buildActivityItem(Map<String, dynamic> item) {
  //   final tipe = item['tipe']?.toString() ?? '-';

  //   return Card(
  //     margin: const EdgeInsets.symmetric(
  //       horizontal: 12,
  //       vertical: 6,
  //     ),
  //     child: ListTile(
  //       leading: CircleAvatar(
  //         child: Icon(
  //           iconForType(tipe),
  //           size: 20,
  //         ),
  //       ),
  //       title: Text(
  //         titleForItem(item),
  //       ),
  //       subtitle: Text(
  //         subtitleForItem(item),
  //       ),
  //       trailing: Text(
  //         formatTime(item['tanggal']),
  //         style: const TextStyle(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(
        currentPage: 'Aktivitas',
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : activities.isEmpty
                ? const Center(
                    child: Text('Belum ada aktivitas hari ini'),
                  )
                : ListView.builder(
                    itemCount: activities.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return 
                          ActivitySummaryCard(
                          summary: summary,
                        );
                      }

                      return 
                        ActivityItemsCard(
                          item: activities[index-1],
                        );
                    },
                  ),
      ),
    );
  }
}