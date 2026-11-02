import { asc } from 'drizzle-orm'
import { getDb } from '../../db'
import { users } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    return await getDb().select().from(users).orderBy(asc(users.username))
  } catch (error: any) {
    console.error('[API] Gagal membaca users:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: error.statusMessage || 'Gagal membaca akun pengguna.' })
  }
})
