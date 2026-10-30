-- =============================================================================
-- PRISMO — MIGRATION SCRIPT REVISI HASIL MEETING
-- File: supabase_migration_revisi_meeting.sql
-- Sifat: Non-Destructive & Idempotent (Aman dijalankan tanpa menghapus data lama)
-- PENTING: Jalankan script ini di Supabase SQL Editor HANYA SETELAH Anda
--          meninjau dan menyetujui rencana migrasi ini.
-- =============================================================================

-- 1. TABEL MASTER CLUSTER KEBIJAKAN (Revisi #2: Penyesuaian Clustering Kebijakan)
-- Menyimpan daftar cluster secara terpusat & configurable (menunggu daftar final
-- dari Humas / Pak Puji) beserta pemetaan (mapping) cluster lama agar data
-- historis tidak rusak.
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

-- Seed cluster eksisting + placeholder resmi tanpa mengubah data kegiatan lama
INSERT INTO public.prismo_master_clusters (code, name, description, color_hex, is_placeholder, is_active, legacy_names, sort_order)
VALUES
    ('CLUSTER_PENDING_HUMAS', 'Daftar cluster kebijakan final sedang disiapkan', 'Placeholder netral sementara sebelum daftar cluster resmi dari Humas & stakeholder terkait ditetapkan', '#64748b', true, true, '["Belum Ditentukan", "Lainnya", "[Menunggu Daftar Cluster Final Humas / Pak Puji]"]'::jsonb, 1),
    ('CLUSTER_ASN', 'Manajemen ASN & Birokrasi', 'Cluster historis Manajemen ASN & Reformasi Birokrasi', '#2563eb', false, true, '["Manajemen ASN & Birokrasi", "Manajemen ASN", "Tata Kelola & Manajemen ASN"]'::jsonb, 2),
    ('CLUSTER_PELAYANAN', 'Pelayanan Publik & Inovasi', 'Cluster historis Pelayanan Publik & Inovasi Daerah', '#059669', false, true, '["Pelayanan Publik & Inovasi", "Pelayanan Publik"]'::jsonb, 3),
    ('CLUSTER_EKONOMI', 'Ekonomi & Pembangunan Daerah', 'Cluster historis Ekonomi & Pembangunan Daerah', '#d97706', false, true, '["Ekonomi & Pembangunan Daerah", "Ekonomi Daerah"]'::jsonb, 4),
    ('CLUSTER_KOMPETENSI', 'Pengembangan Kompetensi', 'Cluster historis Pengembangan Kompetensi ASN', '#9333ea', false, true, '["Pengembangan Kompetensi", "Bangkom"]'::jsonb, 5)
ON CONFLICT (code) DO NOTHING;

-- 2. PENAMBAHAN KOLOM PADA TABEL KEGIATAN/PUBLIKASI (Revisi #1 & #3)
-- Menambahkan kolom pengingat keterlambatan & metadata Google Link TOR/Proposal
ALTER TABLE public.publikasi
    ADD COLUMN IF NOT EXISTS pic TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS alasan_terlambat TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS target_tanggal DATE,
    ADD COLUMN IF NOT EXISTS doc_proposal_url TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_nama TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_jenis TEXT DEFAULT 'TOR dan Proposal',
    ADD COLUMN IF NOT EXISTS doc_ket TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_access_status TEXT DEFAULT 'Belum dicek',
    ADD COLUMN IF NOT EXISTS doc_last_checked TIMESTAMP WITH TIME ZONE;

-- 3. PENAMBAHAN KOLOM PADA TABEL PRISMO_PROPOSALS (Revisi #1, #3, #8)
-- Jika tabel prismo_proposals sudah ada, tambahkan kolom pendukung secara aman
CREATE TABLE IF NOT EXISTS public.prismo_proposals (
    id TEXT PRIMARY KEY,
    judul TEXT NOT NULL,
    unit TEXT NOT NULL,
    deputi TEXT DEFAULT '',
    jenis TEXT DEFAULT '',
    cluster TEXT DEFAULT '',
    Output TEXT DEFAULT '',
    target_waktu TEXT DEFAULT '',
    target_tanggal DATE,
    pic TEXT DEFAULT '',
    alasan_terlambat TEXT DEFAULT '',
    status_global TEXT DEFAULT 'Menunggu Persetujuan',
    tahap_aktif INT DEFAULT 1,
    prioritas BOOLEAN DEFAULT false,
    doc_proposal TEXT DEFAULT '',
    doc_nama TEXT DEFAULT '',
    doc_jenis TEXT DEFAULT 'TOR dan Proposal',
    doc_ket TEXT DEFAULT '',
    doc_access_status TEXT DEFAULT 'Belum dicek',
    doc_last_checked TIMESTAMP WITH TIME ZONE,
    catatan_pimpinan JSONB DEFAULT '[]'::jsonb,
    riwayat_keputusan JSONB DEFAULT '[]'::jsonb,
    payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.prismo_proposals
    ADD COLUMN IF NOT EXISTS target_tanggal DATE,
    ADD COLUMN IF NOT EXISTS pic TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS alasan_terlambat TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_nama TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_jenis TEXT DEFAULT 'TOR dan Proposal',
    ADD COLUMN IF NOT EXISTS doc_ket TEXT DEFAULT '',
    ADD COLUMN IF NOT EXISTS doc_access_status TEXT DEFAULT 'Belum dicek',
    ADD COLUMN IF NOT EXISTS doc_last_checked TIMESTAMP WITH TIME ZONE,
    ADD COLUMN IF NOT EXISTS payload JSONB DEFAULT '{}'::jsonb,
    ADD COLUMN IF NOT EXISTS catatan_pimpinan JSONB DEFAULT '[]'::jsonb,
    ADD COLUMN IF NOT EXISTS riwayat_keputusan JSONB DEFAULT '[]'::jsonb;

-- 4. TABEL PENGUMUMAN (Revisi #4: Tambahkan Form Pengumuman)
CREATE TABLE IF NOT EXISTS public.prismo_announcements (
    id TEXT PRIMARY KEY,
    judul TEXT NOT NULL,
    isi TEXT NOT NULL,
    kategori TEXT DEFAULT 'Informasi Umum',
    target_tipe TEXT DEFAULT 'Semua pengguna', -- 'Semua pengguna', 'Pimpinan', 'Unit kerja tertentu', 'Role tertentu'
    target_detail TEXT DEFAULT 'Semua',
    status TEXT DEFAULT 'Terbit',              -- 'Draft', 'Terbit', 'Diarsipkan'
    tanggal_mulai DATE,
    tanggal_berakhir DATE,
    lampiran_url TEXT DEFAULT '',
    lampiran_nama TEXT DEFAULT '',
    created_by TEXT DEFAULT '',
    created_by_role TEXT DEFAULT '',
    updated_by TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 5. TABEL INTERNAL AUDIT LOG KEAMANAN (Revisi #7: Hapus Log dari Menu Operasional Admin,
--    Pertahankan Pencatatan Teknis Internal untuk Superadmin/Keamanan)
--    CATATAN KEAMANAN: Jangan pernah menyimpan password, token, atau secret di tabel ini.
CREATE TABLE IF NOT EXISTS public.prismo_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,      -- 'APPROVAL', 'DATA_CHANGE', 'SECURITY', 'RECOVERY', 'ERROR'
    actor_username TEXT DEFAULT '',
    actor_role TEXT DEFAULT '',
    target_entity TEXT DEFAULT '',
    target_id TEXT DEFAULT '',
    action_summary TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 6. KEBIJAKAN RLS (Row Level Security)
ALTER TABLE public.prismo_master_clusters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prismo_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prismo_audit_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_clusters' AND policyname = 'Read master clusters') THEN
        CREATE POLICY "Read master clusters" ON public.prismo_master_clusters FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_master_clusters' AND policyname = 'Manage master clusters') THEN
        CREATE POLICY "Manage master clusters" ON public.prismo_master_clusters FOR ALL USING (true) WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_announcements' AND policyname = 'Read announcements') THEN
        CREATE POLICY "Read announcements" ON public.prismo_announcements FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_announcements' AND policyname = 'Manage announcements') THEN
        CREATE POLICY "Manage announcements" ON public.prismo_announcements FOR ALL USING (true) WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_audit_logs' AND policyname = 'Insert audit logs') THEN
        CREATE POLICY "Insert audit logs" ON public.prismo_audit_logs FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'prismo_audit_logs' AND policyname = 'Superadmin read audit logs') THEN
        CREATE POLICY "Superadmin read audit logs" ON public.prismo_audit_logs FOR SELECT USING (true);
    END IF;
END $$;

-- 7. PENYESUAIAN LABEL ROLE KEPALA DEPUTI -> DEPUTI (Revisi #9)
-- TIDAK mengubah username, password, atau kode role ('deputi') agar autentikasi
-- dan hak akses tidak rusak. Hanya memperbarui label tampilan 'Kepala Deputi' -> 'Deputi'
-- secara opsional apabila dijalankan oleh DBA:
-- UPDATE public.users SET nama = REPLACE(nama, 'Kepala Deputi', 'Deputi') WHERE nama LIKE '%Kepala Deputi%';

-- 8. KESAMAAN CAKUPAN AKSES & KEWENANGAN DEPUTI DENGAN KEPALA LAN (Revisi #10)
-- Fungsi helper otorisasi di level database untuk memvalidasi bahwa role 'deputi'
-- dan 'kepala_lan' sama-sama memiliki hak akses seluruh unit ('ALL') serta kewenangan
-- Review/ACC pimpinan, sedangkan 'admin_unit' hanya terbatas pada unit kerjanya sendiri.
CREATE OR REPLACE FUNCTION public.prismo_has_executive_access(p_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT lower(coalesce(p_role, '')) IN ('kepala_lan', 'deputi', 'superadmin');
$$;

CREATE OR REPLACE FUNCTION public.prismo_can_access_unit(p_role TEXT, p_user_unit TEXT, p_record_unit TEXT)
RETURNS BOOLEAN
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE
        WHEN lower(coalesce(p_role, '')) IN ('kepala_lan', 'deputi', 'admin_dspk2an', 'humas', 'superadmin') THEN true
        WHEN lower(coalesce(p_role, '')) = 'admin_unit' THEN
            coalesce(p_user_unit, '') <> '' AND position(lower(p_user_unit) in lower(coalesce(p_record_unit, ''))) > 0
        ELSE false
    END;
$$;

