import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/local/supplier_debt_repo.dart';
import '../../widgets/app_drawer.dart';
import '../widgets/add_supplier_debt_dialog.dart';
import 'supplier_detail_page.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final repo = SupplierDebtRepo();

  List<Map<String, dynamic>> data = [];
  String selectedFilter = 'BELUM_LUNAS';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<Map<String, dynamic>> get filteredData {
    if (selectedFilter == 'SEMUA') {
      return data;
    }

    return data.where((item) {
      final sisa = item['sisa_hutang'] as int? ?? 0;
      return sisa > 0;
    }).toList();
  }

  Future<void> loadData() async {
    final result = await repo.getSupplierSummaryAll();

    if (!mounted) return;

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  Future<void> refreshData() async {
    await loadData();
  }

  Future<void> showTambahHutangDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddSupplierDebtDialog(),
    );

    if (result != true) return;

    await refreshData();

    if (!mounted) return;

    AppDialog.success(
      context,
      message: 'Hutang supplier berhasil ditambahkan',
    );
  }

  Future<void> openDetail(int supplierId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierDetailPage(
          supplierId: supplierId,
        ),
      ),
    );

    if (!mounted) return;
    await refreshData();
  }

  Widget buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Belum Lunas'),
            selected: selectedFilter == 'BELUM_LUNAS',
            onSelected: (_) {
              setState(() {
                selectedFilter = 'BELUM_LUNAS';
              });
            },
          ),
          ChoiceChip(
            label: const Text('Semua'),
            selected: selectedFilter == 'SEMUA',
            onSelected: (_) {
              setState(() {
                selectedFilter = 'SEMUA';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    final message = selectedFilter == 'SEMUA'
        ? 'Belum ada data hutang supplier'
        : 'Tidak ada hutang supplier yang belum lunas';

    return ListView(
      children: [
        buildFilterBar(),
        const SizedBox(height: 100),
        const Icon(
          Icons.local_shipping_outlined,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSupplierList() {
    return ListView.builder(
      itemCount: filteredData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return buildFilterBar();
        }

        final item = filteredData[index - 1];

        final supplierId = item['supplier_id'];
        final nama = item['nama']?.toString() ?? '-';
        final jumlahHutang = item['jumlah_hutang'] as int? ?? 0;
        final sisaHutang = item['sisa_hutang'] as int? ?? 0;
        final isLunas = sisaHutang <= 0;

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.local_shipping_outlined),
            ),
            title: Text(
              nama,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              isLunas ? 'LUNAS' : '$jumlahHutang hutang belum lunas',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(sisaHutang),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isLunas ? 'LUNAS' : 'AKTIF',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLunas ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            onTap: supplierId == null
                ? null
                : () {
                    openDetail(supplierId as int);
                  },
          ),
        );
      },
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: filteredData.isEmpty ? buildEmptyState() : buildSupplierList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hutang Supplier'),
        actions: [
          IconButton(
            onPressed: showTambahHutangDialog,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AppDrawer(
        currentPage: 'Supplier',
      ),
      body: SafeArea(
        child: buildBody(),
      ),
    );
  }
}