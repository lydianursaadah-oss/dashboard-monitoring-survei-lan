import { asc } from 'drizzle-orm'
import { getDb } from '../../db'
import { publikasi } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    return await getDb().select().from(publikasi).orderBy(asc(publikasi.no))
  } catch (error: any) {
    console.error('[API] Gagal membaca publikasi:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: error.statusMessage || 'Gagal membaca data publikasi.' })
  }
})
