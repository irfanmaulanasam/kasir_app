import '../models/cart_item.dart';

class TransactionService {
  static int getTotal(Map<int, CartItem> cart) {
    return cart.values.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  static Map<int, CartItem> addToCart({
    required Map<int, CartItem> cart,
    required Map<String, dynamic> produk,
  }) {
    final newCart = Map<int, CartItem>.from(cart);

    final id = produk['id'] as int;
    final nama = produk['nama'].toString();
    final harga = produk['harga'] as int;

    final existing = newCart[id];

    if (existing == null) {
      newCart[id] = CartItem(
        id: id,
        nama: nama,
        harga: harga,
        qty: 1,
      );
    } else {
      newCart[id] = existing.copyWith(
        qty: existing.qty + 1,
      );
    }

    return newCart;
  }

  static Map<int, CartItem> decreaseQty({
    required Map<int, CartItem> cart,
    required int productId,
  }) {
    final newCart = Map<int, CartItem>.from(cart);
    final item = newCart[productId];

    if (item == null) return newCart;

    if (item.qty <= 1) {
      newCart.remove(productId);
    } else {
      newCart[productId] = item.copyWith(
        qty: item.qty - 1,
      );
    }

    return newCart;
  }

  static Map<int, CartItem> removeItem({
    required Map<int, CartItem> cart,
    required int productId,
  }) {
    final newCart = Map<int, CartItem>.from(cart);
    newCart.remove(productId);
    return newCart;
  }
}