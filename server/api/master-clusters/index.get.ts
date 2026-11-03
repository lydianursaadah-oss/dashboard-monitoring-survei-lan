import { asc } from 'drizzle-orm'
import { getDb } from '../../db'
import { prismoMasterClusters } from '../../db/schema'

export default defineEventHandler(async () => {
  try {
    const rows = await getDb().select().from(prismoMasterClusters).orderBy(asc(prismoMasterClusters.sortOrder))
    return rows.map(row => ({
      id: row.id,
      code: row.code,
      name: row.name,
      description: row.description,
      color: row.colorHex,
      isPlaceholder: row.isPlaceholder,
      active: row.isActive,
      legacyNames: Array.isArray(row.legacyNames) ? row.legacyNames : [],
      sortOrder: row.sortOrder,
      updatedBy: row.updatedBy,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    }))
  } catch (error: any) {
    console.error('[API] Gagal membaca prismo_master_clusters:', error)
    throw createError({ statusCode: error.statusCode || 500, statusMessage: error.statusMessage || 'Gagal membaca master cluster.' })
  }
})
