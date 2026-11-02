import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { users } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const username = getRouterParam(event, 'username')
  if (!username) throw createError({ statusCode: 400, statusMessage: 'Username wajib diisi.' })
  try {
    await getDb().delete(users).where(eq(users.username, username))
    return { ok: true }
  } catch (error) {
    console.error('[API] Gagal menghapus users:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menghapus akun pengguna.' })
  }
})
