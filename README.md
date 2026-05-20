# Kasir App

Aplikasi POS (Point of Sale) berbasis Flutter untuk UMKM dengan fokus:
- offline first
- cepat dipakai
- workflow kasir sederhana
- inventory ringan
- monitoring usaha

Project saat ini difokuskan untuk mematangkan versi BASIC terlebih dahulu sebelum masuk ke ADVANCED dan PRO.

---

# Current Focus

Saat ini development diprioritaskan untuk:

✅ stabilitas transaksi  
✅ inventory workflow  
✅ kenyamanan input kasir  
✅ histori stok  
✅ receipt / nota  
✅ laporan sederhana  

Bukan fitur enterprise.

---

# App Structure

## Main Menu

### 1. Transaksi
Digunakan untuk proses penjualan.

Fitur:
- pilih produk
- cart transaksi
- quick search produk
- metode pembayaran
- uang diterima
- kembalian otomatis
- receipt preview
- simpan transaksi

---

### 2. Inventory
Digunakan untuk pengelolaan produk dan stok.

Fitur:
- tambah produk
- edit produk
- stok awal
- tambah stok
- kurangi stok
- histori stok masuk
- histori stok keluar
- catatan stok
- warning stok habis

---

### 3. Riwayat
Digunakan untuk monitoring usaha.

Fitur:
- ringkasan omzet
- jumlah transaksi
- riwayat transaksi
- riwayat stok
- produk terlaris
- produk hampir habis

---

### 4. Store Settings
Digunakan untuk identitas toko.

Fitur:
- nama toko
- alamat toko
- footer nota
- logo toko

---

# Flavor Plan

## BASIC (Current Main Focus)

Tujuan:
POS offline sederhana yang nyaman dipakai harian.

### Included
- transaksi offline
- inventory
- histori stok
- pembayaran
- receipt
- laporan sederhana

---

## ADVANCED

Tujuan:
mempercepat operasional kasir.

### Planned Features
- barcode scanner
- QR scanner
- quick action
- shortcut transaksi
- customer data
- pencarian lebih cepat

---

## PRO

Tujuan:
scaling bisnis & sinkronisasi.

### Planned Features
- cloud sync
- multi device
- multi cashier
- dashboard owner
- export laporan
- backup online
- multi cabang

---

# Progress Feature

| Feature | Status |
|---|---|
| Tambah produk | ✅ |
| Edit produk | 🚧 |
| Inventory stok | ✅ |
| Histori stok | ✅ |
| Cart transaksi | ✅ |
| Payment flow | ✅ |
| Receipt preview | ✅ |
| Print / PDF receipt | 🚧 |
| Riwayat transaksi | ✅ |
| Dashboard riwayat | 🚧 |
| Omzet sederhana | 🚧 |
| Warning stok habis | ✅ |
| Quick search produk | ✅ |
| Store settings | ✅ |
| Barcode scanner | ⏳ |
| Cloud sync | ⏳ |
| Multi device | ⏳ |

---

# Tech Stack

- Flutter
- SQLite (sqflite)
- Dart

---

# Development Philosophy

Project ini difokuskan untuk:
- workflow dulu
- UX kasir dulu
- stabilitas inventory dulu

Bukan:
- fitur enterprise terlalu cepat
- dashboard kompleks
- cloud terlalu dini

Tujuan utama:
membuat aplikasi kasir yang benar-benar nyaman dipakai UMKM sehari-hari.

---

# Run App

## BASIC
```bash
flutter run -t lib/main_basic.dart
```

## ADVANCED
```bash
flutter run -t lib/main_advance.dart
```

## PRO
```bash
flutter run -t lib/main_pro.dart
```


# Tech Stack

- Flutter
- SQLite
- Provider / Riverpod
- Bluetooth Printing
- Mobile Camera Scanner

---

# Development Roadmap

## Phase 1
- [x] Core transaksi
- [x] Database lokal
- [x] CRUD produk
- [ ] Bluetooth printing stabilization

## Phase 2
- [ ] Barcode scanner
- [ ] QR scanner
- [ ] Supplier management

## Phase 3
- [ ] Cloud sync
- [ ] Multi device
- [ ] Role management

---

# Architecture Notes

Aplikasi menggunakan:
- modular feature architecture
- single codebase
- feature gating
- offline-first approach

---

# Current Focus

Saat ini fokus pengembangan:
- stabilitas transaksi
- optimasi database
- scanner integration
- UX simplification

## Stability Level

| Module | Stability |
|---|---|
| Transaction Engine | High |
| Product Management | High |
| Scanner Module | Medium |
| Cloud Sync | Low |
