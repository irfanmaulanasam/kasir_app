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
    final path = join(await getDatabasesPath(), 'kasir.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produk(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            harga INTEGER,
            harga_beli INTEGER DEFAULT 0,
            stok INTEGER DEFAULT 0,
            satuan_dasar TEXT DEFAULT 'pcs',
            minimum_stok INTEGER DEFAULT 0
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

        await db.execute('''
          CREATE TABLE stok_log(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            produk_id INTEGER,
            qty INTEGER,
            tipe TEXT,
            catatan TEXT,
            tanggal INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_toko TEXT,
            alamat TEXT,
            telepon TEXT,
            footer TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE produk ADD COLUMN stok INTEGER DEFAULT 0',
          );

          await db.execute('''
            CREATE TABLE IF NOT EXISTS stok_log(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              produk_id INTEGER,
              qty INTEGER,
              tipe TEXT,
              catatan TEXT,
              tanggal INTEGER
            )
          ''');
        }

        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE produk ADD COLUMN harga_beli INTEGER DEFAULT 0',
          );

          await db.execute(
            'ALTER TABLE produk ADD COLUMN minimum_stok INTEGER DEFAULT 0',
          );

          await db.execute('''
            CREATE TABLE IF NOT EXISTS settings(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_toko TEXT,
              alamat TEXT,
              telepon TEXT,
              footer TEXT
            )
          ''');
        }

        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE produk ADD COLUMN satuan_dasar TEXT DEFAULT 'pcs'",
          );
        }
      },
    );
  }
}