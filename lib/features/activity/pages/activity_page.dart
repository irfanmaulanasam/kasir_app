import 'package:flutter/material.dart';
import 'package:kasir_app/features/activity/widgets/activity_filter_bar.dart';
import 'package:kasir_app/features/activity/widgets/activity_item_card.dart';
import 'package:kasir_app/features/activity/widgets/activity_range_bar.dart';
import 'package:kasir_app/features/activity/widgets/activity_summary_card.dart';
import 'package:kasir_app/features/pengeluaran/pages/pengeluaran_detail_page.dart';
import 'package:kasir_app/features/product/stock_log_detail_page.dart';
import 'package:kasir_app/features/supplier/pages/supplier_detail_page.dart';
import '../../../../data/local/activity_repo.dart';
import '../../piutang/pages/cutomer_detail_page.dart';
import '../../transactions/pages/detail_transaction_page.dart';
import '../../widgets/app_drawer.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final repo = ActivityRepo();

  String selectedFilter = 'SEMUA';
  bool isLoading = true;

  List<Map<String, dynamic>> activities = [];
  Map<String, dynamic>? summary;

  DateTime selectedStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime selectedEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day + 1,
  );

  List<Map<String, dynamic>> get filteredActivities {
    if (selectedFilter == 'SEMUA') {
      return activities;
    }

    return activities.where((item) {
      return item['tipe'] == selectedFilter;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final start = selectedStart.millisecondsSinceEpoch;
    final end = selectedEnd.millisecondsSinceEpoch;

    final activityResult = await repo.getActivityByRange(
      start: start,
      end: end,
    );

    final summaryResult = await repo.getCashSummaryByRange(
      start: start,
      end: end,
    );

    if (!mounted) return;

    setState(() {
      activities = activityResult;
      summary = summaryResult;
      isLoading = false;
    });
  }

  void setToday() {
    final now = DateTime.now();

    setState(() {
      selectedStart = DateTime(now.year, now.month, now.day);
      selectedEnd = DateTime(now.year, now.month, now.day + 1);
      isLoading = true;
    });

    loadData();
  }

  void setLast7Days() {
    final now = DateTime.now();

    setState(() {
      selectedStart = DateTime(now.year, now.month, now.day - 6);
      selectedEnd = DateTime(now.year, now.month, now.day + 1);
      isLoading = true;
    });

    loadData();
  }

  void setLast30Days() {
    final now = DateTime.now();

    setState(() {
      selectedStart = DateTime(now.year, now.month, now.day - 29);
      selectedEnd = DateTime(now.year, now.month, now.day + 1);
      isLoading = true;
    });

    loadData();
  }

  void openActivityDetail(Map<String, dynamic> item) {
    final tipe = item['tipe']?.toString() ?? '';
    final referenceId = item['reference_id'];

    if (referenceId == null) return;

    if (tipe == 'PENJUALAN') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailTransaksiPage(
            transaksiId: referenceId as int,
          ),
        ),
      );
      return;
    }

    if (tipe == 'PEMBAYARAN_PIUTANG') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerDetailPage(
            customerId: referenceId as int,
          ),
        ),
      );
    }
    if (tipe == 'MASUK' || tipe == 'KELUAR' || tipe == 'ADJUSTMENT') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StockLogDetailPage(
            stockLogId: referenceId as int,
          ),
        ),
      );
      return;
    }
    if (tipe == 'PENGELUARAN') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PengeluaranDetailPage(
            pengeluaranId: referenceId as int,
          ),
        ),
      );
      return;
    }
    if (tipe == 'PEMBAYARAN_HUTANG_SUPPLIER') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SupplierDetailPage(
            supplierId: referenceId as int,
          ),
        ),
      );
      return;
    }
  }

  Widget buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(
        itemCount: filteredActivities.isEmpty
            ? 4
            : filteredActivities.length + 3,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ActivitySummaryCard(
              summary: summary,
            );
          }

          if (index == 1) {
            return ActivityRangeBar(
              onToday: setToday,
              onLast7Days: setLast7Days,
              onLast30Days: setLast30Days,
            );
          }

          if (index == 2) {
            return ActivityFilterBar(
              selectedFilter: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            );
          }

          if (filteredActivities.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Belum ada aktivitas pada periode ini'),
              ),
            );
          }

          final item = filteredActivities[index - 3];

          return ActivityItemCard(
            item: item,
            onTap: () {
              openActivityDetail(item);
            },
          );
        },
      ),
    );
  }

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
        child: buildContent(),
      ),
    );
  }
}