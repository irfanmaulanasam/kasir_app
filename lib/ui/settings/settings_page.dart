import 'package:flutter/material.dart';
import '../../data/local/settings_repo.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {

  final repo = SettingsRepo();

  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final teleponController = TextEditingController();
  final footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {

    final data = await repo.getSettings();

    if (data == null) return;

    namaController.text =
        data['nama_toko'] ?? '';

    alamatController.text =
        data['alamat'] ?? '';

    teleponController.text =
        data['telepon'] ?? '';

    footerController.text =
        data['footer'] ?? '';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Settings Toko'),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: teleponController,
                decoration: const InputDecoration(
                  labelText: 'Telepon',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: footerController,
                decoration: const InputDecoration(
                  labelText: 'Footer Nota',
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    await repo.saveSettings(
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

                    messenger.showSnackBar(
                      const SnackBar(
                        content:
                            Text('Settings disimpan'),
                      ),
                    );
                  },

                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}