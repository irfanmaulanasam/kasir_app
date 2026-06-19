class Supplier {
  final int? id;
  final String nama;
  final String noHp;
  final String catatan;

  Supplier({
    this.id,
    required this.nama,
    this.noHp = '',
    this.catatan = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_hp': noHp,
      'catatan': catatan,
    };
  }

  factory Supplier.fromMap(
    Map<String, dynamic> map,
  ) {
    return Supplier(
      id: map['id'],
      nama: map['nama'] ?? '',
      noHp: map['no_hp'] ?? '',
      catatan: map['catatan'] ?? '',
    );
  }
}