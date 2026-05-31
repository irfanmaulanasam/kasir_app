import 'package:flutter/material.dart';

import '../../core/db/db_helper.dart';
// import '../models/customer.dart';

class PiutangRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insert({
    required int transaksiId,
    required int customerId,
    required String namaPelanggan,
    required int total,
    required int dibayar,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;
    final sisa = total - dibayar;

    return db.insert('piutang', {
      'transaksi_id': transaksiId,
      'customer_id': customerId,
      'nama_pelanggan': namaPelanggan,
      'total': total,
      'dibayar': dibayar,
      'sisa': sisa,
      'status': sisa <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
      'catatan': catatan,
      'tanggal': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.db;

    return db.query(
      'piutang',
      orderBy: 'tanggal DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getBelumLunas() async {
    final db = await _dbHelper.db;

    return db.query(
      'piutang',
      where: 'status = ?',
      whereArgs: ['BELUM_LUNAS'],
      orderBy: 'tanggal DESC',
    );
  }

  Future<void> bayarPiutang({
    required int id,
    required int nominal,
  }) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      final rows = await txn.query(
        'piutang',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw Exception('Piutang tidak ditemukan');
      }

      final current = rows.first;
      final dibayarLama = current['dibayar'] as int? ?? 0;
      final sisaLama = current['sisa'] as int? ?? 0;

      final dibayarBaru = dibayarLama + nominal;
      final sisaBaru = sisaLama - nominal;

      await txn.update(
        'piutang',
        {
          'dibayar': dibayarBaru,
          'sisa': sisaBaru < 0 ? 0 : sisaBaru,
          'status': sisaBaru <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
  Future<List<Map<String, dynamic>>> getPiutangWithCustomer() async {
    final db = await _dbHelper.db;

    return db.rawQuery('''
      SELECT
        p.id,
        p.customer_id,
        p.transaksi_id,
        c.nama AS nama_pelanggan,
        c.no_hp,
        p.total,
        p.dibayar,
        p.sisa,
        p.status,
        p.catatan,
        p.tanggal
      FROM piutang p
      LEFT JOIN customers c ON c.id = p.customer_id
      ORDER BY p.tanggal DESC
    ''');
  }
  Future<List<Map<String, dynamic>>> getCustomerDebtSummary() async {
    final db = await _dbHelper.db;
    return db.rawQuery('''
        SELECT
        COALESCE(c.id, p.customer_id) AS customer_id,
        COALESCE(c.nama, p.nama_pelanggan, 'Pelanggan') AS nama,
        COALESCE(c.no_hp, '') AS no_hp,
        COUNT(p.id) AS jumlah_bon,
        COALESCE(SUM(p.total), 0) AS total_hutang,
        COALESCE(SUM(p.dibayar), 0) AS total_bayar,
        COALESCE(SUM(p.sisa), 0) AS sisa_hutang
      FROM piutang p
      LEFT JOIN customers c ON c.id = p.customer_id
      GROUP BY COALESCE(c.id, p.customer_id, p.nama_pelanggan)
      HAVING sisa_hutang > 0
      ORDER BY nama ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getCustomerSummary() async {
    final db = await _dbHelper.db;

    return db.rawQuery('''
      SELECT
        c.id AS customer_id,
        c.nama AS nama,
        c.no_hp AS no_hp,
        COUNT(p.id) AS jumlah_bon,
        COALESCE(SUM(p.total), 0) AS total_hutang,
        COALESCE(SUM(p.dibayar), 0) AS total_bayar,
        COALESCE(SUM(p.sisa), 0) AS sisa_hutang
      FROM piutang p
      JOIN customers c ON c.id = p.customer_id
      GROUP BY c.id
      HAVING sisa_hutang > 0
      ORDER BY c.nama ASC
    ''');
  }

  Future<Map<String, dynamic>> getCustomerDebtDetail(int customerId) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery('''
      SELECT
        c.id,
        c.nama,
        c.no_hp,
        COALESCE(SUM(p.total), 0) as total_hutang,
        COALESCE(SUM(p.dibayar), 0) as total_bayar,
        COALESCE(SUM(p.sisa), 0) as sisa_hutang
      FROM customers c
      LEFT JOIN piutang p ON p.customer_id = c.id
      WHERE c.id = ?
      GROUP BY c.id
    ''', [customerId]);

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getCustomerPiutangList(int customerId) async {
    final db = await _dbHelper.db;

    return db.query(
      'piutang',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'tanggal DESC',
    );
  }
  Future<void> debugPiutang() async {
    final db = await _dbHelper.db;

    final rows = await db.rawQuery('SELECT * FROM piutang');
    debugPrint('PIUTANG ROWS: $rows');

    final customers = await db.rawQuery('SELECT * FROM customers');
    debugPrint('CUSTOMER ROWS: $customers');
  }

  Future<void> bayarCustomerPiutang({
  required int customerId,
  required int nominal,
}) async {
  final db = await _dbHelper.db;

  await db.transaction((txn) async {
    int sisaBayar = nominal;

    final rows = await txn.query(
      'piutang',
      where: 'customer_id = ? AND status = ?',
      whereArgs: [customerId, 'BELUM_LUNAS'],
      orderBy: 'tanggal ASC',
    );

    for (final row in rows) {
      if (sisaBayar <= 0) break;

      final id = row['id'] as int;
      final dibayarLama = row['dibayar'] as int? ?? 0;
      final sisaLama = row['sisa'] as int? ?? 0;

      final bayarUntukBon = sisaBayar >= sisaLama ? sisaLama : sisaBayar;

      final dibayarBaru = dibayarLama + bayarUntukBon;
      final sisaBaru = sisaLama - bayarUntukBon;

      await txn.update(
        'piutang',
        {
          'dibayar': dibayarBaru,
          'sisa': sisaBaru,
          'status': sisaBaru <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      sisaBayar -= bayarUntukBon;
    }
  });
}
}