import 'package:flutter/material.dart';
import 'package:kasir_app/features/inventory/pages/inventory_page.dart';
import '../summary/summary_page.dart';
import '../transactions/pages/transaction_page.dart';
import '../product/product_page.dart';
import '../settings/settings_page.dart';

class AppDrawer extends StatelessWidget {

  final String currentPage;

  const AppDrawer({
    super.key,
    required this.currentPage,
  });

  Widget buildMenu({

    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget page,
  }) {

    final isActive =
        currentPage == title;

    return ListTile(

      leading: Icon(icon),

      title: Text(title),

      selected: isActive,

      enabled: !isActive,

      onTap: isActive
          ? null
          : () {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(
                  builder: (_) => page,
                ),
              );
            },
    );
  }
  @override
  Widget build(BuildContext context) {

    return Drawer(

      child: ListView(

        padding: EdgeInsets.zero,

        children: [

          const DrawerHeader(

            child: Text(

              'Kasir App',

              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),

          buildMenu(
            context: context,
            title: 'Transaksi',
            icon: Icons.point_of_sale,
            page: const TransaksiPage(),
          ),

          buildMenu(
            context: context,
            title: 'Tambah Produk',
            icon: Icons.add,
            page: const ProdukPage()
          ),
          
          buildMenu(
            context: context,
            title: 'Inventory',
            icon: Icons.inventory_2,
            page: const InventoryPage(),
          ),

          buildMenu(
            context: context,
            title: 'Riwayat',
            icon: Icons.receipt_long,
            page: const SummaryPage(),
          ),

          buildMenu(
            context: context,
            title: 'Store Settings',
            icon: Icons.settings,
            page: const SettingsPage(),
        ),
        ],
      ),
    );
  }
}