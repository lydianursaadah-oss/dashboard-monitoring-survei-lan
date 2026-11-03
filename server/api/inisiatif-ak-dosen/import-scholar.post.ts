import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'

interface ScholarArticle {
  judul: string
  link: string
  authors: string
  venue: string
  tahun: number | null
  citations: number
  catatan?: string
}

function extractUserId(input: string): string | null {
  const trimmed = input.trim()
  if (!trimmed) return null
  const urlMatch = trimmed.match(/[?&]user=([a-zA-Z0-9_-]+)/)
  if (urlMatch) return urlMatch[1]
  if (/^[a-zA-Z0-9_-]{12}$/.test(trimmed)) return trimmed
  return null
}

async function scrapeScholarProfile(userId: string): Promise<{ name: string; affiliation: string; articles: ScholarArticle[] }> {
  const url = `https://scholar.google.co.id/citations?user=${encodeURIComponent(userId)}&hl=id&cstart=0&pagesize=100`
  const response = await fetch(url, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
    }
  })

  if (!response.ok) {
    throw createError({
      statusCode: response.status,
      statusMessage: `Gagal mengakses profil Google Scholar (Status: ${response.status})`
    })
  }

  const html = await response.text()

  // Parse Name & Affiliation
  const nameMatch = html.match(/<div id="gsc_prf_in">([^<]+)<\/div>/)
  const name = nameMatch ? nameMatch[1].trim() : 'Peneliti Google Scholar'

  const affMatch = html.match(/<div class="gsc_prf_il">([^<]+)<\/div>/)
  const affiliation = affMatch ? affMatch[1].trim() : ''

  // Parse Table
  const tbodyStart = html.indexOf('<tbody id="gsc_a_b">')
  const tbodyEnd = html.indexOf('</tbody>', tbodyStart)
  if (tbodyStart === -1 || tbodyEnd === -1) {
    return { name, affiliation, articles: [] }
  }

  const tbody = html.slice(tbodyStart, tbodyEnd)
  const rows = tbody.split('<tr class="gsc_a_tr">').slice(1)

  const articles: ScholarArticle[] = []

  for (const r of rows) {
    const titleMatch = r.match(/<a[^>]*href="([^"]+)"[^>]*class="gsc_a_at"[^>]*>([\s\S]*?)<\/a>/)
      || r.match(/<a[^>]*class="gsc_a_at"[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/)

    const link = titleMatch ? 'https://scholar.google.co.id' + titleMatch[1].replace(/&amp;/g, '&') : ''
    const judul = titleMatch ? titleMatch[2].replace(/<[^>]+>/g, '').trim() : ''

    const grays = [...r.matchAll(/<div class="gs_gray">([\s\S]*?)<\/div>/g)]
    const authors = grays[0] ? grays[0][1].replace(/<[^>]+>/g, '').trim() : ''
    const venue = grays[1] ? grays[1][1].replace(/<[^>]+>/g, '').trim() : ''

    const citesMatch = r.match(/<a class="gsc_a_ac[^"]*"[^>]*>([0-9]+)<\/a>/)
    const citations = citesMatch ? parseInt(citesMatch[1], 10) : 0

    const yearMatch = r.match(/<span class="gsc_a_h gsc_a_hc gs_ibl">([0-9]{4})<\/span>/)
    const tahun = yearMatch ? parseInt(yearMatch[1], 10) : null

    if (judul) {
      articles.push({
        judul,
        link,
        authors,
        venue,
        tahun,
        citations,
        catatan: `Penulis: ${authors}. Diterbitkan: ${venue || '-'}. Dikutip: ${citations} kali.`
      })
    }
  }

  return { name, affiliation, articles }
}

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  if (!body || typeof body !== 'object') {
    throw createError({ statusCode: 400, statusMessage: 'Payload permintaan tidak valid.' })
  }

  const action = body.action || 'preview'

  // ACTION: PREVIEW
  if (action === 'preview') {
    const rawUrl = body.url || body.userId
    if (!rawUrl || typeof rawUrl !== 'string') {
      throw createError({ statusCode: 400, statusMessage: 'URL atau ID profil Google Scholar wajib disertakan.' })
    }

    const userId = extractUserId(rawUrl)
    if (!userId) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Format URL Google Scholar tidak valid. Pastikan URL memuat parameter ?user=... (contoh: https://scholar.google.co.id/citations?user=0h2jYOUAAAAJ)'
      })
    }

    try {
      const data = await scrapeScholarProfile(userId)
      return {
        ok: true,
        userId,
        name: data.name,
        affiliation: data.affiliation,
        total: data.articles.length,
        articles: data.articles
      }
    } catch (err: any) {
      console.error('[API Scholar] Scrape error:', err)
      throw createError({
        statusCode: 500,
        statusMessage: `Gagal membaca Google Scholar: ${err?.message || 'Periksa koneksi atau URL profil'}`
      })
    }
  }

  // ACTION: SAVE
  if (action === 'save') {
    const unit = body.unit ? String(body.unit).trim() : ''
    const articles = body.articles
    if (!unit) {
      throw createError({ statusCode: 400, statusMessage: 'Unit kerja wajib dipilih.' })
    }
    if (!Array.isArray(articles) || articles.length === 0) {
      throw createError({ statusCode: 400, statusMessage: 'Pilih minimal satu artikel untuk disimpan.' })
    }

    const researcherName = body.researcherName ? String(body.researcherName).trim() : ''
    const cluster1 = body.cluster1 ? String(body.cluster1).trim() : 'Tata Kelola & Manajemen ASN'
    const cluster2 = body.cluster2 ? String(body.cluster2).trim() : ''
    const sourceSheet = researcherName ? `Google Scholar (${researcherName})` : `Google Scholar - ${unit}`

    const rowsToInsert = articles.map((art: any, index: number) => {
      const judul = String(art.judul || '').trim()
      const tahun = art.tahun != null && art.tahun !== '' ? Number(art.tahun) : null
      const jurnalLink = String(art.link || art.jurnal || '').trim()
      const catatanText = String(art.catatan || (art.authors ? `Penulis: ${art.authors}. Diterbitkan: ${art.venue || '-'}. Dikutip: ${art.citations || 0} kali.` : '')).trim()

      return {
        no: art.no != null ? Number(art.no) : (index + 1),
        unit,
        sourceSheet,
        judul,
        jenis: String(art.jenis || 'Jurnal/Penelitian Dosen').trim(),
        jadwalPublikasi: '',
        tahun: (tahun && !isNaN(tahun)) ? tahun : null,
        cluster1: String(art.cluster1 || cluster1).trim(),
        cluster2: String(art.cluster2 || cluster2).trim(),
        jurnal: jurnalLink,
        mediaOnline: '',
        websiteLan: '',
        websiteUnit: '',
        instagramLan: '',
        instagramUnit: '',
        youtubeLan: '',
        youtubeUnit: '',
        mediaTelevisi: '',
        catatan: catatanText
      }
    }).filter(r => r.judul.length > 0)

    try {
      const db = getDb()
      const inserted = await db.insert(inisiatifAkDosen).values(rowsToInsert).returning()
      return {
        ok: true,
        count: inserted.length,
        items: inserted
      }
    } catch (err: any) {
      console.error('[API Scholar] Insert error:', err)
      throw createError({
        statusCode: 500,
        statusMessage: `Gagal menyimpan ke database Supabase: ${err?.message || 'Terjadi kesalahan sistem'}`
      })
    }
  }

  throw createError({ statusCode: 400, statusMessage: `Aksi tidak dikenal: ${action}` })
})
