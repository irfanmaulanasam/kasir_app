import '../../core/db/db_helper.dart';

class ProdukRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _dbHelper.db;

    return db.transaction<int>((txn) async {
      final int stokAwal = (data['stok'] ?? 0) as int;

      final id = await txn.insert('produk', {
        'nama': data['nama'],
        'harga': data['harga'],
        'harga_beli': data['harga_beli'],
        'stok': stokAwal,
        'satuan_dasar': data['satuan_dasar'] ?? 'pcs',
        'minimum_stok': data['minimum_stok'],
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
    return db.query('produk', orderBy: 'nama ASC');
  }

  Future<void> updateMinimumStock(
    int produkId,
    int minimumStock,
  ) async {
    final db = await _dbHelper.db;

    await db.update(
      'produk',
      {
        'minimum_stok': minimumStock,
      },
      where: 'id = ?',
      whereArgs: [produkId],
    );
  }

  Future<void> tambahStok(int produkId, int qty, {String catatan = ''}) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'produk',
        columns: ['stok'],
        where: 'id = ?',
        whereArgs: [produkId],
        limit: 1,
      );

      if (rows.isEmpty) throw Exception('Produk tidak ditemukan');

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

  Future<void> kurangiStokManual(int produkId, int qty, {String catatan = ''}) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'produk',
        columns: ['stok'],
        where: 'id = ?',
        whereArgs: [produkId],
        limit: 1,
      );

      if (rows.isEmpty) throw Exception('Produk tidak ditemukan');

      final currentStok = (rows.first['stok'] as int?) ?? 0;
      if (currentStok < qty) {
        throw Exception('Stok tidak cukup. Sisa: $currentStok');
      }

      final newStok = currentStok - qty;

      await txn.update(
        'produk',
        {'stok': newStok},
        where: 'id = ?',
        whereArgs: [produkId],
      );

      await txn.insert('stok_log', {
        'produk_id': produkId,
        'qty': qty,
        'tipe': 'KELUAR',
        'catatan': catatan.isEmpty ? 'kurangi stok manual' : catatan,
        'tanggal': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<List<Map<String, dynamic>>> getStockLog(int produkId) async {
    final db = await _dbHelper.db;
    return db.query(
      'stok_log',
      where: 'produk_id = ?',
      whereArgs: [produkId],
      orderBy: 'tanggal DESC',
    );
  }
  Future<Map<String, dynamic>?> getStockLogById(int id) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery('''
      SELECT
        s.id,
        s.produk_id,
        p.nama AS nama_produk,
        s.qty,
        s.tipe,
        s.catatan,
        s.tanggal
      FROM stok_log s
      LEFT JOIN produk p ON p.id = s.produk_id
      WHERE s.id = ?
      LIMIT 1
    ''', [id]);

    if (result.isEmpty) return null;

    return result.first;
  }
}