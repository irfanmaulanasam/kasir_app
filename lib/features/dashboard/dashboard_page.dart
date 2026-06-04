import 'package:flutter/material.dart';

import '../product/product_page.dart';
import '../transactions/pages/transaction_page.dart';
import '../transactions/pages/transaction_history_page.dart';
import '../inventory/pages/inventory_page.dart';
import '../settings/settings_page.dart';

import '../../core/config/flavor_config.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {

    final isPro = FlavorConfig.isPro();

    return Scaffold(

      appBar: AppBar(
        title: Text(
          FlavorConfig.instance.appTitle,
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: GridView.count(

          crossAxisCount: 2,

          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          children: [

            _menuCard(
              context,
              'Kelola Produk',
              Icons.inventory_2_outlined,
              const ProdukPage(),
            ),

            _menuCard(
              context,
              'Transaksi',
              Icons.point_of_sale,
              const TransaksiPage(),
            ),

            _menuCard(
              context,
              'Riwayat Penjualan',
              Icons.receipt_long,
              const RiwayatPage(),
            ),

            _menuCard(
              context,
              'Inventory',
              Icons.warehouse_outlined,
              const InventoryPage(),
            ),

            _menuCard(
              context,
              'Settings',
              Icons.settings,
              const SettingsPage(),
            ),

            if (isPro)
              Card(
                color: Colors.orange.shade100,

                child: InkWell(

                  borderRadius: BorderRadius.circular(12),

                  onTap: () {
                    // future cloud sync
                  },

                  child: const Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      Icon(
                        Icons.cloud_sync,
                        size: 40,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Cloud Sync',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {

    return Card(

      elevation: 3,

      child: InkWell(

        borderRadius: BorderRadius.circular(12),

        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              icon,
              size: 40,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}