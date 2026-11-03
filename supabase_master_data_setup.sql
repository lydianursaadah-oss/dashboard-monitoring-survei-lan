-- =============================================================================
-- PRISMO — SUPABASE SQL SETUP MASTER DATA TERPADU LAN RI
-- File: supabase_master_data_setup.sql
-- Sifat: Idempotent & Non-Destructive (Sangat aman dijalankan berkali-kali)
-- Cara Pakai: Salin seluruh script ini, buka Supabase Dashboard > SQL Editor > Paste & Run.
-- =============================================================================

-- 1. TABEL MASTER CLUSTER KEBIJAKAN
CREATE TABLE IF NOT EXISTS public.prismo_master_clusters (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT UNIQUE NOT NULL,
    description TEXT DEFAULT '',
    color_hex TEXT DEFAULT '#2563eb',
    is_placeholder BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    legacy_names JSONB DEFAULT '[]'::jsonb,
    sort_order INT DEFAULT 0,
    updated_by TEXT DEFAULT 'system',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Seed 6 Cluster Resmi LAN RI
INSERT INTO public.prismo_master_clusters (code, name, description, color_hex, is_placeholder, is_active, legacy_names, sort_order)
VALUES
    ('CL-01', 'Program Prioritas Presiden', 'Program Prioritas Presiden & Kebijakan Strategis Nasional', '#ef4444', false, true, '["Program Prioritas Presiden", "Prioritas Presiden", "Prioritas Presiden & Kebijakan Strategis"]'::jsonb, 1),
    ('CL-02', 'Digitalisasi', 'Transformasi Digital dan SPBE', '#8b5cf6', false, true, '["Digitalisasi", "Digitalisasi & Transformasi Digital"]'::jsonb, 2),
    ('CL-03', 'Tata Kelola dan Manajemen ASN', 'Tata Kelola Lembaga, Reformasi Birokrasi dan Manajemen ASN', '#3b82f6', false, true, '["Tata Kelola dan Manajemen ASN", "Tata Kelola & Manajemen ASN", "Manajemen ASN", "Manajemen ASN & Birokrasi"]'::jsonb, 3),
    ('CL-04', 'Manajemen Kinerja', 'Pengelolaan dan Akuntabilitas Kinerja Instansi dan ASN', '#f59e0b', false, true, '["Manajemen Kinerja"]'::jsonb, 4),
    ('CL-05', 'Pelayanan Publik', 'Peningkatan Kualitas dan Inovasi Pelayanan Publik', '#22c55e', false, true, '["Pelayanan Publik", "Pelayanan Publik & Inovasi"]'::jsonb, 5),
    ('CL-06', 'Manajemen Pemerintahan', 'Pemerintahan Umum, Otonomi Daerah, dan Administrasi Negara', '#14b8a6', false, true, '["Manajemen Pemerintahan", "Inovasi Administrasi Negara", "Desentralisasi & Otonomi Daerah", "Ekonomi & Pembangunan Daerah"]'::jsonb, 6)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    color_hex = EXCLUDED.color_hex,
    is_placeholder = EXCLUDED.is_placeholder,
    is_active = EXCLUDED.is_active,
    legacy_names = EXCLUDED.legacy_names,
    sort_order = EXCLUDED.sort_order,
    updated_at = timezone('utc'::text, now());

-- 2. TABEL MASTER UNIT KERJA LAN RI
CREATE TABLE IF NOT EXISTS public.prismo_master_units (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    category TEXT DEFAULT 'Pusat Studi',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Seed 13 Unit Kerja / Satker LAN RI
INSERT INTO public.prismo_master_units (code, name, category, is_active, sort_order)
VALUES
    ('SKPP', 'Pusat Studi Kebijakan Pelayanan Publik (SKPP)', 'Pusat Studi', true, 1),
    ('DAPKK', 'Direktorat Analisis & Pengembangan Kebijakan (DAPKK)', 'Direktorat', true, 2),
    ('SKMP', 'Pusat Studi Kebijakan Manajemen Pemerintahan (SKMP)', 'Pusat Studi', true, 3),
    ('SKTAN', 'Pusat Studi Kebijakan Tata Kelola & ASN (SKTAN)', 'Pusat Studi', true, 4),
    ('SKMK', 'Pusat Studi Kebijakan Manajemen Kinerja (SKMK)', 'Pusat Studi', true, 5),
    ('STIA JKT', 'Politeknik STIA LAN Jakarta', 'Perguruan Tinggi', true, 6),
    ('STIA MKS', 'Politeknik STIA LAN Makassar', 'Perguruan Tinggi', true, 7),
    ('STIA BDG', 'Politeknik STIA LAN Bandung', 'Perguruan Tinggi', true, 8),
    ('DSPK2AN', 'Deputi Kajian Kebijakan & Inovasi (DSPK2AN)', 'Kedeputian', true, 9),
    ('KDOD', 'Puslatbang KDOD Samarinda', 'Puslatbang', true, 10),
    ('KHAN', 'Puslatbang KHAN Aceh', 'Puslatbang', true, 11),
    ('PKASN', 'Puslatbang PKASN Jatinangor', 'Puslatbang', true, 12),
    ('KMP', 'Puslatbang KMP Makassar', 'Puslatbang', true, 13)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    category = EXCLUDED.category,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order,
    updated_at = timezone('utc'::text, now());

-- 3. TABEL MASTER JENIS PUBLIKASI & LUARAN
CREATE TABLE IF NOT EXISTS public.prismo_master_jenis (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Seed 6 Jenis Publikasi
INSERT INTO public.prismo_master_jenis (code, name, description, is_active, sort_order)
VALUES
    ('JENIS-01', 'Survei', 'Survei dan Pengumpulan Data Kebijakan', true, 1),
    ('JENIS-02', 'Kajian Kebijakan', 'Naskah Akademik dan Analisis Kebijakan', true, 2),
    ('JENIS-03', 'Policy Brief', 'Ringkasan Eksekutif Rekomendasi Kebijakan', true, 3),
    ('JENIS-04', 'Laporan Analisis', 'Laporan Komprehensif Hasil Evaluasi & Riset', true, 4),
    ('JENIS-05', 'Buku Referensi', 'Publikasi Buku ISBN dan Bunga Rampai', true, 5),
    ('JENIS-06', 'Jurnal Ilmiah', 'Artikel Ilmiah Terakreditasi Nasional/Internasional', true, 6)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order,
    updated_at = timezone('utc'::text, now());

-- 4. TABEL MASTER KANAL MEDIA PUBLIKASI
CREATE TABLE IF NOT EXISTS public.prismo_master_media (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    type TEXT DEFAULT 'Media',
    field_key TEXT DEFAULT '',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Seed 9 Kanal Media Publikasi
INSERT INTO public.prismo_master_media (code, name, type, field_key, is_active, sort_order)
VALUES
    ('MED-01', 'Jurnal Ilmiah', 'Akademik', 'jurnal', true, 1),
    ('MED-02', 'Media Massa / Online', 'Berita & Siaran Pers', 'media', true, 2),
    ('MED-03', 'Website Resmi LAN RI', 'Portal Resmi', 'web_lan', true, 3),
    ('MED-04', 'Website Unit Kerja', 'Portal Satker', 'web_unit', true, 4),
    ('MED-05', 'Instagram LAN RI', 'Media Sosial', 'ig_lan', true, 5),
    ('MED-06', 'Instagram Unit Kerja', 'Media Sosial Satker', 'ig_unit', true, 6),
    ('MED-07', 'YouTube LAN RI', 'Video Streaming', 'yt_lan', true, 7),
    ('MED-08', 'YouTube Unit Kerja', 'Video Streaming Satker', 'yt_unit', true, 8),
    ('MED-09', 'Media Televisi', 'Penyiaran Nasional', 'media_televisi', true, 9)
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    type = EXCLUDED.type,
    field_key = EXCLUDED.field_key,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order,
    updated_at = timezone('utc'::text, now());

-- 5. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.prismo_master_clusters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prismo_master_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prismo_master_jenis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prismo_master_media ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    -- Clusters
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_clusters' AND policyname = 'Allow read clusters') THEN
        CREATE POLICY "Allow read clusters" ON public.prismo_master_clusters FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_clusters' AND policyname = 'Allow manage clusters') THEN
        CREATE POLICY "Allow manage clusters" ON public.prismo_master_clusters FOR ALL USING (true) WITH CHECK (true);
    END IF;

    -- Units
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_units' AND policyname = 'Allow read units') THEN
        CREATE POLICY "Allow read units" ON public.prismo_master_units FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_units' AND policyname = 'Allow manage units') THEN
        CREATE POLICY "Allow manage units" ON public.prismo_master_units FOR ALL USING (true) WITH CHECK (true);
    END IF;

    -- Jenis
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_jenis' AND policyname = 'Allow read jenis') THEN
        CREATE POLICY "Allow read jenis" ON public.prismo_master_jenis FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_jenis' AND policyname = 'Allow manage jenis') THEN
        CREATE POLICY "Allow manage jenis" ON public.prismo_master_jenis FOR ALL USING (true) WITH CHECK (true);
    END IF;

    -- Media
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_media' AND policyname = 'Allow read media') THEN
        CREATE POLICY "Allow read media" ON public.prismo_master_media FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_media' AND policyname = 'Allow manage media') THEN
        CREATE POLICY "Allow manage media" ON public.prismo_master_media FOR ALL USING (true) WITH CHECK (true);
    END IF;
END $$;
