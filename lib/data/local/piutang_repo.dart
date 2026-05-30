import '../../core/db/db_helper.dart';

class PiutangRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert({
    required int transaksiId,
    required String namaPelanggan,
    required int total,
    required int dibayar,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;
    final sisa = total - dibayar;

    return db.insert('piutang', {
      'transaksi_id': transaksiId,
      'nama_pelanggan': namaPelanggan,
      'total': total,
      'dibayar': dibayar,
      'sisa': sisa,
      'status': sisa <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
      'catatan': catatan,
      'tanggal': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.db;

    return db.query(
      'piutang',
      orderBy: 'tanggal DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getBelumLunas() async {
    final db = await _dbHelper.db;

    return db.query(
      'piutang',
      where: 'status = ?',
      whereArgs: ['BELUM_LUNAS'],
      orderBy: 'tanggal DESC',
    );
  }

  Future<void> bayarPiutang({
    required int id,
    required int nominal,
  }) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'piutang',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw Exception('Piutang tidak ditemukan');
      }

      final current = rows.first;
      final dibayarLama = current['dibayar'] as int? ?? 0;
      final sisaLama = current['sisa'] as int? ?? 0;

      final dibayarBaru = dibayarLama + nominal;
      final sisaBaru = sisaLama - nominal;

      await txn.update(
        'piutang',
        {
          'dibayar': dibayarBaru,
          'sisa': sisaBaru < 0 ? 0 : sisaBaru,
          'status': sisaBaru <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}