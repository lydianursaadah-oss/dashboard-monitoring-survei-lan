-- =========================================================================
-- SETUP TABEL PRISMO PUBLICATION CALENDAR DI SUPABASE (LAN RI)
-- Digunakan oleh Humas LAN RI untuk mengatur jadwal tayang Publikasi Akhir
-- Dapat dilihat (read-only) oleh Admin DSPK2AN di menu Kalender Publikasi
-- =========================================================================

CREATE TABLE IF NOT EXISTS public.prismo_publication_calendar (
  id TEXT PRIMARY KEY,
  source_type TEXT DEFAULT 'raw',
  source_id TEXT NOT NULL,
  judul TEXT NOT NULL,
  unit TEXT NOT NULL,
  cluster TEXT DEFAULT '',
  pic TEXT DEFAULT '',
  bentuk_naskah TEXT DEFAULT 'Laporan Lengkap & Policy Brief',
  dokumen_url TEXT DEFAULT '',
  publish_date TEXT DEFAULT '',
  channels JSONB DEFAULT '[]'::jsonb,
  channel_links JSONB DEFAULT '{}'::jsonb,
  status_tayang TEXT DEFAULT 'terjadwal',
  catatan_humas TEXT DEFAULT '',
  updated_by TEXT DEFAULT 'Humas LAN RI',
  updated_role TEXT DEFAULT 'humas',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE public.prismo_publication_calendar ENABLE ROW LEVEL SECURITY;

-- Policy 1: Semua role (termasuk Admin DSPK2AN & Humas) dapat membaca kalender publikasi
DROP POLICY IF EXISTS "Semua role dapat membaca kalender publikasi" ON public.prismo_publication_calendar;
CREATE POLICY "Semua role dapat membaca kalender publikasi"
ON public.prismo_publication_calendar
FOR SELECT
USING (true);

-- Policy 2: Hanya role Humas yang mengelola jadwal kalender publikasi
DROP POLICY IF EXISTS "Hanya Humas yang dapat mengelola kalender publikasi" ON public.prismo_publication_calendar;
CREATE POLICY "Hanya Humas yang dapat mengelola kalender publikasi"
ON public.prismo_publication_calendar
FOR ALL
USING (updated_role = 'humas' OR current_user = 'postgres' OR current_user = 'authenticated')
WITH CHECK (updated_role = 'humas' OR current_user = 'postgres' OR current_user = 'authenticated');

-- Berikan hak akses tabel ke role anon, authenticated, dan service_role
GRANT ALL ON TABLE public.prismo_publication_calendar TO anon, authenticated, service_role;

-- Seed data awal dari Publikasi Akhir yang sudah selesai / sudah direview
INSERT INTO public.prismo_publication_calendar (
  id, source_type, source_id, judul, unit, cluster, pic, bentuk_naskah, dokumen_url, publish_date, channels, channel_links, status_tayang, catatan_humas, updated_by, updated_role
)
VALUES
  (
    'PUBCAL-PROPOSAL-PRISMO-2026-004',
    'proposal',
    'PRISMO-2026-004',
    'Survei Kepuasan Pemangku Kepentingan Diklat Kepemimpinan Nasional',
    'SKMK',
    'Tata Kelola & Manajemen ASN',
    'Dewi Lestari, S.Psi., M.M',
    'Laporan Lengkap & Policy Brief',
    'https://drive.google.com/file/d/1PRISMO2026004_TOR_KepuasanPKN/view?usp=sharing',
    '2026-11-05',
    '["Website LAN", "Instagram LAN", "Media Online"]'::jsonb,
    '{"Website LAN": "https://lan.go.id"}'::jsonb,
    'terjadwal',
    'Naskah Publikasi Akhir telah direview dan dijadwalkan tayang minggu pertama November 2026.',
    'Humas LAN RI',
    'humas'
  ),
  (
    'PUBCAL-RAW-1',
    'raw',
    '1',
    'Survei Optimalisasi Akses Layanan Kesehatan',
    'SKPP',
    'Prioritas Presiden',
    'Koordinator SKPP',
    'Laporan Lengkap & Ringkasan Eksekutif',
    '',
    '2026-11-10',
    '["Website LAN", "Website Unit", "Instagram Unit"]'::jsonb,
    '{}'::jsonb,
    'tayang',
    'Publikasi selesai dan telah tayang di kanal resmi.',
    'Humas LAN RI',
    'humas'
  ),
  (
    'PUBCAL-RAW-2',
    'raw',
    '2',
    'Survei Disrupsi Pekerjaan dan Keterampilan Strategis (Top Skills ASN)',
    'DAPKK',
    'Tata Kelola & Manajemen ASN',
    'Koordinator DAPKK',
    'Laporan Lengkap & Policy Paper',
    '',
    '2026-11-18',
    '["Website LAN", "YouTube LAN", "Instagram Unit"]'::jsonb,
    '{}'::jsonb,
    'terjadwal',
    'Dijadwalkan rilis serentak melalui kanal Website dan YouTube LAN RI.',
    'Humas LAN RI',
    'humas'
  )
ON CONFLICT (id) DO UPDATE SET
  judul = EXCLUDED.judul,
  unit = EXCLUDED.unit,
  cluster = EXCLUDED.cluster,
  pic = EXCLUDED.pic,
  bentuk_naskah = EXCLUDED.bentuk_naskah,
  dokumen_url = EXCLUDED.dokumen_url,
  publish_date = EXCLUDED.publish_date,
  channels = EXCLUDED.channels,
  channel_links = EXCLUDED.channel_links,
  status_tayang = EXCLUDED.status_tayang,
  catatan_humas = EXCLUDED.catatan_humas,
  updated_by = EXCLUDED.updated_by,
  updated_role = EXCLUDED.updated_role,
  updated_at = NOW();
