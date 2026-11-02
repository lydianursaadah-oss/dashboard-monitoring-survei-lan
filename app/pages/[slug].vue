<script setup lang="ts">
const route = useRoute()

const rolePages: Record<string, { title: string; label: string }> = {
  kepala: { title: 'Dashboard Kepala LAN RI', label: 'Halaman Kepala LAN RI' },
  deputi: { title: 'Dashboard Deputi', label: 'Halaman Deputi' },
}

const slug = computed(() => String(route.params.slug).toLowerCase())
const page = computed(() => rolePages[slug.value] || (
  /^[a-z0-9._-]{1,80}$/.test(slug.value)
    ? { title: `Dashboard ${slug.value}`, label: `Halaman pengguna ${slug.value}` }
    : undefined
))
const legacyUrl = computed(() => {
  if (slug.value === 'kepala' || slug.value === 'deputi') {
    return `/legacy/?role=${slug.value}`
  }
  return `/legacy/?role=user&username=${encodeURIComponent(slug.value)}`
})

if (!page.value) {
  throw createError({ statusCode: 404, statusMessage: 'Halaman role tidak ditemukan' })
}

useHead(() => ({ title: `${page.value?.title} — Monitoring Survei LAN RI` }))
</script>

<template>
  <main class="w-full h-[100dvh] overflow-hidden bg-slate-50">
    <iframe
      class="block w-full h-[100dvh] border-0"
      :src="legacyUrl"
      :title="page?.label || 'Halaman Monitoring Survei LAN RI'"
    />
  </main>
</template>

