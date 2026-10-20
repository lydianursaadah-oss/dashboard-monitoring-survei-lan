# Monitoring Publikasi Survei LAN RI

Dashboard monitoring dan rekap publikasi Lembaga Administrasi Negara Republik Indonesia.

## 🌐 Live Demo

[https://dashboard-monitoring-survei-lan.vercel.app](https://dashboard-monitoring-survei-lan.vercel.app)

## 📋 Fitur

- **Dashboard Publik** (`index.html`) — Monitoring publikasi interaktif dengan 6 tab:
  - Overview & KPI
  - Timeline & Jadwal
  - Unit & Cluster
  - Channel Publikasi
  - Risiko & Flags
  - Data Records
- **Admin Panel** (`admin.html`) — CRUD data publikasi dengan autentikasi

## 🔐 Akses Admin

Klik logo LAN RI di pojok kiri header **5× berturut-turut** untuk masuk ke halaman admin.

- Default username: `admin`
- Default password: `admin2026`

## 🚀 Teknologi

- HTML5 + CSS3 + Vanilla JavaScript
- Chart.js v4.4.0
- localStorage untuk persistensi data admin
- Vercel untuk hosting

## 📁 Struktur File

```
├── index.html      # Dashboard publik
├── admin.html      # Panel admin (CRUD)
├── logo-lan.png    # Logo LAN RI
├── vercel.json     # Konfigurasi Vercel
└── .gitignore
```

---
© LAN RI — Lembaga Administrasi Negara Republik Indonesia
