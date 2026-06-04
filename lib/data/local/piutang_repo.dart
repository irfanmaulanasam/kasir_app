import 'package:flutter/material.dart';
import '../../core/db/db_helper.dart';

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
    try {
      final db = await _dbHelper.db;
      final sisa = total - dibayar;

      return await db.insert('piutang', {
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
    } catch (e) {
      debugPrint('Error inserting piutang: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await _dbHelper.db;
      return await db.query(
        'piutang',
        orderBy: 'tanggal DESC',
      );
    } catch (e) {
      debugPrint('Error getting all piutang: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBelumLunas() async {
    try {
      final db = await _dbHelper.db;
      return await db.query(
        'piutang',
        where: 'status = ?',
        whereArgs: ['BELUM_LUNAS'],
        orderBy: 'tanggal DESC',
      );
    } catch (e) {
      debugPrint('Error getting belum lunas: $e');
      return [];
    }
  }

  Future<void> bayarPiutang({
    required int id,
    required int nominal,
  }) async {
    try {
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
    } catch (e) {
      debugPrint('Error bayar piutang: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPiutangWithCustomer() async {
    try {
      final db = await _dbHelper.db;
      return await db.rawQuery('''
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
    } catch (e) {
      debugPrint('Error getting piutang with customer: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerSummary() async {
    try {
      debugPrint('getCustomerSummary: starting');
      final db = await _dbHelper.db.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('getCustomerSummary: database timeout');
          throw Exception('Database timeout');
        },
      );

      debugPrint('getCustomerSummary: db obtained, running query');

      final result = await db.rawQuery('''
        SELECT
          p.customer_id,
          COALESCE(c.nama, p.nama_pelanggan, 'Pelanggan') AS nama,
          COALESCE(c.no_hp, '') AS no_hp,
          COUNT(p.id) AS jumlah_bon,
          COALESCE(SUM(p.total), 0) AS total_hutang,
          COALESCE(SUM(p.dibayar), 0) AS total_bayar,
          (COALESCE(SUM(p.total), 0) - COALESCE(SUM(p.dibayar), 0)) AS sisa_hutang
        FROM piutang p
        LEFT JOIN customers c ON c.id = p.customer_id
        GROUP BY p.customer_id, p.nama_pelanggan
        HAVING (COALESCE(SUM(p.total), 0) - COALESCE(SUM(p.dibayar), 0)) > 0
        ORDER BY nama ASC
      ''');
      debugPrint('================awal debug repo===================');
      debugPrint('getCustomerSummary: result count = ${result.length}');
      debugPrint('================akhir debug repo===================');
      return result;
    } catch (e, stackTrace) {
      debugPrint('Error getting customer summary: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> getCustomerDebtDetail(int customerId) async {
    try {
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

      if (result.isEmpty) {
        throw Exception('Customer dengan ID $customerId tidak ditemukan');
      }

      return result.first;
    } catch (e) {
      debugPrint('Error getting customer debt detail: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCustomerPiutangList(int customerId) async {
    try {
      final db = await _dbHelper.db;
      return await db.query(
        'piutang',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'tanggal DESC',
      );
    } catch (e) {
      debugPrint('Error getting customer piutang list: $e');
      return [];
    }
  }

  Future<void> debugPiutang() async {
    try {
      final db = await _dbHelper.db;
      final rows = await db.rawQuery('SELECT * FROM piutang');
      debugPrint('PIUTANG ROWS: $rows');

      final customers = await db.rawQuery('SELECT * FROM customers');
      debugPrint('CUSTOMER ROWS: $customers');
    } catch (e) {
      debugPrint('Error debugging piutang: $e');
    }
  }

 Future<void> bayarCustomerPiutang({
    required int customerId,
    required int nominal,
  }) async {
    try {
      final db = await _dbHelper.db;

      await db.transaction((txn) async {
        int sisaBayar = nominal;

        final rows = await txn.query(
          'piutang',
          where: 'customer_id = ? AND status = ?',
          whereArgs: [customerId, 'BELUM_LUNAS'],
          orderBy: 'tanggal ASC',
        );

        if (rows.isEmpty) {
          throw Exception(
            'Tidak ada piutang yang belum lunas untuk customer ini',
          );
        }

        for (final row in rows) {
          if (sisaBayar <= 0) break;

          final id = row['id'] as int;
          final dibayarLama = row['dibayar'] as int? ?? 0;
          final sisaLama = row['sisa'] as int? ?? 0;

          final bayarUntukBon =
              sisaBayar >= sisaLama ? sisaLama : sisaBayar;

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

        await txn.insert('piutang_payments', {
          'customer_id': customerId,
          'nominal': nominal,
          'catatan': 'Pembayaran piutang',
          'tanggal': DateTime.now().millisecondsSinceEpoch,
        });
      });
    } catch (e) {
      debugPrint('Error bayar customer piutang: $e');
      rethrow;
    }
  }
}