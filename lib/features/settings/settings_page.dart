import 'package:flutter/material.dart';
import 'package:kasir_app/core/services/backup_service.dart';
import 'package:kasir_app/core/widgets/app_dialog.dart';
import 'package:kasir_app/features/widgets/app_drawer.dart';
import 'package:kasir_app/data/local/settings_repo.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../splash/app_launcher_page.dart';
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
  final backupService = BackupService();

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
      drawer: const AppDrawer(
        currentPage: 'Settings',
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
              SizedBox(height: 12,),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final path = await backupService.createBackup();

                    if (!context.mounted) return;

                    AppDialog.success(
                      context,
                      message: 'Backup berhasil disimpan.\n\nLokasi:\n$path',
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    AppDialog.error(
                      context,
                      message: 'Gagal backup: $e',
                    );
                  }
                },
                icon: const Icon(Icons.backup),
                label: const Text('Backup Data'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await backupService.shareLatestBackup();

                    if (!context.mounted) return;

                    AppDialog.success(
                      context,
                      message: 'Backup berhasil dibagikan.',
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    AppDialog.error(
                      context,
                      message: 'Gagal membagikan backup: $e',
                    );
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text('Bagikan Backup'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final result = await fp.FilePicker.pickFiles(
                      type: fp.FileType.custom,
                      allowedExtensions: ['kasir', 'db'],
                    );

                    if (result == null || result.files.single.path == null) {
                      return;
                    }

                    if (!context.mounted) return;

                    final confirm = await AppDialog.confirm(
                      context,
                      title: 'Restore Backup',
                      message:
                          'Restore akan mengganti semua data aplikasi saat ini. Lanjutkan?',
                      confirmText: 'Restore',
                    );

                    if (!confirm) return;

                    await backupService.restoreBackup(
                      result.files.single.path!,
                    );

                    if (!context.mounted) return;

                    AppDialog.success(
                      context,
                      message: 'Restore berhasil. Aplikasi akan memuat ulang data.',
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppLauncherPage(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    AppDialog.error(
                      context,
                      message: 'Gagal restore: $e',
                    );
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}