import 'package:flutter/material.dart';
import 'package:kasir_app/features/activity/pages/activity_page.dart';
import 'package:kasir_app/features/inventory/pages/inventory_page.dart';
import 'package:kasir_app/features/piutang/pages/piutang_page.dart';
import 'package:kasir_app/features/transactions/pages/transaction_page.dart';
import 'package:kasir_app/features/product/product_page.dart';
import 'package:kasir_app/features/settings/settings_page.dart';
import 'package:kasir_app/features/pengeluaran/pages/pengeluaran_page.dart';
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
            title: 'Stok',
            icon: Icons.inventory_2,
            page: const InventoryPage(),
          ),

          buildMenu(
            context: context,
            title: 'pengeluaran',
            icon: Icons.money_off_csred_outlined,
            page: const PengeluaranPage()
          ),

          buildMenu(
            context: context,
            title: 'Aktivitas',
            icon: Icons.receipt_long,
            page: const ActivityPage(),
          ),

          buildMenu(
            context: context,
            title: 'piutang',
            icon: Icons.people_alt_outlined,
            page: const PiutangPage()
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