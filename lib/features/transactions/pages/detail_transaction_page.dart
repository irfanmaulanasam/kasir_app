import 'package:flutter/material.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';
import 'package:kasir_app/core/widgets/info_row.dart';
import '../../../data/local/transaksi_repo.dart';

class DetailTransaksiPage extends StatefulWidget {
  final int transaksiId;

  const DetailTransaksiPage({
    super.key,
    required this.transaksiId,
  });

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  final TransaksiRepo repo = TransaksiRepo();

  Future<Map<String, dynamic>?>? transaksiData;
  Future<List<Map<String, dynamic>>>? detailList;

  @override
  void initState() {
    super.initState();
    transaksiData = repo.getTransaksiById(widget.transaksiId);
    detailList = repo.getDetailTransaksi(widget.transaksiId);
  }

  int hitungTotal(List<Map<String, dynamic>> data) {
    int total = 0;

    for (final item in data) {
      total += (item['harga'] as int) * (item['qty'] as int);
    }

    return total;
  }

  Widget buildTransactionInfo(Map<String, dynamic>? transaksi) {
    if (transaksi == null) {
      return const SizedBox.shrink();
    }

    final metodeBayar = transaksi['metode_bayar']?.toString() ?? '-';
    final total = transaksi['total'] as int? ?? 0;
    final nomor = transaksi['nomor_transaksi']?.toString() ??
        'Transaksi #${widget.transaksiId}';

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nomor,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            
            InfoRow(
              label: 'Metode Bayar',
              value: metodeBayar,
            ),
            const SizedBox(height: 8),
            InfoRow(
              label: 'Total',
              value: CurrencyFormatter.format(total),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItemList(List<Map<String, dynamic>> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        final harga = item['harga'] as int? ?? 0;
        final qty = item['qty'] as int? ?? 0;
        final subtotal = harga * qty;

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: ListTile(
            title: Text(
              item['nama'].toString(),
            ),
            subtitle: Text(
              '${CurrencyFormatter.format(harga)} x $qty',
            ),
            trailing: Text(
              CurrencyFormatter.format(subtotal),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi #${widget.transaksiId}'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: detailList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(
                child: Text('Tidak ada detail transaksi'),
              );
            }

            return Column(
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: transaksiData,
                  builder: (context, transaksiSnapshot) {
                    return buildTransactionInfo(
                      transaksiSnapshot.data,
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daftar Barang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: buildItemList(data),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: Text(
                    'TOTAL: ${CurrencyFormatter.format(hitungTotal(data))}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}