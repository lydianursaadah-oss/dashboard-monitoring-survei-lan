-- =========================================================================
-- SETUP TABEL PRISMO ANNOUNCEMENTS DI SUPABASE (LAN RI)
-- Sinkronisasi Pengumuman Resmi PRISMO: Hanya Admin DSPK2AN yang Mengelola
-- Isi pengumuman default disesuaikan persis dengan data bawaan PRISMO
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

-- Policy 1: Semua role dan publik dapat membaca pengumuman
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

-- Berikan hak akses tabel ke role anon dan authenticated
GRANT ALL ON TABLE public.prismo_announcements TO anon, authenticated, service_role;

-- Seed data pengumuman bawaan PRISMO (disesuaikan persis dengan sistem PRISMO)
INSERT INTO public.prismo_announcements (
  id, title, description, date, kategori, target_type, target_value, status, start_date, end_date, attachment_url, author, author_role
)
VALUES 
  (
    1,
    'Arahan Penyelesaian Tahapan Publikasi Survei TA 2026',
    'Seluruh unit kerja diharapkan mempercepat penyusunan instrumen dan pengolahan data sebelum batas waktu Q4. Pastikan dokumen TOR/Proposal pada Google Drive telah memiliki akses baca bagi tim verifikator.',
    '27 Okt 2026',
    'Arahan Pimpinan',
    'Semua pengguna',
    '',
    'Terbit',
    '2026-10-01',
    '2026-12-31',
    '',
    'Admin DSPK2AN',
    'admin_dspk2an'
  ),
  (
    2,
    'Pemberitahuan Sinkronisasi Database Survei LAN RI (PRISMO)',
    'Sistem telah terhubung langsung dengan Google Spreadsheet Analis/Survei 2026 dan database terpusat untuk monitoring real-time seluruh tahapan survei dan kajian kebijakan.',
    '22 Okt 2026',
    'Sistem & Teknis',
    'Semua pengguna',
    '',
    'Terbit',
    '2026-10-01',
    '2026-12-31',
    '',
    'Admin DSPK2AN',
    'admin_dspk2an'
  ),
  (
    3,
    'Jadwal Review Draft Policy Brief & Policy Paper Triwulan IV',
    'Agenda pemaparan hasil pengolahan data survei bersama Kepala LAN RI, Deputi, dan Tim Peneliti unit kerja akan dilaksanakan secara bertahap mulai minggu pertama November 2026.',
    '15 Okt 2026',
    'Jadwal Publikasi',
    'Semua pengguna',
    '',
    'Terbit',
    '2026-10-01',
    '2026-12-31',
    '',
    'Admin DSPK2AN',
    'admin_dspk2an'
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  date = EXCLUDED.date,
  kategori = EXCLUDED.kategori,
  target_type = EXCLUDED.target_type,
  target_value = EXCLUDED.target_value,
  status = EXCLUDED.status,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  attachment_url = EXCLUDED.attachment_url,
  author = EXCLUDED.author,
  author_role = EXCLUDED.author_role,
  updated_at = NOW();
