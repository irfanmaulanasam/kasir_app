import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const int _databaseVersion = 1; // Dimulai dari version 1

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = join(await getDatabasesPath(), 'kasir.db');

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Create all tables
    await db.execute('''
      CREATE TABLE produk(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        harga INTEGER NOT NULL CHECK(harga >= 0),
        harga_beli INTEGER NOT NULL DEFAULT 0 CHECK(harga_beli >= 0),
        stok INTEGER NOT NULL DEFAULT 0 CHECK(stok >= 0),
        satuan_dasar TEXT NOT NULL DEFAULT 'pcs',
        minimum_stok INTEGER NOT NULL DEFAULT 0 CHECK(minimum_stok >= 0)
      )
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE,
        no_hp TEXT DEFAULT '',
        catatan TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_transaksi TEXT UNIQUE,
        tanggal INTEGER NOT NULL,
        total INTEGER NOT NULL DEFAULT 0 CHECK(total >= 0),
        metode_bayar TEXT DEFAULT 'Cash',
        customer_id INTEGER,
        FOREIGN KEY(customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE detail(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaksi_id INTEGER NOT NULL,
        produk_id INTEGER NOT NULL,
        qty INTEGER NOT NULL CHECK(qty > 0),
        harga INTEGER NOT NULL CHECK(harga >= 0),
        subtotal INTEGER NOT NULL CHECK(subtotal >= 0),
        FOREIGN KEY(transaksi_id) REFERENCES transaksi(id) ON DELETE CASCADE,
        FOREIGN KEY(produk_id) REFERENCES produk(id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE piutang(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        transaksi_id INTEGER NOT NULL UNIQUE,
        nama_pelanggan TEXT NOT NULL,
        total INTEGER NOT NULL CHECK(total >= 0),
        dibayar INTEGER NOT NULL DEFAULT 0 CHECK(dibayar >= 0),
        sisa INTEGER NOT NULL CHECK(sisa >= 0),
        status TEXT NOT NULL CHECK(status IN ('LUNAS', 'BELUM_LUNAS', 'JATUH_TEMPO')),
        catatan TEXT,
        tanggal INTEGER NOT NULL,
        jatuh_tempo INTEGER,
        FOREIGN KEY(customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
        FOREIGN KEY(transaksi_id) REFERENCES transaksi(id) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE piutang_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        nominal INTEGER,
        catatan TEXT,
        tanggal INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE stok_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produk_id INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        tipe TEXT NOT NULL CHECK(tipe IN ('MASUK', 'KELUAR', 'ADJUSTMENT')),
        catatan TEXT,
        tanggal INTEGER NOT NULL,
        user_id TEXT DEFAULT 'system',
        FOREIGN KEY(produk_id) REFERENCES produk(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pengeluaran(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kategori TEXT NOT NULL,
        nominal INTEGER NOT NULL CHECK(nominal > 0),
        catatan TEXT,
        tanggal INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        id PRIMARY KEY CHECK(id = 1),
        nama_toko TEXT,
        alamat TEXT,
        telepon TEXT,
        footer TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cash_sessions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tanggal INTEGER NOT NULL,
      kas_awal INTEGER NOT NULL DEFAULT 0,
      catatan TEXT
      )'''
    );
    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE,
        no_hp TEXT DEFAULT '',
        catatan TEXT DEFAULT ''
      )'''
    );
    await db.execute('''
      CREATE TABLE supplier_debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        total INTEGER NOT NULL,
        dibayar INTEGER NOT NULL DEFAULT 0,
        sisa INTEGER NOT NULL,
        status TEXT NOT NULL,
        catatan TEXT,
        tanggal INTEGER NOT NULL,
        FOREIGN KEY(supplier_id)
          REFERENCES suppliers(id)
          ON DELETE RESTRICT
      )'''
    );
    await db.execute('''
      CREATE TABLE supplier_debt_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER,
        nominal INTEGER,
        catatan TEXT,
        tanggal INTEGER
      )'''
    );
    await db.insert('settings', {
      'id': 1,
      'nama_toko': '',
      'alamat': '',
      'telepon': '',
      'footer': 'Terima kasih telah berbelanja',
    });

    // Create indexes for performance
    await _createIndexes(db);


  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_produk_nama ON produk(nama)');
    await db.execute('CREATE INDEX idx_produk_stok ON produk(stok)');
    await db.execute('CREATE INDEX idx_transaksi_tanggal ON transaksi(tanggal)');
    await db.execute('CREATE INDEX idx_transaksi_customer ON transaksi(customer_id)');
    await db.execute('CREATE INDEX idx_detail_transaksi ON detail(transaksi_id)');
    await db.execute('CREATE INDEX idx_detail_produk ON detail(produk_id)');
    await db.execute('CREATE INDEX idx_piutang_customer ON piutang(customer_id)');
    await db.execute('CREATE INDEX idx_piutang_status ON piutang(status)');
    await db.execute('CREATE INDEX idx_piutang_tanggal ON piutang(tanggal)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_piutang_customer_id ON piutang(customer_id)',);
    await db.execute('CREATE INDEX IF NOT EXISTS idx_piutang_status ON piutang(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_piutang_tanggal ON piutang(tanggal)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_piutang_payments_customer_id ON piutang_payments(customer_id)');
    await db.execute('CREATE INDEX idx_stok_log_produk ON stok_log(produk_id)');
    await db.execute('CREATE INDEX idx_pengeluaran_tanggal ON pengeluaran(tanggal)');
    await db.execute('CREATE INDEX idx_customers_nama ON customers(nama)');
    await db.execute('CREATE INDEX idx_transaksi_nomor ON transaksi(nomor_transaksi)');
    await db.execute('CREATE INDEX idx_piutang_jatuh_tempo ON piutang(jatuh_tempo)');
    await db.execute('CREATE INDEX idx_cash_sessions_tanggal ON cash_sessions(tanggal)');
    await db.execute('CREATE INDEX idx_supplier_nama ON suppliers(nama)',);
    await db.execute('CREATE INDEX idx_supplier_debt_supplier ON supplier_debts(supplier_id)',);
    await db.execute('CREATE INDEX idx_supplier_payment_supplier ON supplier_debt_payments(supplier_id)',);
  }

  // _onUpgrade tidak diperlukan lagi karena version = 1
  // Jika di masa depan butuh migration, bisa ditambahkan kembali
  static Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  static void resetDatabase() {
    _db = null;
  }
}