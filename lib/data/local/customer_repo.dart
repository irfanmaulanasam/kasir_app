import '../../core/db/db_helper.dart';
import '../models/customer.dart';

class CustomerRepo {
  final DBHelper dbHelper = DBHelper();

  Future<int> insert(Customer customer) async {
    final db = await dbHelper.db;

    return db.insert(
      'customers',
      customer.toMap(),
    );
  }

  Future<List<Customer>> getAll() async {
    final db = await dbHelper.db;

    final result = await db.query(
      'customers',
      orderBy: 'nama ASC',
    );

    return result
        .map((e) => Customer.fromMap(e))
        .toList();
  }

  Future<List<Customer>> search(
    String keyword,
  ) async {
    final db = await dbHelper.db;

    final result = await db.query(
      'customers',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'nama ASC',
    );

    return result
        .map((e) => Customer.fromMap(e))
        .toList();
  }
  Future<Customer?> findByName(String nama) async {
    final db = await dbHelper.db;

    final result = await db.query(
      'customers',
      where: 'LOWER(nama) = ?',
      whereArgs: [nama.toLowerCase()],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Customer.fromMap(result.first);
  }
}