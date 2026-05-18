import '../../core/db/db_helper.dart';

class SettingsRepo {

  final DBHelper _dbHelper = DBHelper();

  Future<void> saveSettings({
    required String namaToko,
    required String alamat,
    required String telepon,
    required String footer,
  }) async {

    final db = await _dbHelper.db;

    final existing = await db.query('settings');

    if (existing.isEmpty) {

      await db.insert('settings', {
        'nama_toko': namaToko,
        'alamat': alamat,
        'telepon': telepon,
        'footer': footer,
      });

    } else {

      await db.update(
        'settings',
        {
          'nama_toko': namaToko,
          'alamat': alamat,
          'telepon': telepon,
          'footer': footer,
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );

    }
  }

  Future<Map<String, dynamic>?> getSettings() async {

    final db = await _dbHelper.db;

    final result = await db.query(
      'settings',
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first;
  }
}