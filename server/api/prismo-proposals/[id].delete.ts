import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoProposals } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, statusMessage: 'ID pengajuan wajib diisi.' })
  try {
    await getDb().delete(prismoProposals).where(eq(prismoProposals.id, id))
    return { ok: true }
  } catch (error) {
    console.error('[API] Gagal menghapus prismo_proposals:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menghapus pengajuan.' })
  }
})
