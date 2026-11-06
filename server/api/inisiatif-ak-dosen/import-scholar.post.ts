import { getDb } from '../../db'
import { inisiatifAkDosen } from '../../db/schema'
import { PRESET_SCHOLAR_PROFILES } from './scholar-presets'

interface ScholarArticle {
  judul: string
  link: string
  authors: string
  venue: string
  tahun: number | null
  citations: number
  catatan?: string
}

function filterScholarArticles(articles: ScholarArticle[]): ScholarArticle[] {
  return articles.filter(article => Number.isInteger(article.tahun) && article.tahun! >= 2020 && article.tahun! <= 2026)
}

function normalizePresetArticle(article: any): ScholarArticle {
  const note = String(article.catatan || '')
  const authorsFromNote = note.match(/Penulis:\s*(.*?)\.\s*Diterbitkan:/i)?.[1]?.trim() || ''
  const venueFromNote = note.match(/Diterbitkan:\s*(.*?)\.\s*Dikutip:/i)?.[1]?.trim() || ''
  const citationsFromNote = note.match(/Dikutip:\s*(\d+)\s*kali/i)?.[1]
  const year = article.tahun == null || article.tahun === '' ? null : Number(article.tahun)

  return {
    judul: String(article.judul || '').trim(),
    link: String(article.link || article.jurnal || '').trim(),
    authors: String(article.authors || authorsFromNote).trim(),
    venue: String(article.venue || venueFromNote.replace(/[,\s]+20\d{2}$/, '')).trim(),
    tahun: year !== null && Number.isInteger(year) ? year : null,
    citations: Number.isFinite(Number(article.citations)) ? Number(article.citations) : Number(citationsFromNote || 0),
    catatan: note
  }
}

function extractUserId(input: string): string | null {
  const trimmed = input.trim()
  if (!trimmed) return null
  const urlMatch = trimmed.match(/[?&]user=([a-zA-Z0-9_-]+)/)
  if (urlMatch) return urlMatch[1]
  if (/^[a-zA-Z0-9_-]{12}$/.test(trimmed)) return trimmed
  return null
}

function parseScholarHtml(html: string): { name: string; affiliation: string; articles: ScholarArticle[] } {
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

    const citesMatch = r.match(/<a\b(?=[^>]*\bclass=["'][^"']*\bgsc_a_ac\b[^"']*["'])[^>]*>\s*([\d,]+)\s*<\/a>/i)
    const citations = citesMatch ? parseInt(citesMatch[1].replace(/,/g, ''), 10) : 0

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
    throw new Error(`Google Scholar HTTP ${response.status}`)
  }

  const html = await response.text()
  return parseScholarHtml(html)
}

async function searchOpenAlexFallback(query: string): Promise<{ name: string; affiliation: string; articles: ScholarArticle[] }> {
  const authorRes = await fetch(`https://api.openalex.org/authors?filter=display_name.search:${encodeURIComponent(query)}`)
  if (!authorRes.ok) throw new Error('OpenAlex API unavailable')
  const authorData = await authorRes.json()
  const author = authorData?.results?.[0]
  if (!author) throw new Error('Peneliti tidak ditemukan di OpenAlex')

  const authorName = author.display_name || query
  const affiliation = author.affiliations?.[0]?.institution?.display_name || 'Lembaga Administrasi Negara'

  const worksRes = await fetch(`https://api.openalex.org/works?filter=author.id:${author.id}&per-page=100`)
  if (!worksRes.ok) throw new Error('Gagal memuat publikasi dari OpenAlex')
  const worksData = await worksRes.json()

  const articles: ScholarArticle[] = (worksData?.results || []).map((w: any) => {
    const authors = (w.authorships || []).map((a: any) => a.author?.display_name).filter(Boolean).join(', ')
    const venue = w.primary_location?.source?.display_name || w.host_venue?.name || ''
    const citations = w.cited_by_count || 0
    return {
      judul: w.title || 'Untitled',
      link: w.doi || w.primary_location?.landing_page_url || `https://openalex.org/${w.id}`,
      authors,
      venue,
      tahun: w.publication_year || null,
      citations,
      catatan: `Penulis: ${authors}. Diterbitkan: ${venue || '-'}. Dikutip: ${citations} kali.`
    }
  })

  return { name: authorName, affiliation, articles }
}

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  if (!body || typeof body !== 'object') {
    throw createError({ statusCode: 400, statusMessage: 'Payload permintaan tidak valid.' })
  }

  const action = body.action || 'preview'

  // ACTION: PREVIEW
  if (action === 'preview') {
    // 1. Direct HTML paste
    if (body.html && typeof body.html === 'string' && body.html.length > 50) {
      const parsed = parseScholarHtml(body.html)
      const articles = filterScholarArticles(parsed.articles)
      if (articles.length > 0) {
        return {
          ok: true,
          userId: 'custom_html',
          name: parsed.name,
          affiliation: parsed.affiliation,
          total: articles.length,
          articles
        }
      }
    }

    const rawUrl = body.url || body.userId
    if (!rawUrl || typeof rawUrl !== 'string') {
      throw createError({ statusCode: 400, statusMessage: 'URL atau ID profil Google Scholar wajib disertakan.' })
    }

    const userId = extractUserId(rawUrl)
    
    // Coba ambil profil terbaru agar penulis, jurnal, dan sitasi berasal dari Google Scholar.
    if (userId) {
      try {
        const data = await scrapeScholarProfile(userId)
        const articles = filterScholarArticles(data.articles)
        if (articles.length > 0) {
          return {
            ok: true,
            userId,
            name: data.name,
            affiliation: data.affiliation,
            total: articles.length,
            articles
          }
        }
      } catch (err) {
        console.warn('[API Scholar] Direct scrape gagal (biasanya 403 cloud IP), mencoba OpenAlex fallback...', err)
      }
    }

    // Fallback ke snapshot profil bila Google Scholar membatasi akses server.
    if (userId && PRESET_SCHOLAR_PROFILES[userId]) {
      const preset = PRESET_SCHOLAR_PROFILES[userId]
      const articles = filterScholarArticles(preset.articles.map(normalizePresetArticle))
      if (articles.length > 0) {
        return {
          ok: true,
          userId,
          name: preset.name,
          affiliation: preset.affiliation,
          total: articles.length,
          articles
        }
      }
    }

    // 4. Fallback ke OpenAlex API jika direct scrape diblokir Google
    const searchQuery = body.name || rawUrl.replace(/https?:\/\/[^/]+\//, '').replace(/[^a-zA-Z\s]/g, ' ').trim()
    if (searchQuery) {
      try {
        const openAlexData = await searchOpenAlexFallback(searchQuery)
        const articles = filterScholarArticles(openAlexData.articles)
        if (articles.length > 0) {
          return {
            ok: true,
            userId: userId || 'openalex',
            name: openAlexData.name,
            affiliation: openAlexData.affiliation,
            total: articles.length,
            articles,
            source: 'openalex'
          }
        }
      } catch (oaErr) {
        console.warn('[API Scholar] OpenAlex fallback gagal:', oaErr)
      }
    }

    throw createError({
      statusCode: 400,
      statusMessage: 'Google Scholar membatasi akses server cloud (403). Gunakan tombol "Contoh Cepat" atau tempel kode sumber/HTML profil.'
    })
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
    const inRangeArticles = articles.filter((article: any) => {
      const year = Number(article?.tahun)
      return Number.isInteger(year) && year >= 2020 && year <= 2026
    })
    if (inRangeArticles.length === 0) {
      throw createError({ statusCode: 400, statusMessage: 'Hanya publikasi tahun 2020–2026 yang dapat disimpan.' })
    }

    const researcherName = body.researcherName ? String(body.researcherName).trim() : ''
    const cluster1 = body.cluster1 ? String(body.cluster1).trim() : 'Tata Kelola & Manajemen ASN'
    const cluster2 = body.cluster2 ? String(body.cluster2).trim() : ''
    const sourceSheet = researcherName ? `Google Scholar (${researcherName})` : `Google Scholar - ${unit}`

    const rowsToInsert = inRangeArticles.map((art: any, index: number) => {
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
