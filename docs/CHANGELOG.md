# Changelog

# Changelog

## v0.3.0-alpha

### Added

#### Activity

* Activity timeline
* Activity filter (Semua, Penjualan, Pengeluaran, Stok, Piutang)
* Activity period filter (Hari Ini, 7 Hari, 30 Hari)
* Activity cash summary
* Pull-to-refresh activity page

#### Piutang

* Customer detail page
* Customer debt summary
* Debt payment history table
* Customer-based debt settlement workflow

#### Expenses

* Expense detail page
* Activity integration for expenses

#### Inventory

* Stock log detail page
* Activity integration for stock movement

#### Transactions

* Transaction detail page improvements
* Transaction navigation from Activity page

### Improved

#### UX

* Replaced most SnackBar notifications with AppDialog
* Better navigation flow between modules
* Cleaner activity timeline layout
* Better readability for transaction and debt workflow

#### Architecture

* ActivityPage refactored into modular widgets
* ActivitySummaryCard extracted
* ActivityItemCard extracted
* ActivityFilterBar extracted
* ActivityRangeBar extracted

### Fixed

* Debt summary loading issue
* Null customer references in debt records
* Customer debt detail crash
* Payment validation issues
* Activity sorting consistency

---

## v0.2.0-alpha

### Added

* Stock history
* Improved payment flow
* Restructured README
* Optimized transaction cart

---

## v0.1.0-alpha

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

#### Customer & Debt

* Customer model
* Customer repository
* Customer database table
* Tempo payment workflow
* Piutang page
* Debt payment dialog
* Receipt payment status

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

### Fixed

* Bug qty transaksi melebihi stok
* Bug refresh data inventory setelah adjustment
* Bug penggunaan BuildContext setelah async operation
* Bug formatting currency pada beberapa halaman
* Bug duplicate logic pada beberapa widget
* QRIS and Transfer now require full payment
* Prevent overpayment on debt settlement
* Currency formatting for debt payments
* Receipt header alignment

### Internal

* Persiapan modular architecture
* Persiapan flavor BASIC / ADVANCED / PRO
* Persiapan inventory scaling
* Persiapan custom unit conversion

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

## [0.1.0-alpha] - 2026-05-31

### Added
- Customer model
- Customer repository
- Customer database table
- Tempo payment workflow
- Piutang page
- Debt payment dialog
- Receipt payment status

### Fixed
- QRIS and Transfer now require full payment
- Prevent overpayment on debt settlement
- Currency formatting for debt payments
- Receipt header alignment

