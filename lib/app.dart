import 'package:flutter/material.dart';
import 'core/config/flavor_config.dart';
import 'ui/produk/produk_page.dart';
import 'ui/transaksi/transaksi_page.dart';
import 'ui/transaksi/riwayat_page.dart';
import 'ui/inventory/inventory_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.appTitle,
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isPro = FlavorConfig.isPro();

    return Scaffold(
      appBar: AppBar(title: Text(FlavorConfig.instance.appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(context, "Kelola Produk", const ProdukPage()),
            const SizedBox(height: 20),
            _menuButton(context, "Transaksi", const TransaksiPage()),
            const SizedBox(height: 20),
            _menuButton(context, "Riwayat", const RiwayatPage()),
            const SizedBox(height: 20),
            _menuButton(context, "Stok", const InventoryPage()),
            
            // FITUR KHUSUS PRO
            if (isPro) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  // Panggil fungsi sinkronisasi cloud di sini
                },
                child: const Text("Sync Cloud (Pro Only)"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Text(label),
    );
  }
}