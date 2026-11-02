import { eq } from 'drizzle-orm'
import { getDb } from '../../db'
import { publikasi } from '../../db/schema'

const columns = {
  unit: 'unit', judul: 'judul', jenis: 'jenis', jadwal: 'jadwal',
  tahun: 'tahun', cluster: 'cluster', jurnal: 'jurnal', media: 'media',
  web_lan: 'webLan', web_unit: 'webUnit', ig_lan: 'igLan', ig_unit: 'igUnit',
  yt_lan: 'ytLan', yt_unit: 'ytUnit', ket: 'ket',
} as const

export default defineEventHandler(async (event) => {
  const no = Number(getRouterParam(event, 'no'))
  if (!Number.isInteger(no)) throw createError({ statusCode: 400, statusMessage: 'Nomor publikasi tidak valid.' })
  const body = await readBody(event)
  const set: Record<string, unknown> = {}
  for (const [key, property] of Object.entries(columns)) {
    const camelKey = key.replace(/_([a-z])/g, (_, char) => char.toUpperCase())
    if (Object.hasOwn(body || {}, key)) set[property] = body[key]
    else if (Object.hasOwn(body || {}, camelKey)) set[property] = body[camelKey]
  }
  if (!Object.keys(set).length) throw createError({ statusCode: 400, statusMessage: 'Tidak ada kolom publikasi yang diperbarui.' })
  try {
    await getDb().update(publikasi).set(set as any).where(eq(publikasi.no, no))
    return { ok: true }
  } catch (error) {
    console.error('[API] Gagal memperbarui publikasi:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal memperbarui data publikasi.' })
  }
})
