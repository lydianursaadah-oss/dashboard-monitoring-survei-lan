import { sql } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoProposals } from '../../db/schema'

const dateOrNull = (value: unknown) => typeof value === 'string' && /^\d{4}-\d{2}-\d{2}/.test(value) ? value.slice(0, 10) : null

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  if (!Array.isArray(body) || body.some(item => !item || typeof item.id !== 'string' || !item.id.trim() || typeof item.judul !== 'string' || !item.judul.trim() || typeof item.unit !== 'string' || !item.unit.trim())) {
    throw createError({ statusCode: 400, statusMessage: 'Setiap pengajuan wajib memiliki id, judul, dan unit.' })
  }

  const rows = body.map((proposal: any) => ({
    id: proposal.id,
    judul: proposal.judul,
    unit: proposal.unit,
    jenis: proposal.jenis || 'Survei',
    cluster: proposal.cluster || null,
    latarBelakang: proposal.latar_belakang || null,
    tujuan: proposal.tujuan || null,
    pic: proposal.pic || null,
    targetSelesai: dateOrNull(proposal.target_selesai),
    jadwal: proposal.jadwal || null,
    tahun: Number(proposal.tahun) || 2026,
    dokumenProposal: proposal.dokumen_proposal || null,
    dokumenJadwal: proposal.dokumen_jadwal || null,
    status: proposal.status || 'diajukan',
    diajukanTgl: dateOrNull(proposal.diajukan_tgl) || new Date().toISOString().slice(0, 10),
    diverifikasiTgl: dateOrNull(proposal.diverifikasi_tgl),
    disetujuiTgl: dateOrNull(proposal.disetujui_tgl),
    checklistAdmin: proposal.checklist_admin && typeof proposal.checklist_admin === 'object' ? proposal.checklist_admin : {},
    catatanAdmin: proposal.catatan_admin || '',
    keputusanKepala: proposal.keputusan_kepala || null,
    catatanKepala: proposal.catatan_kepala || '',
    catatanRevisi: proposal.catatan_revisi || '',
    riwayat: Array.isArray(proposal.riwayat) ? proposal.riwayat : [],
    updatedAt: new Date(),
  }))

  try {
    await getDb().insert(prismoProposals).values(rows).onConflictDoUpdate({
      target: prismoProposals.id,
      set: {
        judul: sql`excluded.judul`, unit: sql`excluded.unit`, jenis: sql`excluded.jenis`,
        cluster: sql`excluded.cluster`, latarBelakang: sql`excluded.latar_belakang`,
        tujuan: sql`excluded.tujuan`, pic: sql`excluded.pic`, targetSelesai: sql`excluded.target_selesai`,
        jadwal: sql`excluded.jadwal`, tahun: sql`excluded.tahun`, dokumenProposal: sql`excluded.dokumen_proposal`,
        dokumenJadwal: sql`excluded.dokumen_jadwal`, status: sql`excluded.status`,
        diajukanTgl: sql`excluded.diajukan_tgl`, diverifikasiTgl: sql`excluded.diverifikasi_tgl`,
        disetujuiTgl: sql`excluded.disetujui_tgl`, checklistAdmin: sql`excluded.checklist_admin`,
        catatanAdmin: sql`excluded.catatan_admin`, keputusanKepala: sql`excluded.keputusan_kepala`,
        catatanKepala: sql`excluded.catatan_kepala`, catatanRevisi: sql`excluded.catatan_revisi`,
        riwayat: sql`excluded.riwayat`, updatedAt: new Date(),
      },
    })
    return { ok: true, saved: rows.length }
  } catch (error) {
    console.error('[API] Gagal menyimpan prismo_proposals:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menyimpan pengajuan ke database.' })
  }
})
