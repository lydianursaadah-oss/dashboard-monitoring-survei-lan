import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'

const textFields = [
  'judul', 'jenis', 'cluster1', 'cluster2', 'jurnal', 'mediaOnline', 'websiteLan',
  'websiteUnit', 'instagramLan', 'instagramUnit', 'youtubeLan', 'youtubeUnit', 'catatan',
] as const

export default defineEventHandler(async (event) => {
  const id = Number(getRouterParam(event, 'id'))
  if (!Number.isSafeInteger(id) || id < 1) throw createError({ statusCode: 400, statusMessage: 'ID data tidak valid.' })
  const body = await readBody(event)
  const updates: Record<string, unknown> = { updatedAt: new Date() }
  for (const key of textFields) {
    if (Object.hasOwn(body || {}, key)) updates[key] = key === 'judul' ? String(body[key] || '').trim() : String(body[key] ?? '').trim()
  }
  if (Object.hasOwn(body || {}, 'tahun')) {
    const year = body.tahun == null || body.tahun === '' ? null : Number(body.tahun)
    if (year !== null && (!Number.isInteger(year) || year < 1900 || year > 2200)) {
      throw createError({ statusCode: 400, statusMessage: 'Tahun tidak valid.' })
    }
    updates.tahun = year
  }
  if (Object.hasOwn(updates, 'judul') && !updates.judul) throw createError({ statusCode: 400, statusMessage: 'Judul wajib diisi.' })
  try {
    const [saved] = await getDb().update(inisiatifAkDosen).set(updates as any).where(eq(inisiatifAkDosen.id, id)).returning()
    if (!saved) throw createError({ statusCode: 404, statusMessage: 'Data Inisiatif AK/Dosen tidak ditemukan.' })
    return { ok: true, item: saved }
  } catch (error: any) {
    if (error.statusCode) throw error
    console.error('[API] Gagal memperbarui inisiatif AK/Dosen:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal memperbarui data Inisiatif AK/Dosen.' })
  }
})
