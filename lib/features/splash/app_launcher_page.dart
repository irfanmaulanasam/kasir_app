import 'package:flutter/material.dart';

import '../../data/local/settings_repo.dart';
import '../../data/local/produk_repo.dart';

import '../settings/setup_store_page.dart';
import '../product/product_page.dart';
import '../transactions/pages/transaction_page.dart';

class AppLauncherPage extends StatefulWidget {
  const AppLauncherPage({super.key});

  @override
  State<AppLauncherPage> createState() => _AppLauncherPageState();
}

class _AppLauncherPageState extends State<AppLauncherPage> {
  @override
  void initState() {
    super.initState();
    checkAppState();
  }

  Future<void> checkAppState() async {
    final settings = await SettingsRepo().getSettings();
    final namaToko = settings?['nama_toko'] ?? '';

    if (!mounted) return;

    if (namaToko.toString().trim().isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupStorePage()),
      );
      return;
    }

    final produkList = await ProdukRepo().getAll();

    if (!mounted) return;

    if (produkList.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProdukPage()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TransaksiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}