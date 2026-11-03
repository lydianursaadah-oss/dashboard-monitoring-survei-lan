import { sql } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoAnnouncements } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const items = Array.isArray(body) ? body : [body]

  if (items.length === 0) {
    throw createError({ statusCode: 400, statusMessage: 'Data pengumuman tidak boleh kosong.' })
  }

  for (const item of items) {
    if (!item || !item.title || !String(item.title).trim()) {
      throw createError({ statusCode: 400, statusMessage: 'Judul pengumuman wajib diisi.' })
    }
    const role = String(item.author_role || item.authorRole || '').toLowerCase()
    if (role && role !== 'admin_dspk2an' && role !== 'superadmin') {
      throw createError({
        statusCode: 403,
        statusMessage: 'Hanya Admin DSPK2AN yang memiliki kewenangan untuk membuat atau mengubah pengumuman.'
      })
    }
  }

  const rows = items.map((item: any) => ({
    id: Number(item.id) || Date.now(),
    title: String(item.title).trim(),
    description: String(item.desc || item.description || '').trim(),
    date: item.date || new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' }),
    kategori: item.kategori || 'Umum',
    targetType: item.target_type || item.targetType || 'Semua pengguna',
    targetValue: item.target_value || item.targetValue || '',
    status: item.status || 'Terbit',
    startDate: item.start_date || item.startDate || null,
    endDate: item.end_date || item.endDate || null,
    attachmentUrl: item.attachment_url || item.attachmentUrl || '',
    author: item.author || 'Admin DSPK2AN',
    authorRole: 'admin_dspk2an',
    updatedAt: new Date(),
  }))

  try {
    await getDb().insert(prismoAnnouncements).values(rows).onConflictDoUpdate({
      target: prismoAnnouncements.id,
      set: {
        title: sql`excluded.title`,
        description: sql`excluded.description`,
        date: sql`excluded.date`,
        kategori: sql`excluded.kategori`,
        targetType: sql`excluded.target_type`,
        targetValue: sql`excluded.target_value`,
        status: sql`excluded.status`,
        startDate: sql`excluded.start_date`,
        endDate: sql`excluded.end_date`,
        attachmentUrl: sql`excluded.attachment_url`,
        author: sql`excluded.author`,
        authorRole: sql`excluded.author_role`,
        updatedAt: new Date(),
      },
    })
    return { ok: true, saved: rows.length }
  } catch (error: any) {
    console.error('[API] Gagal menyimpan prismo_announcements:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Gagal menyimpan pengumuman ke database.'
    })
  }
})
