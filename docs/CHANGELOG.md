# Changelog

## v0.2.0-alpha
- add stock history
- improve payment flow
- restructure README
- optimize transaction cart

---

## v0.1.0-alpha
- initial project setup
- basic inventory
- local database

### Added

#### Product Management

* Tambah produk
* Edit produk dasar
* Stok awal saat membuat produk
* Harga jual
* Harga beli
* Minimum stok
* Satuan dasar produk

#### Inventory

* Tambah stok manual
* Kurangi stok manual
* Catatan penyesuaian stok
* Histori pergerakan stok
* Warning stok minimum
* Validasi stok tidak boleh minus

#### Transaction

* Cart transaksi
* Penambahan produk ke cart
* Pengurangan qty item
* Perhitungan total otomatis
* Dialog pembayaran
* Perhitungan kembalian otomatis
* Simpan transaksi ke database

#### Receipt

* Receipt preview
* Informasi toko
* Detail item transaksi
* Ringkasan pembayaran
* Export PDF receipt

#### Settings

* Nama toko
* Alamat toko
* Telepon toko
* Footer nota

---

### Improved

#### Architecture

* Refactor TransactionPage menjadi widget modular
* CartSection dipisahkan
* ProductListSection dipisahkan
* CheckoutBar dipisahkan
* PaymentDialog dipisahkan
* QuickAddProductDialog dipisahkan

#### Formatting

* CurrencyFormatter dibuat reusable
* DateFormatter dibuat reusable

#### UX

* Produk dapat ditambah langsung dari halaman transaksi
* Inventory adjustment memiliki alasan dan catatan
* Warning stok minimum lebih jelas
* Histori stok lebih mudah dibaca

---

### Fixed

* Bug qty transaksi melebihi stok
* Bug refresh data inventory setelah adjustment
* Bug penggunaan BuildContext setelah async operation
* Bug formatting currency pada beberapa halaman
* Bug duplicate logic pada beberapa widget

---

### Internal

* Persiapan modular architecture
* Persiapan flavor BASIC / ADVANCED / PRO
* Persiapan inventory scaling
* Persiapan custom unit conversion
