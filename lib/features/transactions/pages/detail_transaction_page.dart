import 'package:flutter/material.dart';
import 'package:kasir_app/core/formatters/currency_formatter.dart';
import '../../../data/local/transaksi_repo.dart';

class DetailTransaksiPage extends StatefulWidget {

  final int transaksiId;

  const DetailTransaksiPage({
    super.key,
    required this.transaksiId,
  });

  @override
  State<DetailTransaksiPage> createState() =>
      _DetailTransaksiPageState();
}

class _DetailTransaksiPageState
    extends State<DetailTransaksiPage> {

  final TransaksiRepo repo = TransaksiRepo();

  Future<List<Map<String, dynamic>>>? detailList;

  @override
  void initState() {
    super.initState();

    detailList =
        repo.getDetailTransaksi(widget.transaksiId);
  }

  int hitungTotal(List<Map<String, dynamic>> data) {

    int total = 0;

    for (var item in data) {
      total +=
          (item['harga'] as int) *
          (item['qty'] as int);
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Transaksi #${widget.transaksiId}',
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: detailList,

          builder: (context, snapshot) {

            if (snapshot.connectionState ==
                ConnectionState.waiting) {

              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {

              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {

              return const Center(
                child: Text(
                  'Tidak ada detail transaksi',
                ),
              );
            }

            return Column(
              children: [

                Expanded(
                  child: ListView.builder(

                    itemCount: data.length,

                    itemBuilder: (context, index) {

                      final item = data[index];

                      final subtotal =
                          (item['harga'] as int) *
                          (item['qty'] as int);

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        child: ListTile(

                          title: Text(
                            item['nama'].toString(),
                          ),

                          subtitle: Text(
                            '${CurrencyFormatter.format(item['harga'])} x ${item['qty']}',
                          ),

                          trailing: Text(
                            CurrencyFormatter.format(subtotal),
                          ),
                        ),
                      );
                    },
                  ),
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