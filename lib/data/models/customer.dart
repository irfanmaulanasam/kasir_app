class Customer {
  final int? id;
  final String nama;
  final String noHp;
  final String catatan;

  const Customer({
    this.id,
    required this.nama,
    required this.noHp,
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

  factory Customer.fromMap(
    Map<String, dynamic> map,
  ) {
    return Customer(
      id: map['id'],
      nama: map['nama'] ?? '',
      noHp: map['no_hp'] ?? '',
      catatan: map['catatan'] ?? '',
    );
  }
}