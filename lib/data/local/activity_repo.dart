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

    final debtPayments = await db.rawQuery('''
    SELECT
      'PEMBAYARAN_PIUTANG' AS tipe,
      pp.id AS reference_id,
      pp.nominal,
      pp.tanggal,
      c.nama AS catatan
    FROM piutang_payments pp
    LEFT JOIN customers c ON c.id = pp.customer_id
    WHERE pp.tanggal >= ?
  ''', [startOfDay]);

    final activities = <Map<String, dynamic>>[
      ...sales,
      ...expenses,
      ...stocks,
      ...debtPayments,
    ];

    activities.sort((a, b) {
      final aTanggal = a['tanggal'] as int? ?? 0;
      final bTanggal = b['tanggal'] as int? ?? 0;

      return aTanggal.compareTo(bTanggal);
    });

    return activities;
  }
  
  Future<Map<String, dynamic>> getTodayCashSummary() async {
    final db = await _dbHelper.db;

    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;

    final sales = await db.rawQuery('''
      SELECT COALESCE(SUM(total), 0) as total
      FROM transaksi
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final expenses = await db.rawQuery('''
      SELECT COALESCE(SUM(nominal), 0) as total
      FROM pengeluaran
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final debtPayments = await db.rawQuery('''
      SELECT COALESCE(SUM(nominal), 0) as total
      FROM piutang_payments
      WHERE tanggal >= ?
    ''', [startOfDay]);

    final uangMasuk = sales.first['total'] as int? ?? 0;
    final uangKeluar = expenses.first['total'] as int? ?? 0;
    final bayarPiutang = debtPayments.first['total'] as int? ?? 0;

    return {
      'uang_masuk': uangMasuk + bayarPiutang,
      'penjualan': uangMasuk,
      'bayar_piutang': bayarPiutang,
      'uang_keluar': uangKeluar,
      'kas_bersih': uangMasuk + bayarPiutang - uangKeluar,
    };
  }
}