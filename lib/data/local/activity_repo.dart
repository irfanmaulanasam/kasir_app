import '../../core/db/db_helper.dart';

class ActivityRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getActivityByRange({
    required int start,
    required int end,
  }) async {
    final db = await _dbHelper.db;

    final sales = await db.rawQuery('''
      SELECT
        'PENJUALAN' AS tipe,
        id AS reference_id,
        total AS nominal,
        tanggal,
        'Transaksi penjualan' AS catatan
      FROM transaksi
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    final expenses = await db.rawQuery('''
      SELECT
        'PENGELUARAN' AS tipe,
        id AS reference_id,
        nominal,
        tanggal,
        catatan
      FROM pengeluaran
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    final stocks = await db.rawQuery('''
      SELECT
        s.tipe AS tipe,
        s.id AS reference_id,
        s.qty AS nominal,
        s.tanggal,
        p.nama AS catatan
      FROM stok_log s
      LEFT JOIN produk p ON p.id = s.produk_id
      WHERE s.tanggal >= ? AND s.tanggal < ?
    ''', [start, end]);

    final debtPayments = await db.rawQuery('''
      SELECT
        'PEMBAYARAN_PIUTANG' AS tipe,
        pp.customer_id AS reference_id,
        pp.nominal,
        pp.tanggal,
        c.nama AS catatan
      FROM piutang_payments pp
      LEFT JOIN customers c ON c.id = pp.customer_id
      WHERE pp.tanggal >= ? AND pp.tanggal < ?
    ''', [start, end]);

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

  Future<Map<String, dynamic>> getCashSummaryByRange({
    required int start,
    required int end,
  }) async {
    final db = await _dbHelper.db;

    final sales = await db.rawQuery('''
      SELECT COALESCE(SUM(total), 0) as total
      FROM transaksi
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    final expenses = await db.rawQuery('''
      SELECT COALESCE(SUM(nominal), 0) as total
      FROM pengeluaran
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    final debtPayments = await db.rawQuery('''
      SELECT COALESCE(SUM(nominal), 0) as total
      FROM piutang_payments
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);

    final cashSession = await db.rawQuery('''
      SELECT COALESCE(SUM(kas_awal), 0) as total
      FROM cash_sessions
      WHERE tanggal >= ? AND tanggal < ?
    ''', [start, end]);


    final kasAwal = cashSession.first['total'] as int? ?? 0;
    final uangMasuk = sales.first['total'] as int? ?? 0;
    final uangKeluar = expenses.first['total'] as int? ?? 0;
    final bayarPiutang = debtPayments.first['total'] as int? ?? 0;

    return {
      'kas_awal': kasAwal,
      'uang_masuk': uangMasuk + bayarPiutang,
      'penjualan': uangMasuk,
      'bayar_piutang': bayarPiutang,
      'uang_keluar': uangKeluar,
      'kas_bersih': uangMasuk + bayarPiutang - uangKeluar,
    };
  }
}