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
        await txn.insert('detail', {
          'transaksi_id': transaksiId,
          'produk_id': item['id'],
          'qty': item['qty'],
          'harga': item['harga'],
        });
      }

      return transaksiId;
    });
  }
}