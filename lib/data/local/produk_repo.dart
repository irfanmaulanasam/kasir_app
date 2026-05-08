import '../../core/db/db_helper.dart';

class ProdukRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _dbHelper.db;

    return await db.transaction<int>((txn) async {
      final int stokAwal = (data['stok'] ?? 0) as int;

      final id = await txn.insert('produk', {
        'nama': data['nama'],
        'harga': data['harga'],
        'stok': stokAwal,
      });

      if (stokAwal > 0) {
        await txn.insert('stok_log', {
          'produk_id': id,
          'qty': stokAwal,
          'tipe': 'MASUK',
          'catatan': 'stok awal',
          'tanggal': DateTime.now().millisecondsSinceEpoch,
        });
      }

      return id;
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.db;
    return await db.query('produk', orderBy: 'nama ASC');
  }

  Future<void> tambahStok(
    int produkId,
    int qty, {
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'produk',
        columns: ['stok'],
        where: 'id = ?',
        whereArgs: [produkId],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw Exception('Produk tidak ditemukan');
      }

      final currentStok = (rows.first['stok'] as int?) ?? 0;
      final newStok = currentStok + qty;

      await txn.update(
        'produk',
        {'stok': newStok},
        where: 'id = ?',
        whereArgs: [produkId],
      );

      await txn.insert('stok_log', {
        'produk_id': produkId,
        'qty': qty,
        'tipe': 'MASUK',
        'catatan': catatan.isEmpty ? 'tambah stok manual' : catatan,
        'tanggal': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }
}