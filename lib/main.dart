import 'package:flutter/material.dart';
import 'data/local/produk_repo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ProdukPage());
  }
}

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();

  final repo = ProdukRepo();

  void simpan() async {
    await repo.insert({
      "nama": namaController.text,
      "harga": int.parse(hargaController.text),
    });

    namaController.clear();
    hargaController.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Tersimpan")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Produk")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: namaController, decoration: InputDecoration(labelText: "Nama")),
            TextField(controller: hargaController, decoration: InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(onPressed: simpan, child: Text("Simpan"))
          ],
        ),
      ),
    );
  }
}