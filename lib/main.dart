import 'package:flutter/material.dart';
import 'ui/produk/produk_page.dart';

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
                // nanti transaksi
              },
              child: const Text("Transaksi"),
            ),

          ],
        ),
      ),
    );
  }
}