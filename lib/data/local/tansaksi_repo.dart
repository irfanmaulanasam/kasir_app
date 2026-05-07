import '../../core/db/db_helper.dart';

class TransaksiRepo {
  Future<int> insertTransaksi(int total) async {
    final db = await DBHelper().db;

    return await db.insert("transaksi", {
      "tanggal": DateTime.now().millisecondsSinceEpoch,
      "total": total,
    });
  }

  Future<void> insertDetail(
      int transaksiId, int produkId, int qty, int harga) async {
    final db = await DBHelper().db;

    await db.insert("detail", {
      "transaksi_id": transaksiId,
      "produk_id": produkId,
      "qty": qty,
      "harga": harga,
    });
  }
}