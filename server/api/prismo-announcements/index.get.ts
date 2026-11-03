import { desc } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoAnnouncements } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    const rows = await getDb().select().from(prismoAnnouncements).orderBy(desc(prismoAnnouncements.id))
    return rows.map(row => ({
      id: row.id,
      title: row.title,
      desc: row.description,
      date: row.date,
      kategori: row.kategori,
      target_type: row.targetType,
      target_value: row.targetValue,
      status: row.status,
      start_date: row.startDate,
      end_date: row.endDate,
      attachment_url: row.attachmentUrl,
      author: row.author,
      author_role: row.authorRole,
      created_at: row.createdAt,
      updated_at: row.updatedAt,
    }))
  } catch (error: any) {
    console.error('[API] Gagal membaca prismo_announcements:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.statusMessage || 'Gagal membaca data pengumuman.'
    })
  }
})
