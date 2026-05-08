import '../../core/db/db_helper.dart';

class TransaksiRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> simpanTransaksi(List<Map<String, dynamic>> cartItems) async {
    if (cartItems.isEmpty) {
      throw Exception('Cart kosong');
    }

    final db = await _dbHelper.db;

    final int total = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['harga'] as int) * (item['qty'] as int),
    );

    return await db.transaction<int>((txn) async {
      final transaksiId = await txn.insert('transaksi', {
        'tanggal': DateTime.now().millisecondsSinceEpoch,
        'total': total,
      });

      for (final item in cartItems) {
        final int produkId = item['id'] as int;
        final int qty = item['qty'] as int;
        final int harga = item['harga'] as int;

        final rows = await txn.query(
          'produk',
          columns: ['stok'],
          where: 'id = ?',
          whereArgs: [produkId],
          limit: 1,
        );

        if (rows.isEmpty) {
          throw Exception('Produk ${item['nama']} tidak ditemukan');
        }

        final currentStok = (rows.first['stok'] as int?) ?? 0;

        if (currentStok < qty) {
          throw Exception('Stok ${item['nama']} tidak cukup. Sisa: $currentStok');
        }

        await txn.insert('detail', {
          'transaksi_id': transaksiId,
          'produk_id': produkId,
          'qty': qty,
          'harga': harga,
        });

        await txn.update(
          'produk',
          {'stok': currentStok - qty},
          where: 'id = ?',
          whereArgs: [produkId],
        );

        await txn.insert('stok_log', {
          'produk_id': produkId,
          'qty': qty,
          'tipe': 'KELUAR',
          'catatan': 'transaksi #$transaksiId',
          'tanggal': DateTime.now().millisecondsSinceEpoch,
        });
      }

      return transaksiId;
    });
  }

  Future<List<Map<String, dynamic>>> getTransaksi() async {
    final db = await _dbHelper.db;
    return await db.query('transaksi', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getDetailTransaksi(int transaksiId) async {
    final db = await _dbHelper.db;

    return await db.rawQuery('''
      SELECT
        detail.id,
        detail.qty,
        detail.harga,
        produk.nama
      FROM detail
      JOIN produk ON produk.id = detail.produk_id
      WHERE detail.transaksi_id = ?
    ''', [transaksiId]);
  }
}

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  } 
  
// import '../../core/db/db_helper.dart';

// class TransaksiRepo {
//   final DBHelper _dbHelper = DBHelper();

//   Future<int> simpanTransaksi(List<Map<String, dynamic>> cartItems) async {
//     if (cartItems.isEmpty) {
//       throw Exception('Cart kosong');
//     }

//     final db = await _dbHelper.db;

//     final int total = cartItems.fold<int>(
//       0,
//       (sum, item) => sum + (item['harga'] as int) * (item['qty'] as int),
//     );

//     return await db.transaction<int>((txn) async {
//       final transaksiId = await txn.insert('transaksi', {
//         'tanggal': DateTime.now().millisecondsSinceEpoch,
//         'total': total,
//       });

//       for (final item in cartItems) {
//         await txn.insert('detail', {
//           'transaksi_id': transaksiId,
//           'produk_id': item['id'],
//           'qty': item['qty'],
//           'harga': item['harga'],
//         });
//       }

//       return transaksiId;
//     });
//   }
//   Future<List<Map<String, dynamic>>> getTransaksi() async {

//     final db = await _dbHelper.db;

//     return await db.query(
//       'transaksi',
//       orderBy: 'id DESC',
//     );
//   }
//   Future<List<Map<String, dynamic>>> getDetailTransaksi(
//       int transaksiId) async {

//     final db = await _dbHelper.db;

//     return await db.rawQuery('''
//       SELECT
//         detail.id,
//         detail.qty,
//         detail.harga,
//         produk.nama
//       FROM detail
//       JOIN produk
//         ON produk.id = detail.produk_id
//       WHERE detail.transaksi_id = ?
//     ''', [transaksiId]);
//   }
// }