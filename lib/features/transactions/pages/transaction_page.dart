import 'package:flutter/material.dart';
import 'package:kasir_app/features/transactions/models/cart_item.dart';
import '../../../data/local/produk_repo.dart';
import '../../../data/local/transaksi_repo.dart';
import '../../../data/local/settings_repo.dart';
import '../../../data/local/piutang_repo.dart';
import '../services/transaction_service.dart';
import '../widgets/transaction_page/cart_section.dart';
import '../widgets/transaction_page/checkout_bar.dart';
import '../widgets/transaction_page/payment_dialog.dart';
import '../widgets/transaction_page/product_list_section.dart';
import '../dialogs/quick_add_product_dialog.dart';
import 'receipt_preview_page.dart';
import '../../widgets/app_drawer.dart';

class TransaksiPage extends StatefulWidget {
  
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  Future<void> showTambahProdukCepatDialog(String initialName) async {
  final result = await showDialog<QuickAddProductResult>(
    context: context,
    builder: (dialogContext) {
      return QuickAddProductDialog(
        initialName: initialName,
      );
    },
  );

  if (result == null) return;

  await repo.insert({
    'nama': result.nama,
    'harga': result.harga,
    'harga_beli': 0,
    'stok': result.stok,
    'satuan_dasar': 'pcs',
    'minimum_stok': 0,
  });

  if (!mounted) return;

  setState(() {
    searchController.clear();
    searchQuery = '';
    produkList = repo.getAll();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Produk baru ditambahkan'),
    ),
  );
}


  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  } 

  final ProdukRepo repo = ProdukRepo();
  Future<List<Map<String, dynamic>>>? produkList;

  // cart key = produk id
  final Map<int, CartItem> cart = {};

  @override
  void initState() {
    super.initState();
    loadProduk();
  }

  void loadProduk() {
    setState(() {
      produkList = repo.getAll();
    });
  }

  void tambahKeCart(Map<String, dynamic> produk) {
    try {
      final updatedCart = TransactionService.addToCart(
        cart: cart,
        produk: produk,
      );

      setState(() {
        cart
          ..clear()
          ..addAll(updatedCart);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok tidak cukup'),
        ),
      );
    }
  }

  void kurangiQty(int id) {
    final updatedCart = TransactionService.decreaseQty(
      cart: cart,
      productId: id,
    );

    setState(() {
      cart
        ..clear()
        ..addAll(updatedCart);
    });
  } 

  int getTotal() {
    return TransactionService.getTotal(cart);
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  Future<void> showCheckoutDialog() async {
    final result = await showDialog<PaymentResult>(
      context: context,
      builder: (dialogContext) {
        return PaymentDialog(
          total: getTotal(),
          formatRupiah: formatRupiah,
        );
      },
    );

    if (result == null) return;

   await bayarDanSimpan(
    total: result.total,
    bayar: result.bayar,
    kembalian: result.kembalian,
    metodeBayar: result.metodeBayar,
    namaPelanggan: result.namaPelanggan,
    catatan: result.catatan,
);
  }

  Future<void> bayarDanSimpan({
    required int total,
    required int bayar,
    required int kembalian,
    required String metodeBayar,
    String? namaPelanggan,
    String? catatan,
  }) async {
    if (cart.isEmpty) return;

    final settingsData = await SettingsRepo().getSettings();

    final isTempo = metodeBayar == 'Tempo';
    final sisaHutang = isTempo? total - bayar : 0;
    final sisaHutangAman = sisaHutang < 0 ? 0: sisaHutang;
    final statusBayar = sisaHutangAman > 0 ? 'BELUM_LUNAS': 'LUNAS';

    try {
      final transaksiRepo = TransaksiRepo();

      final receiptItems = cart.values
          .map((item) => item.toMap())
          .toList();

      final transaksiId = await transaksiRepo.simpanTransaksi(
        receiptItems,
      );

      if (metodeBayar == 'Tempo') {
        await PiutangRepo().insert(
          transaksiId: transaksiId,
          namaPelanggan: namaPelanggan ?? 'Pelanggan',
          total: total,
          dibayar: bayar,
          catatan: catatan ?? '',
        );
      }

      if (!mounted) return;

      setState(() {
        cart.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewPage(
            transaksi: {
              'id': transaksiId,
              'total': total,
              'bayar': bayar,
              'kembalian': isTempo ? 0 : kembalian,
              'metode_bayar': metodeBayar,
              'status_bayar': statusBayar,
              'sisa_hutang': sisaHutangAman,
              'tanggal': DateTime.now().millisecondsSinceEpoch,
            },
            items: receiptItems,
            settings: settingsData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal simpan transaksi: $e'),
        ),
      );
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi')
      ),
      drawer: const AppDrawer(
        currentPage: 'Transaksi',
      ),
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(10, 5, 10, 24),
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            flex: 2,
            child: ProductListSection(
              produkList: produkList,
              searchQuery: searchQuery,
              formatRupiah: formatRupiah,
              cartQtyByProductId: cart.map(
                (key, value) => MapEntry(key, value.qty),
              ),
              onTapProduk: tambahKeCart,
              onTambahProdukBaru: () {
                showTambahProdukCepatDialog(
                  searchController.text,
                );
              },
            ),
          ),
          
          // CART
          Expanded(
            flex: 2,
            child: CartSection(
              cart: cart,
              formatRupiah: formatRupiah,
              onDecrease: kurangiQty,
            ),
          ),
          
          const Divider(height: 1),

          CheckoutBar(
            total: getTotal(),
            isCartEmpty: cart.isEmpty,
            formatRupiah: formatRupiah,
            onCheckout: showCheckoutDialog,
          ),
        ],

      ),
      ),
    );
  }
}