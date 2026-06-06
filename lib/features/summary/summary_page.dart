import 'package:flutter/material.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';
import '../../../data/local/summary_repo.dart';
import '../widgets/app_drawer.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {

  final repo = SummaryRepo();

  Map<String, dynamic>? today;
  Map<String, dynamic>? month;
  Map<String, dynamic>? piutang;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    today = await repo.getTodaySummary();
    month = await repo.getMonthSummary();
    piutang = await repo.getPiutangSummary();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    if (today == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: 'Summary',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            child: ListTile(
              title: const Text('Hari Ini'),
              subtitle: Text(
                'Transaksi: ${today!['transaksi']}',
              ),
              trailing: Text(
                CurrencyFormatter.format(today!['omzet']),
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text('Bulan Ini'),
              subtitle: Text(
                'Transaksi: ${month!['transaksi']}',
              ),
              trailing: Text(
                CurrencyFormatter.format(month!['omzet']),
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text('Piutang'),
              subtitle: Text(
                'Belum Lunas: ${piutang!['jumlah']}',
              ),
              trailing: Text(
                CurrencyFormatter.format(piutang!['total']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}