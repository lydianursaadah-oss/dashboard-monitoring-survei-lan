import { sql } from 'drizzle-orm'
import { getDb } from '../../db'
import { users } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const items = Array.isArray(body) ? body : [body]
  if (!items.length || items.some(item => !item || !item.username || !item.password || !item.nama || !item.jabatan || !item.unit || !item.role)) {
    throw createError({ statusCode: 400, statusMessage: 'Setiap akun wajib memiliki username, password, nama, jabatan, unit, dan role.' })
  }

  try {
    const rows = items.map((item: any) => ({
      ...(item.id ? { id: Number(item.id) } : {}),
      username: String(item.username).trim(),
      password: String(item.password),
      nama: String(item.nama),
      jabatan: String(item.jabatan),
      unit: String(item.unit),
      role: String(item.role),
    }))
    await getDb().insert(users).values(rows).onConflictDoUpdate({
      target: users.username,
      set: {
        password: sql`excluded.password`, nama: sql`excluded.nama`, jabatan: sql`excluded.jabatan`,
        unit: sql`excluded.unit`, role: sql`excluded.role`,
      },
    })
    return { ok: true, saved: rows.length }
  } catch (error) {
    console.error('[API] Gagal menyimpan users:', error)
    throw createError({ statusCode: 500, statusMessage: 'Gagal menyimpan akun pengguna.' })
  }
})
