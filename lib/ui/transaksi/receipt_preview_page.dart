import 'package:flutter/material.dart';

class ReceiptPreviewPage extends StatelessWidget {

  final Map transaksi;
  final List items;
  final Map? settings;

  const ReceiptPreviewPage({
    super.key,
    required this.transaksi,
    required this.items,
    required this.settings,
  });

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Preview Nota'),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(16),

          child: Container(

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              border: Border.all(),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Center(
                  child: Text(
                    settings?['nama_toko'] ??
                        'TOKO',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    settings?['alamat'] ?? '',
                    textAlign: TextAlign.center,
                  ),
                ),

                Center(
                  child: Text(
                    settings?['telepon'] ?? '',
                  ),
                ),

                const Divider(height: 30),

                ...items.map((item) {

                  final subtotal =
                      item['qty'] * item['harga'];

                  return Padding(

                    padding:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          item['nama']?.toString() ??
                              'produk',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [

                            Text(
                              '${item['qty']} x ${rupiah(item['harga'])}',
                            ),

                            Text(
                              rupiah(subtotal),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      rupiah(
                        transaksi['total'],
                      ),
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    settings?['footer'] ??
                        'Terima kasih',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () {

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur print belum aktif',
                  ),
                ),
              );
            },

            icon: const Icon(Icons.print),

            label: const Text('Print Nota'),
          ),
        ),
      ),
    );
  }
}