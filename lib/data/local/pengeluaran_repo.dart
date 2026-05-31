import '../../core/db/db_helper.dart';

class PengeluaranRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert({
    required String kategori,
    required int nominal,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;

    return db.insert('pengeluaran', {
      'kategori': kategori,
      'nominal': nominal,
      'catatan': catatan,
      'tanggal': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.db;

    return db.query(
      'pengeluaran',
      orderBy: 'tanggal DESC',
    );
  }
}