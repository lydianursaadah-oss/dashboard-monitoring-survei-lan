import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoAnnouncements } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const role = String(getHeader(event, 'x-prismo-role') || '').toLowerCase()
  if (role !== 'admin_dspk2an') {
    throw createError({ statusCode: 403, statusMessage: 'Hanya Admin DSPK2AN yang dapat menghapus pengumuman.' })
  }

  const idParam = getRouterParam(event, 'id')
  const numId = Number(idParam)
  if (!numId) {
    throw createError({ statusCode: 400, statusMessage: 'ID pengumuman tidak valid.' })
  }

  try {
    await getDb().delete(prismoAnnouncements).where(eq(prismoAnnouncements.id, numId))
    return { ok: true, deleted: numId }
  } catch (error: any) {
    console.error('[API] Gagal menghapus prismo_announcements:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Gagal menghapus pengumuman dari database.'
    })
  }
})
