import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  // Fungsi format rupiah untuk PDF
  static String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  // Fungsi format tanggal untuk PDF
  static String formatTanggal(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(date);
  }

  static Future<void> printReceipt({
    required Map<String, dynamic> transaksi,
    required List items,
    required Map<String, dynamic> settings,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6, // Ukuran kertas struk/A6
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Nama Toko
              pw.Center(
                child: pw.Text(
                  settings['nama_toko'] ?? 'TOKO',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Alamat & Telepon
              pw.Center(
                child: pw.Text(settings['alamat'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Center(
                child: pw.Text(settings['telepon'] ?? '', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 5),
              // Tanggal Transaksi
              pw.Center(
                child: pw.Text(
                  formatTanggal(transaksi['tanggal']),
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ),
              pw.Divider(thickness: 1),

              // List Items Belanjaan
              ...items.map((item) {
                final subtotal = item['harga'] * item['qty'];
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item['nama'] ?? 'produk',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item['qty']} x ${rupiah(item['harga'])}', style: const pw.TextStyle(fontSize: 11)),
                          pw.Text(rupiah(subtotal), style: const pw.TextStyle(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 1),

              // Total Harga
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  pw.Text(rupiah(transaksi['total']), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
                ],
              ),
              pw.SizedBox(height: 10),

              // Rincian Pembayaran
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Metode', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(transaksi['metode_bayar'] ?? '-', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Bayar', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(rupiah(transaksi['bayar'] ?? 0), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Kembalian', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(rupiah(transaksi['kembalian'] ?? 0), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Footer Toko
              pw.Center(
                child: pw.Text(
                  settings['footer'] ?? 'Terima kasih',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 11),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    // Buka dialog printer / layout PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}