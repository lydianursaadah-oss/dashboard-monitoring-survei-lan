import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoPublicationCalendar } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const idParam = getRouterParam(event, 'id')
  if (!idParam) {
    throw createError({ statusCode: 400, statusMessage: 'ID jadwal publikasi tidak valid.' })
  }

  try {
    await getDb().delete(prismoPublicationCalendar).where(eq(prismoPublicationCalendar.id, decodeURIComponent(idParam)))
    return { ok: true, deleted: idParam }
  } catch (error: any) {
    console.error('[API] Gagal menghapus prismo_publication_calendar:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Gagal menghapus jadwal publikasi dari database.'
    })
  }
})
