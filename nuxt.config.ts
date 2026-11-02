export default defineNuxtConfig({
  compatibilityDate: '2025-10-30',
  devtools: { enabled: false },
  modules: ['@nuxtjs/tailwindcss'],
  tailwindcss: {
    cssPath: ['~/assets/css/main.css', { injectPosition: 'first' }],
    configPath: 'tailwind.config',
    viewer: false,
  },
  app: {
    head: {
      title: 'Monitoring Publikasi Survei LAN RI',
      htmlAttrs: { lang: 'id' },
      link: [{ rel: 'icon', type: 'image/png', href: '/favicon.png' }],
    },
  },
})
