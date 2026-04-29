import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'kasir.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE produk(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT,
          harga INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE transaksi(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tanggal INTEGER,
          total INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE detail(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaksi_id INTEGER,
          produk_id INTEGER,
          qty INTEGER,
          harga INTEGER
        )
        ''');
      },
    );
  }
}