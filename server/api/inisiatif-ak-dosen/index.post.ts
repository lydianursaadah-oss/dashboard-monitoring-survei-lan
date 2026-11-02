import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'

const optionalText = (value: unknown) => value == null ? '' : String(value).trim()

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  if (!body || typeof body.unit !== 'string' || !body.unit.trim() || typeof body.judul !== 'string' || !body.judul.trim()) {
    throw createError({ statusCode: 400, statusMessage: 'Unit dan judul wajib diisi.' })
  }
  const tahun = body.tahun == null || body.tahun === '' ? null : Number(body.tahun)
  if (tahun !== null && (!Number.isInteger(tahun) || tahun < 1900 || tahun > 2200)) {
    throw createError({ statusCode: 400, statusMessage: 'Tahun tidak valid.' })
  }
  try {
    const [saved] = await getDb().insert(inisiatifAkDosen).values({
      no: body.no == null || body.no === '' ? null : Number(body.no),
      unit: body.unit.trim(), sourceSheet: optionalText(body.sourceSheet) || body.unit.trim(),
      judul: body.judul.trim(), jenis: optionalText(body.jenis),
      jadwalPublikasi: optionalText(body.jadwalPublikasi), tahun,
      cluster1: optionalText(body.cluster1), cluster2: optionalText(body.cluster2),
      jurnal: optionalText(body.jurnal), mediaOnline: optionalText(body.mediaOnline),
      websiteLan: optionalText(body.websiteLan), websiteUnit: optionalText(body.websiteUnit),
      instagramLan: optionalText(body.instagramLan), instagramUnit: optionalText(body.instagramUnit),
      youtubeLan: optionalText(body.youtubeLan), youtubeUnit: optionalText(body.youtubeUnit),
      mediaTelevisi: optionalText(body.mediaTelevisi), catatan: optionalText(body.catatan),
    }).returning()
    return { ok: true, item: saved }
  } catch (error) {
    console.error('[API] Gagal menambah inisiatif AK/Dosen:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menyimpan data Inisiatif AK/Dosen.' })
  }
})
