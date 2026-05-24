import 'package:flutter/material.dart';

class ProductListSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>>? produkList;
  final String searchQuery;

  final String Function(int value) formatRupiah;

  final void Function(Map<String, dynamic> produk)
      onTapProduk;

  final VoidCallback onTambahProdukBaru;

  const ProductListSection({
    super.key,
    required this.produkList,
    required this.searchQuery,
    required this.formatRupiah,
    required this.onTapProduk,
    required this.onTambahProdukBaru,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: produkList,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        final data = snapshot.data ?? [];

        final filteredData = data.where((produk) {
          final nama =
              (produk['nama'] ?? '')
                  .toString()
                  .toLowerCase();

          return nama.contains(searchQuery);
        }).toList();

        if (filteredData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Text(
                  'Produk tidak ditemukan',
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onTambahProdukBaru,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Tambah Produk Baru',
                  ),
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
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                enabled:
                    (produk['stok'] ?? 0) > 0,

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

                onTap:
                    (produk['stok'] ?? 0) <= 0
                        ? null
                        : () => onTapProduk(
                              produk,
                            ),
              ),
            );
          },
        );
      },
    );
  }
}