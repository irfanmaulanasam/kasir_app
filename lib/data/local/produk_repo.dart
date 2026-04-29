import '../../core/db/db_helper.dart';

class ProdukRepo {
  Future<int> insert(Map<String, dynamic> data) async {
    final db = await DBHelper().db;
    return await db.insert("produk", data);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await DBHelper().db;
    return await db.query("produk");
  }
}