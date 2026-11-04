import { sql } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoPublicationCalendar } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const items = Array.isArray(body) ? body : [body]

  if (items.length === 0) {
    throw createError({ statusCode: 400, statusMessage: 'Data jadwal publikasi tidak boleh kosong.' })
  }

  for (const item of items) {
    if (!item || !item.id || !item.judul) {
      throw createError({ statusCode: 400, statusMessage: 'ID dan judul publikasi wajib diisi.' })
    }
    const role = String(item.updated_role || item.updatedRole || '').toLowerCase()
    if (role && role !== 'humas' && role !== 'superadmin' && role !== 'system') {
      throw createError({
        statusCode: 403,
        statusMessage: 'Hanya Humas LAN RI yang memiliki kewenangan untuk mengatur jadwal kalender publikasi.'
      })
    }
  }

  const rows = items.map((item: any) => ({
    id: String(item.id).trim(),
    sourceType: String(item.source_type || item.sourceType || 'raw'),
    sourceId: String(item.source_id || item.sourceId || item.id),
    judul: String(item.judul).trim(),
    unit: String(item.unit || '-').trim(),
    cluster: String(item.cluster || ''),
    pic: String(item.pic || ''),
    bentukNaskah: String(item.bentuk_naskah || item.bentukNaskah || 'Laporan Lengkap & Policy Brief'),
    dokumenUrl: String(item.dokumen_url || item.dokumenUrl || ''),
    publishDate: String(item.publish_date || item.publishDate || ''),
    channels: Array.isArray(item.channels) ? item.channels : [],
    channelLinks: (item.channel_links || item.channelLinks || {}) as Record<string, string>,
    statusTayang: String(item.status_tayang || item.statusTayang || 'terjadwal'),
    catatanHumas: String(item.catatan_humas || item.catatanHumas || ''),
    updatedBy: String(item.updated_by || item.updatedBy || 'Humas LAN RI'),
    updatedRole: 'humas',
    updatedAt: new Date(),
  }))

  try {
    await getDb().insert(prismoPublicationCalendar).values(rows).onConflictDoUpdate({
      target: prismoPublicationCalendar.id,
      set: {
        sourceType: sql`excluded.source_type`,
        sourceId: sql`excluded.source_id`,
        judul: sql`excluded.judul`,
        unit: sql`excluded.unit`,
        cluster: sql`excluded.cluster`,
        pic: sql`excluded.pic`,
        bentukNaskah: sql`excluded.bentuk_naskah`,
        dokumenUrl: sql`excluded.dokumen_url`,
        publishDate: sql`excluded.publish_date`,
        channels: sql`excluded.channels`,
        channelLinks: sql`excluded.channel_links`,
        statusTayang: sql`excluded.status_tayang`,
        catatanHumas: sql`excluded.catatan_humas`,
        updatedBy: sql`excluded.updated_by`,
        updatedRole: sql`excluded.updated_role`,
        updatedAt: new Date(),
      },
    })
    return { ok: true, saved: rows.length }
  } catch (error: any) {
    console.error('[API] Gagal menyimpan prismo_publication_calendar:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Gagal menyimpan jadwal kalender publikasi ke database.'
    })
  }
})
