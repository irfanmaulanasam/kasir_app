import 'package:flutter/material.dart';
import 'package:kasir_app/data/local/cash_session_repo.dart';
import 'package:kasir_app/features/cash/widgets/open_cash_dialog.dart';
import 'package:kasir_app/features/splash/welcome_page.dart';
import '../../data/local/settings_repo.dart';
import '../../data/local/produk_repo.dart';
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
        MaterialPageRoute(builder: (_) => const WelcomePage()),
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

    final cashSession = await CashSessionRepo().getTodaySession();

    if (!mounted) return;

    if (cashSession == null) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const OpenCashDialog(),
      );

      if (result == null) return;

      await CashSessionRepo().createTodaySession(
        kasAwal: result['kas_awal'] as int? ?? 0,
        catatan: result['catatan']?.toString() ?? '',
      );
      if(!mounted)return;
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