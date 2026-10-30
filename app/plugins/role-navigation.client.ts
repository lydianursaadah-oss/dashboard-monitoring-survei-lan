const rolePaths: Record<string, string> = {
  kepala_lan: '/kepala',
  deputi: '/deputi',
}

function rolePath(role: unknown, username: unknown): string {
  if (typeof role === 'string' && rolePaths[role]) return rolePaths[role]
  if (typeof username === 'string' && /^[a-z0-9._-]{1,80}$/i.test(username)) {
    return `/${encodeURIComponent(username.toLowerCase())}`
  }
  return '/'
}

export default defineNuxtPlugin((nuxtApp) => {
  const onRoleLogin = (event: MessageEvent) => {
    if (event.origin !== window.location.origin) return
    if (event.data?.type !== 'prismo-role-login') return

    const path = rolePath(event.data.role, event.data.username)
    if (nuxtApp.$router.currentRoute.value.path !== path) {
      void nuxtApp.$router.replace(path)
    }
  }

  window.addEventListener('message', onRoleLogin)
  nuxtApp.hook('app:beforeUnmount', () => window.removeEventListener('message', onRoleLogin))
})
