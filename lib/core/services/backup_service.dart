import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../db/db_helper.dart';

class BackupService {
  static const String databaseName = 'kasir.db';

  Future<String> createBackup() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = p.join(dbPath, databaseName);

    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database tidak ditemukan');
    }

    final backupDir = await getApplicationDocumentsDirectory();

    final now = DateTime.now();
    final fileName =
        'kasir_backup_${now.year}${_two(now.month)}${_two(now.day)}_'
        '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}.db';

    final backupPath = p.join(
      backupDir.path,
      fileName,
    );

    final backupFile = await sourceFile.copy(backupPath);

    return backupFile.path;
  }

  Future<void> shareBackup() async {
    final backupPath = await createBackup();

    await SharePlus.instance.share(
      ShareParams(
        text: 'Backup data Kasir App',
        files: [
          XFile(backupPath),
        ],
      ),
    );
  }

  Future<void> restoreBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      throw Exception('File backup tidak ditemukan');
    }

    if (!backupFilePath.endsWith('.db')) {
      throw Exception('File backup harus berformat .db');
    }

    final dbPath = await getDatabasesPath();
    final targetPath = p.join(dbPath, databaseName);

    // Tutup koneksi database aktif dulu
    await DBHelper.closeDatabase();

    // Timpa database lama
    await backupFile.copy(targetPath);

    // Reset instance database agar nanti dibuka ulang
    DBHelper.resetDatabase();
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}