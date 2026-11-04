import { desc } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoPublicationCalendar } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    const rows = await getDb()
      .select()
      .from(prismoPublicationCalendar)
      .orderBy(desc(prismoPublicationCalendar.updatedAt))

    return rows.map(row => ({
      id: row.id,
      source_type: row.sourceType,
      source_id: row.sourceId,
      judul: row.judul,
      unit: row.unit,
      cluster: row.cluster,
      pic: row.pic,
      bentuk_naskah: row.bentukNaskah,
      dokumen_url: row.dokumenUrl,
      publish_date: row.publishDate,
      channels: Array.isArray(row.channels) ? row.channels : [],
      channel_links: row.channelLinks || {},
      status_tayang: row.statusTayang,
      catatan_humas: row.catatanHumas,
      updated_by: row.updatedBy,
      updated_role: row.updatedRole,
      created_at: row.createdAt,
      updated_at: row.updatedAt,
    }))
  } catch (error: any) {
    console.error('[API] Gagal membaca prismo_publication_calendar:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Gagal membaca data kalender publikasi.'
    })
  }
})
