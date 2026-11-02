import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { publikasi } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const no = Number(getRouterParam(event, 'no'))
  if (!Number.isInteger(no)) throw createError({ statusCode: 400, statusMessage: 'Nomor publikasi tidak valid.' })
  try {
    await getDb().delete(publikasi).where(eq(publikasi.no, no))
    return { ok: true }
  } catch (error) {
    console.error('[API] Gagal menghapus publikasi:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menghapus data publikasi.' })
  }
})
