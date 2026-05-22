import 'package:flutter/material.dart';

import '../../data/local/settings_repo.dart';
import '../transaksi/transaksi_page.dart';

class SetupStorePage extends StatefulWidget {
  const SetupStorePage({super.key});

  @override
  State<SetupStorePage> createState() =>
      _SetupStorePageState();
}

class _SetupStorePageState
    extends State<SetupStorePage> {

  final namaController =
      TextEditingController();

  final alamatController =
      TextEditingController();

  final teleponController = 
      TextEditingController();

  final footerController =
      TextEditingController();

  Future<void> simpan() async {

    await SettingsRepo()
    .saveSettings(
        namaToko:
            namaController.text,

        alamat:
            alamatController.text,

        telepon:
            teleponController.text,

        footer:
            footerController.text,
      );

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder: (_) =>
            const TransaksiPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Setup Toko',
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: namaController,
              decoration:
                  const InputDecoration(
                labelText: 'Nama Toko',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  alamatController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Alamat Toko',
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller:
                  teleponController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Telepon Toko',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  footerController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Footer Nota',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(
                onPressed: simpan,
                child: const Text(
                  'Simpan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}