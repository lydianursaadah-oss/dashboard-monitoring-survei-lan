import { sql } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoMasterClusters } from '../../db/schema'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const items = Array.isArray(body) ? body : [body]
  if (items.some(item => !item || typeof item.code !== 'string' || !item.code.trim() || typeof item.name !== 'string' || !item.name.trim())) {
    throw createError({ statusCode: 400, statusMessage: 'Setiap cluster wajib memiliki code dan name.' })
  }

  const rows = items.map((c: any, idx: number) => ({
    code: c.code.trim(),
    name: c.name.trim(),
    description: c.description || '',
    colorHex: c.color || c.colorHex || '#2563eb',
    isPlaceholder: Boolean(c.isPlaceholder),
    isActive: c.active !== false && c.isActive !== false,
    legacyNames: Array.isArray(c.legacyNames) ? c.legacyNames : (c.legacy_names || []),
    sortOrder: Number(c.sortOrder || c.sort_order) || (idx + 1),
    updatedBy: c.updatedBy || c.updated_by || 'admin',
    updatedAt: new Date(),
  }))

  try {
    await getDb().insert(prismoMasterClusters).values(rows).onConflictDoUpdate({
      target: prismoMasterClusters.code,
      set: {
        name: sql`excluded.name`,
        description: sql`excluded.description`,
        colorHex: sql`excluded.color_hex`,
        isPlaceholder: sql`excluded.is_placeholder`,
        isActive: sql`excluded.is_active`,
        legacyNames: sql`excluded.legacy_names`,
        sortOrder: sql`excluded.sort_order`,
        updatedBy: sql`excluded.updated_by`,
        updatedAt: sql`excluded.updated_at`,
      },
    })
    return { success: true, count: rows.length }
  } catch (error: any) {
    console.error('[API] Gagal menyimpan prismo_master_clusters:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: error.statusMessage || 'Gagal menyimpan master cluster.' })
  }
})
