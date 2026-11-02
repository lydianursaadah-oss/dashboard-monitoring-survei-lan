import { asc, eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  try {
    const db = getDb()
    const unit = typeof query.unit === 'string' ? query.unit.trim() : ''
    const base = db.select().from(inisiatifAkDosen)
    return await (unit
      ? base.where(eq(inisiatifAkDosen.unit, unit)).orderBy(asc(inisiatifAkDosen.tahun), asc(inisiatifAkDosen.no))
      : base.orderBy(asc(inisiatifAkDosen.unit), asc(inisiatifAkDosen.tahun), asc(inisiatifAkDosen.no)))
  } catch (error: any) {
    console.error('[API] Gagal membaca inisiatif AK/Dosen:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: 'Gagal membaca data Inisiatif AK/Dosen.' })
  }
})
