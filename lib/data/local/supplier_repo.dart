import '../models/supplier.dart';
import '../../core/db/db_helper.dart';

class SupplierRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert(
    Supplier supplier,
  ) async {
    final db = await _dbHelper.db;

    return db.insert(
      'suppliers',
      supplier.toMap(),
    );
  }

  Future<List<Supplier>> getAll() async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'suppliers',
      orderBy: 'nama ASC',
    );

    return result
        .map((e) => Supplier.fromMap(e))
        .toList();
  }

  Future<Supplier?> findByName(
    String nama,
  ) async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'suppliers',
      where: 'nama = ?',
      whereArgs: [nama],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return Supplier.fromMap(
      result.first,
    );
  }
}