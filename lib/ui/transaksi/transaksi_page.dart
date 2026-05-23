import 'package:flutter/material.dart';
import '../../data/local/produk_repo.dart';
import '../../data/local/transaksi_repo.dart';
import '../../data/local/settings_repo.dart';
import 'receipt_preview_page.dart';
import '../../core/widgets/currency_textfield.dart';
import '../widgets/app_drawer.dart';

class TransaksiPage extends StatefulWidget {
  
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  Future<void> showTambahProdukCepatDialog(String initialName) async {
    final namaController = TextEditingController(text: initialName.trim());
    final hargaController = TextEditingController();
    final stokController = TextEditingController();

    final pageContext = context;

    await showDialog(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Produk Baru'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                  ),
                ),
                const SizedBox(height: 12),
                CurrencyTextField(
                  controller: hargaController,
                  label: 'Harga Jual',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok Awal',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nama = namaController.text.trim();
                final harga = int.tryParse(
                      hargaController.text.replaceAll('.', '').trim(),
                    ) ??
                    0;
                final stok = int.tryParse(stokController.text.trim()) ?? 0;

                if (nama.isEmpty || harga <= 0) {
                  ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan harga wajib diisi'),
                    ),
                  );
                  return;
                }

                await repo.insert({
                  'nama': nama,
                  'harga': harga,
                  'harga_beli': 0,
                  'stok': stok,
                  'satuan_dasar': 'pcs',
                  'minimum_stok': 0,
                });

                if (!pageContext.mounted) return;

                Navigator.pop(dialogContext);
                setState(() {
                  searchController.clear();
                  searchQuery = '';
                });
                loadProduk();

                ScaffoldMessenger.of(pageContext).showSnackBar(
                  const SnackBar(
                    content: Text('Produk baru ditambahkan'),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
  }
  final TextEditingController bayarController =
    TextEditingController();
  String metodeBayar = 'Cash';

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  } 

  final ProdukRepo repo = ProdukRepo();
  Future<List<Map<String, dynamic>>>? produkList;

  // cart key = produk id
  final Map<int, Map<String, dynamic>> cart = {};

  @override
  void initState() {
    super.initState();
    loadProduk();
  }

  void loadProduk() {
    setState(() {
      produkList = repo.getAll();
    });
  }

  void tambahKeCart(Map<String, dynamic> produk,) {

    final int id = produk['id'] as int;

    final stok =
        produk['stok'] as int? ?? 0;

    final currentQty =
        cart[id]?['qty'] as int? ?? 0;

    if (currentQty >= stok) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Stok tidak cukup',
          ),
        ),
      );

      return;
    }

    setState(() {

      if (cart.containsKey(id)) {

        cart[id]!['qty'] =
            (cart[id]!['qty'] as int) + 1;

      } else {

        cart[id] = {
          'id': id,
          'nama': produk['nama'],
          'harga': produk['harga'],
          'qty': 1,
        };
      }
    });
  }

  void kurangiQty(int id) {
    setState(() {
      final item = cart[id];
      if (item == null) return;

      final qty = item['qty'] as int;
      if (qty > 1) {
        item['qty'] = qty - 1;
      } else {
        cart.remove(id);
      }
    });
  }

  void hapusItem(int id) {
    setState(() {
      cart.remove(id);
    });
  }

  int getTotal() {
    int total = 0;
    cart.forEach((key, item) {
      total += (item['harga'] as int) * (item['qty'] as int);
    });
    return total;
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  Future<void> showCheckoutDialog() async {

    bayarController.clear();

    int total = getTotal();

    await showDialog(

      context: context,

      builder: (context) {

        return StatefulBuilder(

          builder: (context, setModalState) {

            final bayar =
                int.tryParse(
                      bayarController.text.replaceAll('.', ''),
                    ) ??
                    0;

            final kembalian =
                bayar - total;

            return AlertDialog(

              title: const Text(
                'Pembayaran',
              ),

              content: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Text('Total'),

                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(

                    value: metodeBayar,

                    items: [
                      'Cash',
                      'QRIS',
                      'Transfer',
                    ]
                        .map(
                          (e) =>
                              DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),

                    onChanged: (value) {

                      if (value == null) return;

                      setModalState(() {
                        metodeBayar = value;
                      });
                    },

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Metode Bayar',
                    ),
                  ),

                  const SizedBox(height: 16),

                  CurrencyTextField(
                    controller: bayarController,
                    label: 'Uang Diterima',
                    onChanged: (_) {
                      setModalState(() {});
                    },
                  ), 
                  

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      const Text(
                        'Kembalian',
                      ),

                      Text(
                        formatRupiah(
                          kembalian < 0
                              ? 0
                              : kembalian,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),

                ElevatedButton(

                  onPressed: () async {

                    if (metodeBayar ==
                            'Cash' &&
                        bayar < total) {

                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Uang kurang',
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.pop(context);

                    await bayarDanSimpan(
                      total,
                      bayar,
                      kembalian,
                    );
                  },

                  child:
                      const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> bayarDanSimpan(
    int total,
    int bayar,
    int kembalian,
  ) async {
    if (cart.isEmpty) return;

    final total = getTotal();

    final settingsData =
        await SettingsRepo().getSettings();

    try {
      final transaksiRepo = TransaksiRepo();

      // simpan snapshot item sebelum cart dikosongkan
      final receiptItems =
          cart.values.toList();

      final transaksiId =
          await transaksiRepo.simpanTransaksi(
        receiptItems,
      );

      // CLEAR cart dulu
      setState(() {
        cart.clear();
      });

      if (!mounted) return;

      // baru pindah page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewPage(
            transaksi: {
              'id': transaksiId,
              'total': total,
              'bayar': bayar,
              'kembalian': kembalian,
              'metode_bayar': metodeBayar,
              'tanggal': DateTime.now().millisecondsSinceEpoch,
            },

            items: receiptItems,

            settings: settingsData,
          ),
        ),
      );
    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal simpan transaksi: $e',
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi')
      ),
      drawer: const AppDrawer(
        currentPage: 'Transaksi',
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 5, 10, 24),
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // LIST PRODUK
          Expanded(
            flex: 2,
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

                final filteredData = data.where((produk) {
                  final nama = (produk['nama'] ?? '').toString().toLowerCase();
                  return nama.contains(searchQuery);
                }).toList();

                if (filteredData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Produk tidak ditemukan'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            showTambahProdukCepatDialog(searchController.text);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Produk Baru'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final produk = filteredData[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      child: ListTile(
                        enabled: (produk['stok'] ?? 0) > 0,

                        title: Text(
                          produk['nama'].toString(),
                        ),

                        subtitle: Text(
                          '${formatRupiah(produk['harga'] as int)} • '
                          'Stok: ${produk['stok'] ?? 0}',
                        ),

                        trailing: Icon(
                          (produk['stok'] ?? 0) > 0
                              ? Icons.add_circle_outline
                              : Icons.block,
                        ),

                        onTap: (produk['stok'] ?? 0) <= 0
                            ? null
                            : () => tambahKeCart(produk),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          
          // CART
          Expanded(
            flex: 2,
            child: cart.isEmpty
                ? const Center(
                    child: Text('Cart masih kosong'),
                  )
                : ListView(
                    children: cart.values.map((item) {
                      final int harga = item['harga'] as int;
                      final int qty = item['qty'] as int;
                      final int subtotal = harga * qty;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(item['nama'].toString()),
                          subtitle: Text(
                            '${formatRupiah(harga)} x $qty = ${formatRupiah(subtotal)}',
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => kurangiQty(item['id'] as int),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => hapusItem(item['id'] as int),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const Divider(height: 1),

          // TOTAL + BAYAR
          Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 14),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ${formatRupiah(getTotal())}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: cart.isEmpty ? null : () => showCheckoutDialog(),
                  child: const Text('Bayar'),
                ),
                
              ],

            ),
          ),
          
        ],

      ),
      ),
    );
  }
}