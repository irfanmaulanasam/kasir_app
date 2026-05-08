import 'package:flutter/material.dart';
import '../../data/local/transaksi_repo.dart';
import '../transaksi/detail_transaksi_page.dart';
class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {

  final TransaksiRepo repo = TransaksiRepo();

  Future<List<Map<String, dynamic>>>? transaksiList;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    setState(() {
      transaksiList = repo.getTransaksi();
    });
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),

      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: transaksiList,

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
                child: Text('Belum ada transaksi'),
              );
            }

            return ListView.builder(
              itemCount: data.length,

              itemBuilder: (context, index) {

                final trx = data[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailTransaksiPage(
                            transaksiId: trx['id'],
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      child: Text(
                        trx['id'].toString(),
                      ),
                    ),

                    title: Text(
                      formatRupiah(trx['total']),
                    ),

                    subtitle: Text(
                      DateTime.fromMillisecondsSinceEpoch(
                        trx['tanggal'],
                      ).toString(),
                    ),

                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}