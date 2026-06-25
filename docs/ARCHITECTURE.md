# ARCHITECTURE

## Purpose

Dokumen ini menjelaskan struktur teknis Kasir App agar pengembangan tetap rapi, mudah dirawat, dan tidak berubah menjadi aplikasi yang terlalu kompleks.

Kasir App dibangun sebagai aplikasi kasir offline-first untuk usaha kecil dan menengah, dengan fokus pada stabilitas transaksi, keakuratan stok, dan penggunaan ringan di perangkat Android sederhana.

---

## Core Principles

### Offline First

Aplikasi harus tetap dapat digunakan tanpa koneksi internet.

Transaksi, stok, piutang, pengeluaran, dan pengaturan toko disimpan secara lokal terlebih dahulu.

### Lightweight

Aplikasi harus tetap ringan dan dapat berjalan di perangkat Android entry-level.

Setiap keputusan teknis harus mempertimbangkan:

- performa
- ukuran aplikasi
- penggunaan memori
- kecepatan transaksi

### Modular

Kode dibagi berdasarkan tanggung jawab agar mudah dipahami dan dirawat.

Setiap fitur utama sebaiknya memiliki batas yang jelas.

### Simple Before Scalable

Arsitektur tidak boleh terlalu rumit sebelum kebutuhan produk benar-benar membutuhkannya.

Kasir App tidak dirancang sebagai ERP sejak awal.

### Feature Gating

Fitur dapat dikelompokkan berdasarkan level produk:

- BASIC
- ADVANCED
- PRO

Namun fitur inti BASIC harus tetap stabil dan dapat digunakan tanpa bergantung pada fitur lanjutan.

---

## App Layers

### Presentation Layer

Berisi halaman dan komponen UI.

Tanggung jawab:

- menampilkan data
- menerima input pengguna
- memberikan feedback
- menjaga alur penggunaan tetap sederhana

Contoh:

- product page
- transaction page
- inventory page
- receivable page
- expense page
- settings page

---

### Service Layer

Berisi aturan bisnis dan proses antar fitur.

Tanggung jawab:

- mengatur transaksi penjualan
- mengurangi stok saat transaksi berhasil
- mencatat histori stok
- mencatat piutang jika pembayaran tempo
- menjaga konsistensi data

Contoh:

- inventory service
- transaction service
- receivable service
- cash flow service

---

### Repository Layer

Berisi akses data ke database lokal.

Tanggung jawab:

- membaca data
- menyimpan data
- mengubah data
- menghapus data
- menyembunyikan detail SQLite dari UI

Contoh:

- product repository
- transaction repository
- inventory repository
- receivable repository
- expense repository
- settings repository

---

### Local Database Layer

Menggunakan SQLite melalui `sqflite`.

Tanggung jawab:

- menyimpan data utama aplikasi
- menjaga data tetap tersedia secara offline
- mendukung backup dan restore database

Database lokal adalah sumber utama data pada versi BASIC.

---

### Shared Utilities

Berisi fungsi bantuan yang dipakai lintas fitur.

Contoh:

- currency formatter
- date formatter
- unit converter
- printer helper
- validation helper

---

## Current Technology

### Framework

Flutter

### Local Database

SQLite using `sqflite`

Alasan:

- ringan
- stabil
- mendukung offline-first
- cocok untuk perangkat Android sederhana
- tidak membutuhkan server untuk operasional harian

---

## Current Module Direction

Struktur kode disarankan mengikuti pola berikut:

```text
lib/
├── core/
│   ├── database/
│   ├── utils/
│   └── constants/
│
├── data/
│   ├── repositories/
│   └── models/
│
├── services/
│
├── features/
│   ├── product/
│   ├── inventory/
│   ├── transaction/
│   ├── receivable/
│   ├── expense/
│   └── settings/
│
└── main.dart

```
## Feature Boundaries
### Product

Mengelola data produk.

Tidak boleh langsung mengatur transaksi.

### Inventory

Mengelola perubahan stok.

Semua perubahan stok sebaiknya tercatat melalui histori stok.

### Transaction

Mengelola penjualan.

Transaksi boleh memicu:

pengurangan stok
pencatatan piutang
pencatatan kas masuk

Tetapi proses tersebut sebaiknya tetap melalui service layer.

### Receivable

Mengelola piutang pelanggan.

Piutang tidak boleh otomatis dianggap sebagai uang masuk sebelum ada pembayaran.

### Expense

Mengelola uang keluar.

Pengeluaran harus masuk ke aktivitas keuangan, tetapi tidak boleh mengganggu data transaksi penjualan.

### Settings

Mengelola identitas toko dan preferensi aplikasi.
## Data Flow Example

### Cash Transaction

```text
User creates transaction
↓
Transaction Service validates cart
↓
Stock is reduced
↓
Transaction is saved
↓
Cash income is recorded
↓
Receipt preview is shown
```

## Design Rule

UI tidak boleh langsung mengubah banyak tabel sekaligus.

Jika sebuah aksi menyentuh beberapa data, proses tersebut harus dipusatkan di service layer.

Contoh:
Transaksi penjualan tidak hanya menyimpan transaksi.

Transaksi juga bisa:

- mengurangi stok
- membuat piutang
- mencatat aktivitas kas
- membuat histori

Karena itu proses transaksi harus ditangani oleh service, bukan langsung dari halaman UI.

### Future Architecture Considerations

Fitur berikut belum menjadi prioritas BASIC, tetapi perlu dipertimbangkan agar struktur kode tidak berantakan ketika dikembangkan nanti:

* cloud sync
* multi user
* multi device
* multi store
* role permission
* owner dashboard

Namun fitur tersebut tidak boleh membuat arsitektur BASIC menjadi terlalu berat.

## Not In Scope For Current Architecture

Arsitektur saat ini tidak dirancang untuk:

* ERP manufaktur
* akuntansi kompleks
* payroll
* HRD
* warehouse management besar
* approval workflow berlapis
