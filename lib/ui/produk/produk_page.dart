import 'package:flutter/material.dart';
import '../../data/local/produk_repo.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {

  final namaController = TextEditingController();
  final hargaController = TextEditingController();

  final repo = ProdukRepo();

  Future<List<Map<String, dynamic>>>? produkList;

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

  void simpan() async {
    await repo.insert({
      "nama": namaController.text,
      "harga": int.parse(hargaController.text),
    });

    namaController.clear();
    hargaController.clear();

    loadProduk(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produk")),

      body: Column(
        children: [

          // 🔹 FORM INPUT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: "Nama Barang"),
                ),
                TextField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: "Harga"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: simpan,
                  child: const Text("Simpan"),
                ),
              ],
            ),
          ),

          const Divider(),

          // 🔹 LIST PRODUK
          Expanded(
            child: FutureBuilder(
              future: produkList,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data as List;

                if (data.isEmpty) {
                  return const Center(child: Text("Belum ada produk"));
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(data[i]['nama']),
                      subtitle: Text("Rp ${data[i]['harga']}"),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}