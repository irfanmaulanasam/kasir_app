# DATABASE

## Overview

Kasir App menggunakan SQLite melalui package `sqflite`.

Database dirancang dengan prinsip:

* Offline First
* Lightweight
* Relational Database
* Low-End Device Friendly

Seluruh data operasional disimpan secara lokal pada perangkat pengguna.

---

# Entity Relationship Overview

```text
Customer
│
├── Transaksi
│     └── Detail Transaksi
│
└── Piutang
      └── Pembayaran Piutang

Product
│
├── Detail Transaksi
│
└── Stok Log

Supplier
│
├── Hutang Supplier
│
└── Pembayaran Hutang

Pengeluaran

Cash Session

Settings
```

---

# Product

Menyimpan data produk yang dijual.

Table: `produk`

| Field        | Type    | Description        |
| ------------ | ------- | ------------------ |
| id           | INTEGER | Primary Key        |
| nama         | TEXT    | Nama produk        |
| harga        | INTEGER | Harga jual         |
| harga_beli   | INTEGER | Harga beli         |
| stok         | INTEGER | Stok saat ini      |
| satuan_dasar | TEXT    | Satuan produk      |
| minimum_stok | INTEGER | Batas minimum stok |

---

# Customer

Menyimpan data pelanggan.

Table: `customers`

| Field   | Type    | Description      |
| ------- | ------- | ---------------- |
| id      | INTEGER | Primary Key      |
| nama    | TEXT    | Nama pelanggan   |
| no_hp   | TEXT    | Nomor telepon    |
| catatan | TEXT    | Catatan tambahan |

---

# Transaction

Menyimpan transaksi penjualan.

Table: `transaksi`

| Field           | Type    | Description                    |
| --------------- | ------- | ------------------------------ |
| id              | INTEGER | Primary Key                    |
| nomor_transaksi | TEXT    | Nomor transaksi unik           |
| tanggal         | INTEGER | Timestamp transaksi            |
| total           | INTEGER | Total transaksi                |
| metode_bayar    | TEXT    | Cash / Transfer / QRIS / Tempo |
| customer_id     | INTEGER | Relasi ke customer             |

---

# Transaction Detail

Menyimpan item yang dijual pada setiap transaksi.

Table: `detail`

| Field        | Type    | Description          |
| ------------ | ------- | -------------------- |
| id           | INTEGER | Primary Key          |
| transaksi_id | INTEGER | Relasi transaksi     |
| produk_id    | INTEGER | Relasi produk        |
| qty          | INTEGER | Jumlah produk        |
| harga        | INTEGER | Harga saat transaksi |
| subtotal     | INTEGER | Nilai subtotal       |

---

# Receivable

Menyimpan piutang pelanggan.

Table: `piutang`

| Field          | Type    | Description                       |
| -------------- | ------- | --------------------------------- |
| id             | INTEGER | Primary Key                       |
| customer_id    | INTEGER | Relasi customer                   |
| transaksi_id   | INTEGER | Relasi transaksi                  |
| nama_pelanggan | TEXT    | Nama pelanggan                    |
| total          | INTEGER | Total piutang                     |
| dibayar        | INTEGER | Total pembayaran                  |
| sisa           | INTEGER | Sisa piutang                      |
| status         | TEXT    | BELUM_LUNAS / LUNAS / JATUH_TEMPO |
| catatan        | TEXT    | Catatan                           |
| tanggal        | INTEGER | Tanggal dibuat                    |
| jatuh_tempo    | INTEGER | Jatuh tempo                       |

---

# Receivable Payment

Menyimpan histori pembayaran piutang.

Table: `piutang_payments`

| Field       | Type    | Description        |
| ----------- | ------- | ------------------ |
| id          | INTEGER | Primary Key        |
| customer_id | INTEGER | Relasi customer    |
| nominal     | INTEGER | Nominal pembayaran |
| catatan     | TEXT    | Catatan pembayaran |
| tanggal     | INTEGER | Tanggal pembayaran |

---

# Inventory Log

Menyimpan histori perubahan stok.

Table: `stok_log`

| Field     | Type    | Description                 |
| --------- | ------- | --------------------------- |
| id        | INTEGER | Primary Key                 |
| produk_id | INTEGER | Relasi produk               |
| qty       | INTEGER | Jumlah perubahan            |
| tipe      | TEXT    | MASUK / KELUAR / ADJUSTMENT |
| catatan   | TEXT    | Catatan                     |
| tanggal   | INTEGER | Timestamp                   |
| user_id   | TEXT    | Pengubah data               |

---

# Expense

Menyimpan pengeluaran usaha.

Table: `pengeluaran`

| Field    | Type    | Description          |
| -------- | ------- | -------------------- |
| id       | INTEGER | Primary Key          |
| kategori | TEXT    | Kategori pengeluaran |
| nominal  | INTEGER | Nilai pengeluaran    |
| catatan  | TEXT    | Catatan              |
| tanggal  | INTEGER | Timestamp            |

---

# Store Settings

Menyimpan identitas toko.

Table: `settings`

| Field     | Type    | Description   |
| --------- | ------- | ------------- |
| id        | INTEGER | Selalu 1      |
| nama_toko | TEXT    | Nama toko     |
| alamat    | TEXT    | Alamat toko   |
| telepon   | TEXT    | Nomor telepon |
| footer    | TEXT    | Footer nota   |

---

# Cash Session

Menyimpan informasi kas awal.

Table: `cash_sessions`

| Field    | Type    | Description |
| -------- | ------- | ----------- |
| id       | INTEGER | Primary Key |
| tanggal  | INTEGER | Tanggal     |
| kas_awal | INTEGER | Kas awal    |
| catatan  | TEXT    | Catatan     |

---

# Supplier

Menyimpan data supplier.

Table: `suppliers`

| Field   | Type    | Description   |
| ------- | ------- | ------------- |
| id      | INTEGER | Primary Key   |
| nama    | TEXT    | Nama supplier |
| no_hp   | TEXT    | Nomor telepon |
| catatan | TEXT    | Catatan       |

---

# Supplier Debt

Menyimpan hutang supplier.

Table: `supplier_debts`

| Field       | Type    | Description        |
| ----------- | ------- | ------------------ |
| id          | INTEGER | Primary Key        |
| supplier_id | INTEGER | Relasi supplier    |
| total       | INTEGER | Total hutang       |
| dibayar     | INTEGER | Total pembayaran   |
| sisa        | INTEGER | Sisa hutang        |
| status      | TEXT    | Status hutang      |
| catatan     | TEXT    | Catatan            |
| tanggal     | INTEGER | Tanggal pencatatan |

---

# Supplier Debt Payment

Menyimpan histori pembayaran hutang supplier.

Table: `supplier_debt_payments`

| Field       | Type    | Description        |
| ----------- | ------- | ------------------ |
| id          | INTEGER | Primary Key        |
| supplier_id | INTEGER | Relasi supplier    |
| nominal     | INTEGER | Nominal pembayaran |
| catatan     | TEXT    | Catatan            |
| tanggal     | INTEGER | Tanggal pembayaran |

---

# Business Rules

## Transaction

Transaksi dapat:

* Mengurangi stok
* Membuat piutang
* Menambah kas masuk

---

## Credit Transaction

Transaksi tempo:

* Mengurangi stok
* Membuat piutang
* Tidak menambah kas masuk

Kas masuk baru dicatat saat pembayaran piutang diterima.

---

## Inventory

Semua perubahan stok harus tercatat pada:

`stok_log`

Tidak boleh ada perubahan stok tanpa histori.

---

## Receivable

Piutang bukan uang masuk.

Piutang hanya menjadi kas masuk setelah pembayaran diterima.

---

## Supplier Debt

Hutang supplier bukan pengeluaran kas.

Pengeluaran baru terjadi saat pembayaran hutang dilakukan.

---

# Current Database Version

Version: 1

Database File:

```text
kasir.db
```

Engine:

```text
SQLite
```
