import { getDb } from '../../db'
import { publikasi } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const items = Array.isArray(body) ? body : [body]
  if (!items.length || items.some(item => !item || typeof item.unit !== 'string' || !item.unit.trim() || typeof item.judul !== 'string' || !item.judul.trim())) {
    throw createError({ statusCode: 400, statusMessage: 'Setiap data publikasi wajib memiliki unit dan judul.' })
  }
  try {
    const rows = items.map((item: any) => ({
      ...(item.id ? { id: Number(item.id) } : {}),
      no: item.no == null ? null : Number(item.no),
      unit: String(item.unit), judul: String(item.judul),
      jenis: item.jenis ?? '', jadwal: item.jadwal ?? '', tahun: item.tahun == null ? '2026' : String(item.tahun),
      cluster: item.cluster ?? '', jurnal: item.jurnal ?? '', media: item.media ?? '',
      webLan: item.webLan ?? item.web_lan ?? '', webUnit: item.webUnit ?? item.web_unit ?? '',
      igLan: item.igLan ?? item.ig_lan ?? '', igUnit: item.igUnit ?? item.ig_unit ?? '',
      ytLan: item.ytLan ?? item.yt_lan ?? '', ytUnit: item.ytUnit ?? item.yt_unit ?? '', ket: item.ket ?? '',
    }))
    await getDb().insert(publikasi).values(rows)
    return { ok: true, saved: rows.length }
  } catch (error) {
    console.error('[API] Gagal menambah publikasi:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menyimpan data publikasi.' })
  }
})
