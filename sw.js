/* ATHLETIX v2 · Service Worker (caché de archivos en el navegador)
   GitHub Pages solo deja guardar los archivos 10 minutos (Cache-Control: max-age=600) y no permite cambiarlo.
   Este Service Worker guarda en el navegador los archivos que no cambian para que las siguientes visitas
   no los vuelvan a descargar:
   - JS y CSS con huella (?v=...): primero la caché; si cambia el código cambia la huella y se descarga el nuevo.
   - Fuentes y fotos: primero la caché y se revisan en segundo plano (stale-while-revalidate).
   - Páginas HTML y version.js: primero la red (siempre la versión publicada); la caché solo si no hay internet.
   - La base de datos (Supabase) y cualquier otro dominio NO pasan por aquí: nunca se guardan datos del cliente. */
const CACHE = 'athletix-v2-archivos-1';

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys()
    .then((claves) => Promise.all(claves.filter((c) => c.startsWith('athletix-') && c !== CACHE).map((c) => caches.delete(c))))
    .then(() => self.clients.claim()));
});

const guardar = async (peticion, respuesta) => {
  if (!respuesta || !respuesta.ok || respuesta.type !== 'basic') return;
  const cache = await caches.open(CACHE);
  const url = new URL(peticion.url);
  // Al guardar una versión nueva de un JS o CSS se borra la anterior del mismo archivo
  if (url.searchParams.has('v')) {
    const viejas = await cache.keys();
    await Promise.all(viejas.filter((r) => { const u = new URL(r.url); return u.pathname === url.pathname && u.search !== url.search; }).map((r) => cache.delete(r)));
  }
  await cache.put(peticion, respuesta);
};

async function primeroCache(peticion) {
  const guardada = await caches.match(peticion);
  if (guardada) return guardada;
  const r = await fetch(peticion);
  guardar(peticion, r.clone());
  return r;
}
async function cacheYRevisar(peticion, evento) {
  const guardada = await caches.match(peticion);
  const red = fetch(peticion).then((r) => { guardar(peticion, r.clone()); return r; });
  if (guardada) { evento.waitUntil(red.catch(() => null)); return guardada; }
  return red;
}
async function primeroRed(peticion) {
  try {
    const r = await fetch(peticion);
    guardar(peticion, r.clone());
    return r;
  } catch (e) {
    const guardada = await caches.match(peticion, { ignoreSearch: peticion.mode === 'navigate' });
    if (guardada) return guardada;
    throw e;
  }
}

self.addEventListener('fetch', (e) => {
  const p = e.request;
  if (p.method !== 'GET') return;
  const url = new URL(p.url);
  if (url.origin !== self.location.origin) return;
  if (p.mode === 'navigate' || url.pathname.endsWith('.html') || url.pathname.endsWith('/version.js')) { e.respondWith(primeroRed(p)); return; }
  if (url.searchParams.has('v') && /\.(js|css)$/.test(url.pathname)) { e.respondWith(primeroCache(p)); return; }
  if (/\/(fuentes|img)\//.test(url.pathname)) { e.respondWith(cacheYRevisar(p, e)); return; }
});
