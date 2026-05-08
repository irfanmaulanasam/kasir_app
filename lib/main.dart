import 'package:flutter/material.dart';
import 'ui/produk/produk_page.dart';
import 'ui/transaksi/transaksi_page.dart';
import 'ui/transaksi/riwayat_page.dart';
import 'ui/inventory/inventory_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kasir App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProdukPage()),
                );
              },
              child: const Text("Kelola Produk"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransaksiPage()),
                );
              },
              child: const Text("Transaksi"),

            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiwayatPage(),
                  ),
                );
              },
              child: const Text('Riwayat'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InventoryPage()),
                );
              },
              child: const Text('Stok'),
            ),
          ],
        ),
      ),
    );
  }
}