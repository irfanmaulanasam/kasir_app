import 'package:flutter/material.dart';
import '../../data/local/produk_repo.dart';
import '../../core/widgets/currency_textfield.dart';
import '../../features/product/widgets/stock_input_field.dart';

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

  double stockDasar = 0;
  String satuanDasar = 'pcs';

  final repo = ProdukRepo();

  Future<List<Map<String, dynamic>>>? produkList;

  @override
  void initState() {
    super.initState();
    loadProduk();
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    hargaBeliController.dispose();
    minimumStokController.dispose();
    super.dispose();
  }

  void loadProduk() {
    setState(() {
      produkList = repo.getAll();
    });
  }

  int parseCurrency(String value) {
    return int.tryParse(value.replaceAll('.', '').trim()) ?? 0;
  }

  Future<void> simpan() async {
    final nama = namaController.text.trim();
    final hargaJual = parseCurrency(hargaController.text);
    final hargaBeli = parseCurrency(hargaBeliController.text);
    final minimumStok = int.tryParse(minimumStokController.text.trim()) ?? 0;

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama barang wajib diisi')),
      );
      return;
    }

    if (hargaJual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga jual wajib lebih dari 0')),
      );
      return;
    }

    await repo.insert({
      "nama": nama,
      "harga": hargaJual,
      "harga_beli": hargaBeli,
      "stok": stockDasar.toInt(),
      "satuan_dasar": satuanDasar,
      "minimum_stok": minimumStok,
    });

    namaController.clear();
    hargaController.clear();
    hargaBeliController.clear();
    minimumStokController.clear();

    setState(() {
      stockDasar = 0;
      satuanDasar = 'pcs';
    });

    loadProduk();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil disimpan')),
    );
  }

  Future<void> showTambahStokDialog(Map<String, dynamic> produk) async {
    final qtyController = TextEditingController();
    final pageContext = context;

    await showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tambah stok ${produk['nama']}'),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Qty'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyController.text.trim()) ?? 0;

                if (qty <= 0) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(content: Text('Qty harus lebih dari 0')),
                  );
                  return;
                }

                await repo.tambahStok(
                  produk['id'] as int,
                  qty,
                  catatan: 'stok masuk manual',
                );

                if (!pageContext.mounted) return;

                Navigator.pop(dialogContext);
                loadProduk();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    qtyController.dispose();
  }

  String formatRupiah(dynamic value) {
    final number = value is int ? value : int.tryParse(value.toString()) ?? 0;

    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  Widget buildFormInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: namaController,
            decoration: const InputDecoration(labelText: "Nama Barang"),
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
            onChanged: (result) {
              stockDasar = result.baseStock;
              satuanDasar = result.baseUnit;
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: minimumStokController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minimum Stok'),
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
        child: const Text("Simpan"),
      ),
    );
  }

  Widget buildProdukList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: produkList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada produk"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final produk = data[i];
              final stok = produk['stok'] as int? ?? 0;
              final minimumStok = produk['minimum_stok'] as int? ?? 0;
              final stokKritis = minimumStok > 0 && stok <= minimumStok;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(produk['nama'].toString()),
                  subtitle: Text(
                    '${formatRupiah(produk['harga'])} | '
                    'Stok: $stok | '
                    'Min: $minimumStok',
                  ),
                  leading: stokKritis
                      ? const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        )
                      : const Icon(Icons.inventory_2_outlined),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => showTambahStokDialog(produk),
                  ),
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
        title: const Text("Produk"),
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