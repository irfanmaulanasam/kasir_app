import 'package:flutter/material.dart';

import '../../data/local/settings_repo.dart';

import '../settings/setup_store_page.dart';
import '../transaksi/transaksi_page.dart';

class AppLauncherPage
    extends StatefulWidget {

  const AppLauncherPage({
    super.key,
  });

  @override
  State<AppLauncherPage>
      createState() =>
          _AppLauncherPageState();
}

class _AppLauncherPageState
    extends State<AppLauncherPage> {

  @override
  void initState() {
    super.initState();
    checkStore();
  }

  Future<void> checkStore() async {
    final settings = await SettingsRepo().getSettings();

    final namaToko = settings?['nama_toko'] ?? '';

    if (!mounted) return;

    if (namaToko.toString().trim().isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SetupStorePage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TransaksiPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(

      body: Center(
        child:
            CircularProgressIndicator(),
      ),
    );
  }
}