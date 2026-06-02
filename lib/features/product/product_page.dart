import 'package:flutter/material.dart';
import 'package:kasir_app/core/widgets/app_dialog.dart';
import 'package:kasir_app/features/splash/app_launcher_page.dart';
import 'package:kasir_app/features/widgets/app_drawer.dart';

import '../../core/formatters/currency_formatter.dart';
import '../../core/widgets/currency_text_field.dart';
import '../../core/widgets/stock_input_field.dart';
import '../../data/local/produk_repo.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final hargaBeliController = TextEditingController();
  final minimumStokController = TextEditingController();

  final repo = ProdukRepo();

  Future<List<Map<String, dynamic>>>? produkList;

  double stockDasar = 0;
  String satuanDasar = 'pcs';
  int stockInputKey = 0;

  @override
  void initState() {
    super.initState();
    produkList = repo.getAll();
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    hargaBeliController.dispose();
    minimumStokController.dispose();
    super.dispose();
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '').trim()) ?? 0;
  }

  void refreshProduk() {
    setState(() {
      produkList = repo.getAll();
    });
  }

  Future<void> simpan() async {
    final nama = namaController.text.trim();
    final hargaJual = parseCurrency(hargaController.text);
    final hargaBeli = parseCurrency(hargaBeliController.text);
    final minimumStok = int.tryParse(minimumStokController.text.trim()) ?? 0;

    if (nama.isEmpty) {
      AppDialog.error(context, message: 'Nama barang wajib diisi');
      return;
    }

    if (hargaJual <= 0) {
      AppDialog.error(context, message: 'Harga jual wajib lebih dari 0');
      return;
    }

    await repo.insert({
      'nama': nama,
      'harga': hargaJual,
      'harga_beli': hargaBeli,
      'stok': stockDasar.toInt(),
      'satuan_dasar': satuanDasar,
      'minimum_stok': minimumStok,
    });

    final semuaProduk = await repo.getAll();
    final isFirstProduct = semuaProduk.length == 1;

    if (!mounted) return;

    namaController.clear();
    hargaController.clear();
    hargaBeliController.clear();
    minimumStokController.clear();

    setState(() {
      stockDasar = 0;
      satuanDasar = 'pcs';
      stockInputKey++;
      produkList = repo.getAll();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Produk berhasil disimpan'),
        action: isFirstProduct
            ? SnackBarAction(
                label: 'Buka Kasir',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppLauncherPage(),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  Widget buildFormInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Barang',
            ),
          ),
          const SizedBox(height: 10),
          CurrencyTextField(
            controller: hargaController,
            label: 'Harga Jual Produk',
          ),
          const SizedBox(height: 10),
          CurrencyTextField(
            controller: hargaBeliController,
            label: 'Harga Beli Produk',
          ),
          const SizedBox(height: 10),
          StockInputField(
            key: ValueKey(stockInputKey),
            onChanged: (result) {
              stockDasar = result.baseStock;
              satuanDasar = result.baseUnit;
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: minimumStokController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum Stok',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: simpan,
        child: const Text('Simpan'),
      ),
    );
  }

  Widget buildProdukList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: produkList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Belum ada produk'),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final produk = data[i];
              final stok = produk['stok'] as int? ?? 0;
              final minimumStok = produk['minimum_stok'] as int? ?? 0;
              final stokKritis = minimumStok > 0 && stok <= minimumStok;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(produk['nama'].toString()),
                  subtitle: Text(
                    '${CurrencyFormatter.format(produk["harga"])} | '
                    'Stok: $stok | '
                    'Min: $minimumStok',
                  ),
                  leading: const Icon(Icons.inventory_2_outlined),
                  trailing: stokKritis
                      ? const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        )
                      : const Icon(Icons.chevron_right),
                ),
              );
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
        title: const Text('Produk'),
      ),
      drawer: const AppDrawer(
        currentPage: 'Produk',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: buildFormInput(),
            ),
            buildSaveButton(),
            const Divider(height: 1),
            buildProdukList(),
          ],
        ),
      ),
    );
  }
}