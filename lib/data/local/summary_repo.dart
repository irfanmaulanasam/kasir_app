import '../../core/db/db_helper.dart';

class SummaryRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<Map<String, dynamic>> getTodaySummary() async {
    final db = await _dbHelper.db;

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_transaksi,
        COALESCE(SUM(total), 0) as omzet
      FROM transaksi
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    return result.first;
  }

  Future<Map<String, dynamic>> getPiutangSummary() async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as jumlah_piutang,
        COALESCE(SUM(sisa), 0) as total_piutang
      FROM piutang
      WHERE status = ?
    ''', ['BELUM_LUNAS']);

    return result.first;
  }
}