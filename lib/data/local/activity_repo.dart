import '../../core/db/db_helper.dart';

class ActivityRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getTodayActivity() async {
    final db = await _dbHelper.db;

    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;

    final sales = await db.rawQuery('''
      SELECT
        'PENJUALAN' AS tipe,
        id AS reference_id,
        total AS nominal,
        tanggal,
        'Transaksi penjualan' AS catatan
      FROM transaksi
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final expenses = await db.rawQuery('''
      SELECT
        'PENGELUARAN' AS tipe,
        id AS reference_id,
        nominal,
        tanggal,
        catatan
      FROM pengeluaran
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final stocks = await db.rawQuery('''
      SELECT
        tipe AS tipe,
        produk_id AS reference_id,
        qty AS nominal,
        tanggal,
        catatan
      FROM stok_log
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final activities = <Map<String, dynamic>>[
      ...sales,
      ...expenses,
      ...stocks,
    ];

    activities.sort((a, b) {
      final aTanggal = a['tanggal'] as int? ?? 0;
      final bTanggal = b['tanggal'] as int? ?? 0;

      return bTanggal.compareTo(aTanggal);
    });

    return activities;
  }
}