import 'package:flutter/material.dart';

import '../../core/db/db_helper.dart';

class SupplierDebtRepo {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertDebt({
    required int supplierId,
    required int total,
    int dibayar = 0,
    String catatan = '',
  }) async {
    final db = await _dbHelper.db;

    final sisa = total - dibayar;

    return db.insert('supplier_debts', {
      'supplier_id': supplierId,
      'total': total,
      'dibayar': dibayar,
      'sisa': sisa < 0 ? 0 : sisa,
      'status': sisa <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
      'catatan': catatan,
      'tanggal': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getSupplierSummary() async {
    final db = await _dbHelper.db;

    return db.rawQuery('''
      SELECT
        s.id AS supplier_id,
        s.nama AS nama,
        s.no_hp AS no_hp,
        COUNT(d.id) AS jumlah_hutang,
        COALESCE(SUM(d.total), 0) AS total_hutang,
        COALESCE(SUM(d.dibayar), 0) AS total_bayar,
        COALESCE(SUM(d.sisa), 0) AS sisa_hutang
      FROM supplier_debts d
      LEFT JOIN suppliers s ON s.id = d.supplier_id
      GROUP BY s.id
      HAVING sisa_hutang > 0
      ORDER BY s.nama ASC
    ''');
  }

  Future<Map<String, dynamic>> getSupplierDebtDetail(int supplierId) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery('''
      SELECT
        s.id,
        s.nama,
        s.no_hp,
        COALESCE(SUM(d.total), 0) AS total_hutang,
        COALESCE(SUM(d.dibayar), 0) AS total_bayar,
        COALESCE(SUM(d.sisa), 0) AS sisa_hutang
      FROM suppliers s
      LEFT JOIN supplier_debts d ON d.supplier_id = s.id
      WHERE s.id = ?
      GROUP BY s.id
    ''', [supplierId]);

    if (result.isEmpty) {
      throw Exception('Supplier tidak ditemukan');
    }

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getSupplierDebtList(int supplierId) async {
    final db = await _dbHelper.db;

    return db.query(
      'supplier_debts',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'tanggal DESC',
    );
  }

  Future<void> paySupplierDebt({
    required int supplierId,
    required int nominal,
  }) async {
    final db = await _dbHelper.db;

    await db.transaction((txn) async {
      int sisaBayar = nominal;

      final rows = await txn.query(
        'supplier_debts',
        where: 'supplier_id = ? AND status = ?',
        whereArgs: [supplierId, 'BELUM_LUNAS'],
        orderBy: 'tanggal ASC',
      );

      if (rows.isEmpty) {
        throw Exception('Tidak ada hutang supplier yang belum lunas');
      }

      for (final row in rows) {
        if (sisaBayar <= 0) break;

        final id = row['id'] as int;
        final dibayarLama = row['dibayar'] as int? ?? 0;
        final sisaLama = row['sisa'] as int? ?? 0;

        final bayarUntukHutang =
            sisaBayar >= sisaLama ? sisaLama : sisaBayar;

        final dibayarBaru = dibayarLama + bayarUntukHutang;
        final sisaBaru = sisaLama - bayarUntukHutang;

        await txn.update(
          'supplier_debts',
          {
            'dibayar': dibayarBaru,
            'sisa': sisaBaru,
            'status': sisaBaru <= 0 ? 'LUNAS' : 'BELUM_LUNAS',
          },
          where: 'id = ?',
          whereArgs: [id],
        );

        sisaBayar -= bayarUntukHutang;
      }

      await txn.insert('supplier_debt_payments', {
        'supplier_id': supplierId,
        'nominal': nominal,
        'catatan': 'Pembayaran hutang supplier',
        'tanggal': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<List<Map<String, dynamic>>> getSupplierPaymentList(
    int supplierId,
  ) async {
    final db = await _dbHelper.db;

    return db.query(
      'supplier_debt_payments',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'tanggal DESC',
    );
  }

  Future<void> debugSupplierDebt() async {
    final db = await _dbHelper.db;

    final debts = await db.rawQuery('SELECT * FROM supplier_debts');
    final payments = await db.rawQuery('SELECT * FROM supplier_debt_payments');

    debugPrint('SUPPLIER DEBTS: $debts');
    debugPrint('SUPPLIER PAYMENTS: $payments');
  }
 
  Future<List<Map<String, dynamic>>> getSupplierSummaryAll() async {
    final db = await _dbHelper.db;

    return db.rawQuery('''
      SELECT
        s.id AS supplier_id,
        s.nama AS nama,
        s.no_hp AS no_hp,
        COUNT(d.id) AS jumlah_hutang,
        COALESCE(SUM(d.total), 0) AS total_hutang,
        COALESCE(SUM(d.dibayar), 0) AS total_bayar,
        COALESCE(SUM(d.sisa), 0) AS sisa_hutang
      FROM suppliers s
      LEFT JOIN supplier_debts d ON d.supplier_id = s.id
      GROUP BY s.id
      ORDER BY s.nama ASC
    ''');
  }
}