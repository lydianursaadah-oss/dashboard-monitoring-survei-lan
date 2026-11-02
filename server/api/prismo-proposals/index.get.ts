import { asc } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoProposals } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    const rows = await getDb().select().from(prismoProposals).orderBy(asc(prismoProposals.id))
    return rows.map(row => ({
      ...row,
      latar_belakang: row.latarBelakang,
      target_selesai: row.targetSelesai,
      dokumen_proposal: row.dokumenProposal,
      dokumen_jadwal: row.dokumenJadwal,
      diajukan_tgl: row.diajukanTgl,
      diverifikasi_tgl: row.diverifikasiTgl,
      disetujui_tgl: row.disetujuiTgl,
      checklist_admin: row.checklistAdmin,
      catatan_admin: row.catatanAdmin,
      keputusan_kepala: row.keputusanKepala,
      catatan_kepala: row.catatanKepala,
      catatan_revisi: row.catatanRevisi,
      created_at: row.createdAt,
      updated_at: row.updatedAt,
    }))
  } catch (error: any) {
    console.error('[API] Gagal membaca prismo_proposals:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: error.statusMessage || 'Gagal membaca pengajuan.' })
  }
})
