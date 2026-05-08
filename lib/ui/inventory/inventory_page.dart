import 'package:flutter/material.dart';
import '../../data/local/produk_repo.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ProdukRepo repo = ProdukRepo();
  Future<List<Map<String, dynamic>>>? produkList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    setState(() {
      produkList = repo.getAll();
    });
  }

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  Future<void> showAdjustDialog(
      Map<String, dynamic> produk, {
      required bool tambah,
    }) async {
      final qtyController = TextEditingController();
      final catatanController = TextEditingController();
      String alasan = tambah ? 'Tambah Stok' : 'Kurangi Stok'; 
      catatanController.text = alasan;
      final pageContext = context;

      await showDialog(
        context: pageContext,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('${tambah ? "Tambah" : "Kurangi"} stok'),
            content: Column(

              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${produk['nama']}'),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Qty'),
                ),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
                DropdownButtonFormField<String>(
                  value: alasan,

                  items: (tambah
                          ? [
                              'Restock',
                              'Supplier datang',
                              'Koreksi stok',
                            ]
                          : [
                              'Barang rusak',
                              'Dipakai internal',
                              'Hilang',
                              'Koreksi stok',
                              'Retur',
                            ])
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),

                  onChanged: (value) {
                    alasan = value!;
                    catatanController.text = value;
                  },

                  decoration: const InputDecoration(
                    labelText: 'Alasan',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyController.text) ?? 0;
                  if (qty <= 0) return;
                  if (!tambah && catatanController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      const SnackBar(
                        content: Text('Catatan wajib untuk pengurangan stok'),
                      ),
                    );
                    return;
                  }
                  try {
                    if (tambah) {
                      await repo.tambahStok(
                        produk['id'] as int,
                        qty,
                        catatan: catatanController.text,
                      );
                    } else {
                      await repo.kurangiStokManual(
                        produk['id'] as int,
                        qty,
                        catatan: catatanController.text,
                      );
                    }

                    if (!pageContext.mounted) return;
                    Navigator.of(pageContext).pop();
                    loadData();
                  } catch (e) {
                    if (!pageContext.mounted) return;
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(content: Text('$e')),
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

  Future<void> showLog(Map<String, dynamic> produk) async {
    final logs = await repo.getStockLog(produk['id'] as int);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          children: [
            ListTile(
              title: Text(produk['nama'].toString()),
              subtitle: Text('Stok sekarang: ${produk['stok']}'),
            ),
            const Divider(),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada histori stok'),
              )
            else
              ...logs.map((log) {
                final type = log['tipe'].toString();
                final qty = log['qty'] as int;
                final catatan = (log['catatan'] ?? '').toString();
                final tanggal = DateTime.fromMillisecondsSinceEpoch(log['tanggal'] as int);

                return ListTile(
                  leading: Icon(
                    type == 'MASUK' ? Icons.add_circle : Icons.remove_circle,
                  ),
                  title: Text('$type $qty'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (catatan.isNotEmpty)
                        Text(catatan),

                      const SizedBox(height: 4),

                      Text(
                        tanggal.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
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
              return const Center(child: Text('Belum ada produk'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final produk = data[i];
                final stok = produk['stok'] as int? ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(produk['nama'].toString()),
                    subtitle: Text(
                      '${rupiah(produk['harga'] as int)} | Stok: $stok',
                    ),
                    onTap: () => showLog(produk),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => showAdjustDialog(produk, tambah: false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => showAdjustDialog(produk, tambah: true),
                        ),
                      ],
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