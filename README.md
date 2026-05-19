# POS / Kasir App

Aplikasi kasir berbasis Flutter dengan dukungan offline-first,
multi segment bisnis, dan pengembangan modular.

---

# Feature Status

## Core Features

| Feature | Status | Basic | Advance | Pro |
|---|---|---|---|---|
| Login | ✅ Stable | ✅ | ✅ | ✅ |
| Transaksi Kasir | ✅ Stable | ✅ | ✅ | ✅ |
| Manajemen Produk | ✅ Stable | ✅ | ✅ | ✅ |
| Manajemen Stok | ✅ Stable | ✅ | ✅ | ✅ |
| Cetak Struk Bluetooth | 🚧 Development | ❌ | ✅ | ✅ |
| Barcode Scanner | 🚧 Development | ❌ | ✅ | ✅ |
| QR Code Scanner | 🚧 Development | ❌ | ✅ | ✅ |
| Multi User | 📋 Planned | ❌ | ❌ | ✅ |
| Cloud Sync | 📋 Planned | ❌ | ❌ | ✅ |
| Multi Cabang | 📋 Planned | ❌ | ❌ | ✅ |

---

# Status Legend

| Symbol | Meaning |
|---|---|
| ✅ | Stable / Ready |
| 🚧 | In Development |
| 🧪 | Experimental |
| 📋 | Planned |
| ❌ | Not Available |

---

# Package Segmentation

## Basic
Cocok untuk:
- warung
- toko kecil
- UMKM

Fitur utama:
- transaksi
- stok dasar
- laporan sederhana

---

## Advance
Cocok untuk:
- toko dengan banyak SKU
- minimarket kecil
- gudang kecil

Tambahan:
- barcode scanner
- QR scanner
- printer bluetooth

---

## Pro / Enterprise
Cocok untuk:
- multi outlet
- operasional kompleks
- banyak pegawai

Tambahan:
- multi user
- cloud sync
- role permission
- analytics

---

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
