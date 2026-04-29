class Produk {
  int? id;
  String nama;
  int harga;

  Produk({this.id, required this.nama, required this.harga});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
    };
  }
}