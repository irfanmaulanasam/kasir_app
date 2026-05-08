import 'package:flutter/material.dart';
import '../../data/local/produk_repo.dart';
import '../../data/local/transaksi_repo.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
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

  void tambahKeCart(Map<String, dynamic> produk) {
    final int id = produk['id'] as int;

    setState(() {
      if (cart.containsKey(id)) {
        cart[id]!['qty'] = (cart[id]!['qty'] as int) + 1;
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

  Future<void> bayar() async {
  if (cart.isEmpty) return;

  try {

    final transaksiRepo = TransaksiRepo();

    final transaksiId = await transaksiRepo.simpanTransaksi(
      cart.values.toList(),
    );

    if (!mounted) return;

    setState(() {
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaksi tersimpan. ID: $transaksiId'),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal simpan transaksi: $e'),
      ),
    );

  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: loadProduk,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 5, 10, 24),
        child: Column(
        children: [
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
                  itemBuilder: (context, index) {
                    final produk = data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(produk['nama'].toString()),
                        subtitle: Text(
                          formatRupiah(produk['harga'] as int),
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () => tambahKeCart(produk),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

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
                  onPressed: cart.isEmpty ? null : bayar,
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