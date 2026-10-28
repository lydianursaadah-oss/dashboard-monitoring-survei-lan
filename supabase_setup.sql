-- ========================================================
-- SUPABASE DATABASE SETUP UNTUK SISTEM MONITORING PUBLIKASI LAN RI
-- ========================================================

-- 1. Buat Tabel Publikasi
CREATE TABLE IF NOT EXISTS publikasi (
  id BIGSERIAL PRIMARY KEY,
  no INT,
  unit TEXT NOT NULL,
  judul TEXT NOT NULL,
  jenis TEXT DEFAULT '',
  jadwal TEXT DEFAULT '',
  tahun TEXT DEFAULT '2026',
  cluster TEXT DEFAULT '',
  jurnal TEXT DEFAULT '',
  media TEXT DEFAULT '',
  web_lan TEXT DEFAULT '',
  web_unit TEXT DEFAULT '',
  ig_lan TEXT DEFAULT '',
  ig_unit TEXT DEFAULT '',
  yt_lan TEXT DEFAULT '',
  yt_unit TEXT DEFAULT '',
  ket TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE publikasi ENABLE ROW LEVEL SECURITY;

-- 3. Policy Akses (Bisa Dibaca Publik & Bisa Diupdate)
CREATE POLICY "Public Read" ON publikasi FOR SELECT USING (true);
CREATE POLICY "Public Insert" ON publikasi FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update" ON publikasi FOR UPDATE USING (true);
CREATE POLICY "Public Delete" ON publikasi FOR DELETE USING (true);

-- 4. Insert Data Awal (56 Data Publikasi LAN RI)
INSERT INTO publikasi (no, unit, judul, jenis, jadwal, tahun, cluster, jurnal, media, web_lan, web_unit, ig_lan, ig_unit, yt_lan, yt_unit, ket) VALUES
(1, 'SKPP', 'Survei Optimalisasi Akses Layanan Kesehatan', '', '2025', '2025', 'Prioritas Presiden', '', '', 'Link', 'Link 1|Link 2', '', 'Link 1|Link 2', '', '', ''),
(2, 'DAPKK', 'Survei Disrupsi Pekerjaan dan Keterampilan Strategis (Top Skills ASN)', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', 'Link', 'Link', '', 'Link', 'Link', '', ''),
(3, 'SKMP', 'Survei Indeks Kesehatan Organisasi (OHI)', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', 'Link', 'Link', '', 'Link', '', 'Link', ''),
(4, 'SKPP', 'Kemudahan Penanaman Modal di Daerah', '', '2025', '2025', 'Prioritas Presiden', '', '', 'Link', 'Link 1|Link 2', '', '', '', '', ''),
(5, 'SKTAN', 'Implementasi Penerapan Manajemen Talenta di Lingkungan Pemerintah Daerah Provinsi / Kabupaten / Kota di Indonesia', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', 'Link', 'Link 1|Link 2|Link 3|Link 4|Link 5|Link 6|Link 7', '', 'Link 1|Link 2', '', 'Link', ''),
(6, 'STIA JKT, STIA MKS, STIA BDG', 'Survei Birokrasi Melayani Outlook', '', '2025', '2025', 'Pelayanan Publik', '', '', '', 'Link', '', '', '', '', ''),
(7, 'DAPKK', 'Survei Future Jobs and Skills Sektor Ketahanan Pangan', '', '2025', '2025', 'Prioritas Presiden', '', '', 'Link', '', '', '', '', '', ''),
(8, 'SKMK', 'Survei Efektivitas Kinerja Jabatan Fungsional', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', 'Link', 'Link 1|Link 2', '', 'Link', '', '', ''),
(9, 'SKPP', '“Customer Journey” Pelayanan Publik Instansi Pemerintah', '', '2025', '2025', 'Pelayanan Publik', '', '', 'Link', 'Link 1|Link 2', '', '', '', '', ''),
(10, 'SKTAN', 'Persepsi Masyarakat dan Birokrasi terhadap kompetensi dan nilai ASN', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', '', 'Link 1|Link 2|Link 3|Link 4', '', '', '', '', ''),
(11, 'DAPKK', 'Survei Produktivitas Sektor Publik Pertanian dengan Pendekatan APO (Tanaman Padi dan Jagung)', '', '2025', '2025', 'Prioritas Presiden', '', '', 'Link', '', '', '', '', '', ''),
(12, 'SKMP', 'Survei Strategi Peningkatan Tata Kelola BUMDes berdasarkan potensi dan karakteristik wilayah', '', '2025', '2025', 'Prioritas Presiden', '', '', 'Link', 'Link', '', 'Link', '', 'Link', ''),
(13, 'SKMK', 'Survei Strategi Peningkatan Kinerja ASN di Era Efisiensi Anggaran', '', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', 'Link', 'Link 1|Link 2|Link 3', '', '', '', '', ''),
(14, 'STIA JKT', 'Flexible Working Arrangement untuk Pegawai Perempuan ASN dan Swasta', 'Jurnal/Penelitian Kolaborasi', '2025', '2025', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Materi sudah dipaparkan di depan DFT Australia. Sudah coba dikirim ke jurnal tapi belum diterima'),
(15, 'DAPKK', 'Ekosistem Inovasi', 'Buku', '2025', '2025', 'Digitalisasi', '', '', 'Link', '', '', '', '', '', ''),
(16, 'SKTAN', 'Survei persepsi alumni terkait dampak pelatihan kepemimpinan terhadap manajemen karir', 'Jurnal/Penelitian', 'Januari (1)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', 'Link', '', '', 'link', 'link', 'Selesai
dengan publikasi di Prosiding dan youtube'),
(17, 'STIA BDG', 'Survey Budaya Kerja ASN', '', 'Januari (4)', '2026', 'Tata Kelola & Manajemen ASN', '', '', 'Link', '', '', '', '', 'Link', 'Selesai
dengan publikasi di website lan dan podcast di youtube Poltek'),
(18, 'STIA MKS', 'Survei Kesiapan Pemerintah Desa/Kelurahan dalam Mengelola Koperasi Merah Putih', 'Policy Paper', 'Februari (3)', '2026', 'Prioritas Presiden', '', '', '', 'Link', '', '', 'Link 1|Link 2', 'Link 1|Link 2', 'Selesai
 dengan publikasi di website Poltek dan Podcast di LAN dan Poltek'),
(19, 'DSPK2AN', 'Survei Indonesia Leadership Outlook 2026', 'Laporan', 'Februari (4)', '2026', 'Digitalisasi', '', '', 'Link', 'Link', 'Link 1|Link 2', 'Link 1|Link 2', 'Link 1|Link 2|Link 3', 'Link 1|Link 2|Link 3', 'Selesai
 dengan publikasi di Website LAN, Instagram LAN & D1 (Infografis & Podcast), dan Youtube LAN (Podcast)'),
(20, 'STIA BDG', 'Difusi Inovasi', '', 'Maret (1)', '2026', 'Digitalisasi', '', '', 'Link', '', '', '', 'Link', 'Link', 'Selesai
 dengan publikasi di Website LAN dan Youtube LAN & Poltek (Podcast)'),
(21, 'DAPKK', 'Desain kelembagaan pengentasan kemiskinan', '', 'Maret (4)', '2026', 'Prioritas Presiden', '', '', 'Link', 'Link', 'Link 1|Link 2', 'Link 1|Link 2', 'Link 1|Link 2', 'Link 1|Link 2', 'Selesai
 dengan publikasi di Website LAN, Instagram LAN & D1 (Podcast), dan Youtube LAN (Podcast)'),
(22, 'SKMP', 'Kesiapan dan kebutuhan kompetensi ASN muda dalam mendukung komponen cadangan pertahanan negara', '', 'April (1)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', 'Link', '', '', 'Link', 'Link', 'Selesai
 dengan publikasi di Website (Media Berita Online) dan Youtube LAN dan Pusjar (Podcast)'),
(23, 'SKPP', 'Efektifitas layanan call center di daerah', '', 'April (3)', '2026', 'Pelayanan Publik', '', '', 'Link', 'Link 1|Link 2', '', 'Link', 'Link', 'Link', 'Selesai
 dengan publikasi di Website Pusjar & Online (Media Indonesia), Instagram Pusjar (Podcast), dan Youtube LAN & Pusjar (Podcast)'),
(24, 'STIA JKT, STIA MKS, STIA BDG', 'Birokrasi melayani outlook', '', 'Mei (1)', '2026', 'Pelayanan Publik', '', '', '', '', '', '', '', '', 'Belum Selesai
Belum dilanjutkan berhubung banyak kegiatan relatif bertumpuk'),
(25, 'SKMK', 'Survei Resiliensi ASN dalam situasi Krisis Bencana', '', 'Mei (2)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sudah disusun policy brief dan akan dilakukan webinar tgl 14 Oktober 2026'),
(26, 'DAPKK', 'Monitoring dan Evaluasi Sekolah Rakyat', '', 'Mei (4)', '2026', 'Prioritas Presiden', '', '', 'Link', 'Link', '', '', 'Link', 'Link', 'Selesai
dengan publikasi di Website LAN dan Youtube LAN (Podcast)'),
(27, 'SKMP', 'Strategi adaptasi fiskal Pemda terhadap pemangkasan dana transfer ke daerah dalam APBN 2026', '', 'Juni (1)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sudah dilakukan pengumpulan data namun belum ada penambahan jumlah responden (masih 28)'),
(28, 'STIA JKT', 'Survey Kualitatif Sistem Penilaian Integritas: Integritas Masih Sebatas Jargon?', 'Policy Brief', 'Juni (2)', '2026', 'Tata Kelola & Manajemen ASN', '', '', 'Link', '', 'Link', 'Link', 'Link', '', 'Selesai
dengan publikasi di Website LAN, Instagram LAN (Podcast), Instagram Unit & D1 (Podcast), dan Youtube LAN (Podcast)'),
(29, 'STIA MKS', 'Preferensi pilihan karier Gen Z untuk menjadi ASN', '', 'Juni (3)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dilakukan penyebaran instrumen survei.'),
(30, 'SKTAN', 'Preferensi pilihan karier ASN Gen Z', 'Policy Brief', 'Juli (1)', '2026', 'Tata Kelola & Manajemen ASN', '', 'Opini di Ayobandung Link 2', '', 'link', '', 'Instagram', 'Link', 'Link', 'Belum Selesai (Policy Paper & Publikasi).
  
 Publikasi baru di Instagram Pusjar & D1 (Infografis)'),
(31, 'SKMK', 'Survei Nasional Kesiapan ASN sebagai Policy Entrepreneur dalam Mendukung Program Prioritas Nasional 2026', '', 'Juli (2)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dilakukan penyempurnaan instrumen'),
(32, 'SKPP', 'Penguatan layanan tanggap bencana di daerah (skupnya nasional)', '', 'Juli (3)', '2026', 'Pelayanan Publik', '', '', 'Link', 'Link', '', 'Link', '', 'Link', 'Selesai dengan publikasi di Website Pusjar, Instagram Pusjar (Dokumentasi Webinar), dan Youtube Pusjar (Webinar).'),
(33, 'STIA JKT, STIA MKS, STIA BDG', 'Organizational Trend in Indonesia''s Public Sector: Mapping Change, Readiness, & Adaptive Capability', '', 'Agustus (1)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dilakukan penyusunan instrumen survei.'),
(34, 'SKPP', 'Pelayanan Publik Outlook', '', 'Agustus (2)', '2026', 'Pelayanan Publik', '', '', 'Link', '', '', 'Link', '', '', 'Selesai dengan publikasi di instagram'),
(35, 'SKTAN', 'Survei Kesiapan Operasional Koperasi Desa Merah Putih di Desa', '', 'Agustus (3)', '2026', 'Prioritas Presiden', '', '', '', '', '', 'Link', '', '', 'Belum Selesai
Sedang dilakukan review policy brief oleh Deputi'),
(36, 'SKMK', 'Menyusun proses bisnis continuity dan disaster recovery serta SOP darurat', '', 'Agustus (4)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dalam tahap penyempurnaan Policy Brief'),
(37, 'STIA MKS', 'Pemberantasan kemiskinan', '', 'September (1)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dilakukan penyebaran instrumen survei.'),
(38, 'DAPKK', 'Workplace trend', '', 'September (2)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', 'Link', '', '', 'Belum Selesai 
Sedang dilakukan pengolahan data'),
(39, 'SKTAN', 'Pelestarian lingkungan hidup (Bencana Sumatera Utara, Sumatera Barat dan Aceh)
Transformasi Kebijakan Lingkungan dari Instrumen menuju Dampak', 'Policy Brief', 'September (3)', '2026', 'Prioritas Presiden', '', '', '', '', '', 'link', '', '', 'Belum Selesai
Sedang dilakukan review policy brief oleh deputi'),
(40, 'DSPK2AN', 'Reformasi Tata Kelola Makan Bergizi Gratis (MBG): Dari Ekspansi Berbasis Target menjadi Pelayanan Gizi Berbasis Standar, Resiko dan Akuntabilitas', 'Policy Paper', 'September (4)', '2026', 'Prioritas Presiden', '', '', 'Link', 'Link', '', '', '', '', 'Selesai 
 dengan publikasi di Website LAN dan Website Unit'),
(41, 'SKPP', 'Fenomena Polyworking di kalangan ASN', '', 'September (4)', '2026', 'Tata Kelola & Manajemen ASN', '', 'link', 'Link', 'link', '', 'Link', '-', 'Link', 'Selesai 
dengan publikasi di Website Pusjar, Instagram Pusjar (Dokumentasi Webinar), dan Youtube Pusjar (Webinar)'),
(42, 'STIA JKT, STIA MKS, STIA BDG', 'Regenerative Leadership', '', 'Oktober (1)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dalam tahap persiapan'),
(43, 'SKMK', 'Evaluasi Kebijakan Makan Bergizi Gratis', '', 'Oktober (1)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', 'Belum Selesai
Sedang dilakukan penyusunan Policy Brief'),
(44, 'DSPK2AN', 'Penguatan Kebijakan Kedaulatan Pangan Nasional', 'Policy Brief', 'Oktober (2)', '2026', 'Prioritas Presiden', '', '', 'Link', 'Link', '', 'Link', '', '', 'Selesai
 dengan publikasi di Website Unit, website LAN & Instagram Unit'),
(45, 'SKMP', 'Persepsi ASN mengenai Upaya Penguatan/Pembentukan Lembaga Pengawas sistem merit', '', 'Oktober (2)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', ''),
(46, 'DAPKK', 'Survei Perilaku Kepemimpinan Adaptif Berdasarkan Persepsi Aparatur Sipil Negara', '', 'Oktober (3)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', ''),
(47, 'SKTAN', 'Ketahanan pangan sebagai fondasi kemandirian bangsa', '', 'Oktober (4)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', 'Sedang dilakukan penyusunan instrumen'),
(48, 'STIA JKT', 'Pendidikan bermutu untuk SDM berdaya saing global', '', 'November (1)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', ''),
(49, 'STIA BDG', 'Program Pemberdayaan dan Kesiapan Masa Depan Siswa Sekolah Rakyat', '', 'November (2)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', ''),
(50, 'SKMP', 'Persepsi masyarakat terhadap peran opini publik/agenda kebijakan pemerintah', '', 'November (3)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', ''),
(51, 'SKPP', 'Penguatan kebijakan ekonomi hijau dalam mendukung hilirisasi berkelanjutan', '', 'November (4)', '2026', 'Prioritas Presiden', '', 'link', '', '', '', 'Link', '', '', 'Sudah dilakukan ekspose kegiatan dan saat ini sedang disusun PB'),
(52, 'SKTAN', 'Learning agility ASN dalam mendukung Pendidikan vokasi, peningkatan kualitas guru dan kesesuaian kurikulum dunia kerja', '', 'Desember (1)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', 'Sedang dilakukan penyusunan instrumen'),
(53, 'SKPP', 'Survei Tata Kelola dan Kualitas Pelayanan Program Bantuan Sosial', '', 'Desember (1)', '', '', '', '', '', '', '', '', '', '', ''),
(54, 'DSPK2AN', 'Analisis Pemantauan dan Solusi atas Program Prioritas Nasional', '', 'Desember (2)', '2026', 'Prioritas Presiden', '', '', '', '', '', '', '', '', ''),
(55, 'SKPP', 'Survei Integrasi Pelayanan Publik', '', 'Desember (2)', '', '', '', '', '', '', '', '', '', '', ''),
(56, 'DSPK2AN', 'Survei Indonesia Leadership Outlook 2027', 'Laporan', 'Desember (3)', '2026', 'Tata Kelola & Manajemen ASN', '', '', '', '', '', '', '', '', '');
