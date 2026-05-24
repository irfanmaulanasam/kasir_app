class CartItem {
  final int id;
  final String nama;
  final int harga;
  final int qty;

  const CartItem({
    required this.id,
    required this.nama,
    required this.harga,
    required this.qty,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'qty': qty,
    };
  }
  int get subtotal => harga * qty;

  CartItem copyWith({
    int? qty,
  }) {
    return CartItem(
      id: id,
      nama: nama,
      harga: harga,
      qty: qty ?? this.qty,
    );
  }
}
