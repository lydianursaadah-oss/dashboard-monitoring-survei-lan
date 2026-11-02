import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const id = Number(getRouterParam(event, 'id'))
  if (!Number.isSafeInteger(id) || id < 1) {
    throw createError({ statusCode: 400, statusMessage: 'ID data tidak valid.' })
  }
  try {
    const [deleted] = await getDb().delete(inisiatifAkDosen).where(eq(inisiatifAkDosen.id, id)).returning()
    if (!deleted) {
      throw createError({ statusCode: 404, statusMessage: 'Data Inisiatif AK/Dosen tidak ditemukan.' })
    }
    return { ok: true, deleted }
  } catch (error: any) {
    if (error.statusCode) throw error
    console.error('[API] Gagal menghapus inisiatif AK/Dosen:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menghapus data Inisiatif AK/Dosen.' })
  }
})
