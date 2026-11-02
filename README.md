# Monitoring Publikasi Survei LAN RI

Dashboard monitoring dan rekap publikasi Lembaga Administrasi Negara Republik Indonesia.

## Menjalankan aplikasi

- `npm install` — memasang dependensi
- `npm run dev` — menjalankan server Nuxt untuk pengembangan
- `npm run build` — membuat build produksi Nuxt
- `npm run preview` — melihat build produksi secara lokal

## Rute

- `/` — dashboard publik
- `/<username>` — halaman role pengguna/unit kerja, mengikuti username akun (contoh: `/stia.jkt`)
- `/kepala` — halaman role Kepala LAN RI
- `/deputi` — halaman role Deputi
- `/admin` — panel admin

Nuxt 4 menangani routing dan aplikasi web. Halaman dashboard dan admin yang ada dipertahankan sebagai aset di `public/legacy/` untuk menjaga fitur yang sudah berjalan saat migrasi bertahap.

## Fitur

- Dashboard publik dengan tab overview, timeline, unit dan cluster, channel publikasi, risiko, serta data records
- Panel admin untuk autentikasi dan pengelolaan data publikasi
- Integrasi Supabase dan penyimpanan browser yang digunakan halaman saat ini

## Konfigurasi

Salin `.env.example` menjadi `.env` untuk pengembangan lokal atau atur variabel Supabase pada environment deployment.

API tabel memakai Drizzle ORM pada server Nuxt dan menyimpan data ke tabel Supabase. Schema berada di `server/db/schema.ts`. Endpoint yang tersedia: `GET/POST /api/publikasi`, `PATCH/DELETE /api/publikasi/:no`, `GET/POST /api/users`, `DELETE /api/users/:username`, serta `GET/POST /api/prismo-proposals` dan `DELETE /api/prismo-proposals/:id`.

Atur `DATABASE_URL` sebagai environment variable server di Vercel memakai connection string Supabase Transaction pooler (port 6543). Jangan memasukkan password database ke kode browser. Jalankan `npm run db:pull` jika ingin mengintrospeksi ulang tabel Supabase ke schema Drizzle; jalankan perintah itu setelah mengatur `DATABASE_URL` lokal. Setelah variabel tersedia di Vercel, redeploy aplikasi.

## Demo

[dashboard-monitoring-survei-lan.vercel.app](https://dashboard-monitoring-survei-lan.vercel.app)

© LAN RI — Lembaga Administrasi Negara Republik Indonesia
