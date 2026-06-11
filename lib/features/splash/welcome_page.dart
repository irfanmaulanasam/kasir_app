import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

import '../../core/services/backup_service.dart';
import '../../core/widgets/app_dialog.dart';
import '../settings/setup_store_page.dart';
import 'app_launcher_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> restoreBackup(BuildContext context) async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      if (!context.mounted) return;

      final confirm = await AppDialog.confirm(
        context,
        title: 'Restore Backup',
        message: 'Restore akan menimpa data aplikasi saat ini. Lanjutkan?',
        confirmText: 'Restore',
      );

      if (!confirm) return;

      await BackupService().restoreBackup(
        result.files.single.path!,
      );

      if (!context.mounted) return;

      AppDialog.success(
        context,
        message: 'Restore berhasil',
      );

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppLauncherPage(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      await AppDialog.error(
        context,
        message: 'Gagal restore backup: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.point_of_sale,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'Kasir App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai toko baru atau pulihkan data dari backup.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SetupStorePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.storefront),
                label: const Text('Setup Toko Baru'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  restoreBackup(context);
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}