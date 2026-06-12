import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import '../db/db_helper.dart';

class BackupService {
  static const String databaseName = 'kasir.db';
  static const String backupFolderName = 'KasirAppBackup';

  Future<Directory> _getBackupDirectory() async {
    final baseDir = await getExternalStorageDirectory();

    if (baseDir == null) {
      throw Exception('Folder penyimpanan tidak ditemukan');
    }

    final backupDir = Directory(
      p.join(baseDir.path, backupFolderName),
    );

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  Future<String> createBackup() async {
    final dbPath = await getDatabasesPath();
    final sourcePath = p.join(dbPath, databaseName);
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database tidak ditemukan');
    }

    final backupDir = await _getBackupDirectory();

    final now = DateTime.now();
    final fileName =
        'kasir_backup_${now.year}${_two(now.month)}${_two(now.day)}_'
        '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}.kasir';

    final backupPath = p.join(backupDir.path, fileName);

    await sourceFile.copy(backupPath);

    return backupPath;
  }

  Future<File?> getLatestBackupFile() async {
    final backupDir = await _getBackupDirectory();

    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.kasir'))
        .toList();

    if (files.isEmpty) return null;

    files.sort((a, b) {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    });

    return files.first;
  }

  Future<String> shareLatestBackup() async {
    final latestFile = await getLatestBackupFile();

    if (latestFile == null) {
      throw Exception('Belum ada file backup. Buat backup dulu.');
    }

    await SharePlus.instance.share(
      ShareParams(
        text: 'Backup data Kasir App',
        files: [
          XFile(latestFile.path),
        ],
      ),
    );

    return latestFile.path;
  }

  Future<void> restoreBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      throw Exception('File backup tidak ditemukan');
    }

    if (!backupFilePath.endsWith('.kasir') &&
        !backupFilePath.endsWith('.db')) {
      throw Exception('File backup tidak valid');
    }

    final dbPath = await getDatabasesPath();
    final targetPath = p.join(dbPath, databaseName);

    await DBHelper.closeDatabase();

    await backupFile.copy(targetPath);

    DBHelper.resetDatabase();
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}