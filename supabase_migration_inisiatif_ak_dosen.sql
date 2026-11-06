create table if not exists public.inisiatif_ak_dosen (
  id bigserial primary key,
  no integer null,
  unit text not null,
  source_sheet text not null,
  judul text not null,
  jenis text null default ''::text,
  jadwal_publikasi text null default ''::text,
  tahun integer null,
  cluster_1 text null default ''::text,
  cluster_2 text null default ''::text,
  jurnal text null default ''::text,
  media_online text null default ''::text,
  website_lan text null default ''::text,
  website_unit text null default ''::text,
  instagram_lan text null default ''::text,
  instagram_unit text null default ''::text,
  youtube_lan text null default ''::text,
  youtube_unit text null default ''::text,
  media_televisi text null default ''::text,
  catatan text null default ''::text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint inisiatif_ak_dosen_source_sheet_no_key unique (source_sheet, no)
);

alter table public.inisiatif_ak_dosen
  add column if not exists sitasi integer not null default 0;

update public.inisiatif_ak_dosen
set sitasi = substring(catatan from 'Dikutip:[[:space:]]*([0-9]+)[[:space:]]*kali')::integer
where sitasi = 0
  and catatan ~ 'Dikutip:[[:space:]]*[0-9]+[[:space:]]*kali';
