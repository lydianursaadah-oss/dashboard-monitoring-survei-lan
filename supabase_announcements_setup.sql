-- =========================================================================
-- SETUP TABEL PRISMO ANNOUNCEMENTS DI SUPABASE (LAN RI)
-- Sinkronisasi Pengumuman Resmi PRISMO: Hanya Admin DSPK2AN yang Mengelola
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.prismo_announcements (
  id BIGINT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  date TEXT,
  kategori TEXT DEFAULT 'Umum',
  target_type TEXT DEFAULT 'Semua pengguna',
  target_value TEXT DEFAULT '',
  status TEXT DEFAULT 'Terbit',
  start_date TEXT,
  end_date TEXT,
  attachment_url TEXT DEFAULT '',
  author TEXT DEFAULT 'Admin DSPK2AN',
  author_role TEXT DEFAULT 'admin_dspk2an',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE public.prismo_announcements ENABLE ROW LEVEL SECURITY;

-- Policy 1: Semua pengguna dan publik dapat melihat / membaca pengumuman
DROP POLICY IF EXISTS "Semua role dapat membaca pengumuman" ON public.prismo_announcements;
CREATE POLICY "Semua role dapat membaca pengumuman"
ON public.prismo_announcements
FOR SELECT
USING (true);

-- Policy 2: Hanya role Admin DSPK2AN yang diizinkan menambah / mengubah data pengumuman
DROP POLICY IF EXISTS "Hanya Admin DSPK2AN yang dapat mengelola pengumuman" ON public.prismo_announcements;
CREATE POLICY "Hanya Admin DSPK2AN yang dapat mengelola pengumuman"
ON public.prismo_announcements
FOR ALL
USING (author_role = 'admin_dspk2an' OR current_user = 'postgres' OR current_user = 'authenticated')
WITH CHECK (author_role = 'admin_dspk2an' OR current_user = 'postgres' OR current_user = 'authenticated');

-- Beri hak akses tabel ke role anon dan authenticated
GRANT ALL ON TABLE public.prismo_announcements TO anon, authenticated, service_role;

-- Seed data pengumuman default jika belum ada
INSERT INTO public.prismo_announcements (
  id, title, description, date, kategori, target_type, target_value, status, start_date, end_date, attachment_url, author, author_role
)
VALUES 
  (1, 'Instruksi Pimpinan: Akselerasi Publikasi Hasil Analisis Kebijakan Triwulan IV', 'Seluruh unit kerja pelaksana (Pusjar SKMK, SKPP, DAPKK, SKMP, SKTAN, STIA) diharapkan segera menuntaskan draf instrumen dan laporan ringkas sebelum tenggat akhir tahun anggaran 2026.', '28 Okt 2026', 'Kebijakan & Arahan Pimpinan', 'Semua pengguna', '', 'Terbit', '2026-10-01', '2026-12-31', '', 'Admin DSPK2AN', 'admin_dspk2an'),
  (2, 'Pemberitahuan Sinkronisasi Database Survei LAN RI (PRISMO)', 'Sistem telah terhubung langsung dengan Google Spreadsheet Analis/Survei 2026 dan database terpusat untuk monitoring real-time seluruh tahapan survei dan kajian kebijakan.', '22 Okt 2026', 'Sistem & Teknis', 'Semua pengguna', '', 'Terbit', '2026-10-01', '2026-12-31', '', 'Admin DSPK2AN', 'admin_dspk2an'),
  (3, 'Jadwal Review Draft Policy Brief & Policy Paper Triwulan IV', 'Agenda pemaparan hasil pengolahan data survei bersama Kepala LAN RI, Deputi, dan Tim Peneliti unit kerja akan dilaksanakan secara bertahap mulai minggu pertama November 2026.', '15 Okt 2026', 'Jadwal Publikasi', 'Semua pengguna', '', 'Terbit', '2026-10-01', '2026-12-31', '', 'Admin DSPK2AN', 'admin_dspk2an')
ON CONFLICT (id) DO NOTHING;
