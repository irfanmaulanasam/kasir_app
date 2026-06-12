import '../../core/db/db_helper.dart';

class CashSessionRepo {
  final DBHelper _dbHelper = DBHelper();

  int startOfToday() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
  }

  Future<Map<String, dynamic>?> getTodaySession() async {
    final db = await _dbHelper.db;
    final today = startOfToday();

    final result = await db.query(
      'cash_sessions',
      where: 'tanggal = ?',
      whereArgs: [today],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first;
  }

  Future<int> createTodaySession({
    required int kasAwal,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;
    final today = startOfToday();

    return db.insert('cash_sessions', {
      'tanggal': today,
      'kas_awal': kasAwal,
      'catatan': catatan,
    });
  }

  Future<void> updateTodaySession({
    required int kasAwal,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;
    final today = startOfToday();

    await db.update(
      'cash_sessions',
      {
        'kas_awal': kasAwal,
        'catatan': catatan,
      },
      where: 'tanggal = ?',
      whereArgs: [today],
    );
  }
}