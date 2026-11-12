/* ATHLETIX · Núcleo: estado, utilidades y componentes de interfaz reutilizables */
'use strict';

/* ======================= Estado ======================= */
// En el navegador (localStorage) se guardan el carrito, los favoritos y la última tienda de retiro. Las cuentas, pedidos, pagos y reseñas viven en la base de datos.
// Cada cuenta tiene sus propias claves (clave base + id del usuario); sin sesión se usa la clave base.
const CLAVE_CARRITO = 'athletix-carrito-v2';
const CLAVE_FAVORITOS = 'athletix-favoritos';
const CLAVE_ENTREGA = 'athletix-ultima-entrega';
const estado = {
  carrito: leerCarrito(CLAVE_CARRITO),
  favoritos: leerFavoritos(CLAVE_FAVORITOS),
  sesion: null,        // sesión de Supabase (usuario autenticado)
  cliente: null,       // fila de la tabla clientes
  esAdmin: false,
  googleActivo: false, // se activa solo si el proveedor Google está encendido en Supabase
  tiendas: [],
  catalogoConectado: false,
  errorCatalogo: '',
  invitado: { carrito: [], favoritos: [] }, // lo agregado sin sesión, para sumarlo a la cuenta al ingresar
  cuentaCargada: false  // true cuando el carrito y los favoritos de la cuenta ya se leyeron de la base
};

/* ---------- localStorage ---------- */
function leerLocal(clave) {
  try { return JSON.parse(localStorage.getItem(clave)); } catch (e) { return null; } // almacenamiento no disponible o dañado
}
function guardarLocal(clave, valor) {
  try { if (valor === null) localStorage.removeItem(clave); else localStorage.setItem(clave, JSON.stringify(valor)); } catch (e) { /* se mantiene en memoria */ }
}
// Clave propia de la cuenta que inició sesión (o la de invitado si no hay sesión)
const claveCuenta = (base) => (estado.sesion ? `${base}-${estado.sesion.user.id}` : base);

function leerCarrito(clave) {
  const c = leerLocal(clave);
  if (!Array.isArray(c)) return [];
  return c.filter((i) => i && typeof i.id === 'string' && Number.isInteger(i.cantidad) && i.cantidad >= 1 && i.cantidad <= 9999)
    .map((i) => ({ id: i.id, talla: i.talla ? String(i.talla) : null, cantidad: i.cantidad }));
}
function guardarCarrito() { guardarLocal(claveCuenta(CLAVE_CARRITO), estado.carrito); sincronizarCuenta('carrito'); }

function leerFavoritos(clave) {
  const f = leerLocal(clave);
  return Array.isArray(f) ? [...new Set(f.filter((id) => typeof id === 'string' && id.length <= 10))] : [];
}
function guardarFavoritos() { guardarLocal(claveCuenta(CLAVE_FAVORITOS), estado.favoritos); sincronizarCuenta('favoritos'); }

/* Con sesión, el carrito y los favoritos también se guardan en la base (tablas CARRITO y FAVORITO).
   Se espera un momento para juntar varios cambios seguidos en un solo envío. */
const esperasCuenta = {};
const CLAVE_CARRITO_COMPRADO = 'athletix-carrito-comprado';
function sincronizarCuenta(que) {
  if (!estado.cliente || !estado.cuentaCargada || typeof Api === 'undefined') return;
  clearTimeout(esperasCuenta[que]);
  esperasCuenta[que] = setTimeout(() => {
    const cedula = estado.cliente.cedula;
    if (que === 'carrito') Api.cuenta.guardarCarrito(cedula, estado.carrito.slice());
    else Api.cuenta.guardarFavoritos(cedula, estado.favoritos.slice());
  }, 400);
}
/* Al iniciar sesión: lo guardado en la cuenta (base) más lo que agregó sin sesión en este navegador */
async function cargarCuentaDesdeBase() {
  estado.cuentaCargada = false;
  if (!estado.cliente) return;
  const [rc, rf] = await Promise.all([Api.cuenta.carrito(), Api.cuenta.favoritos()]);
  if (rc.error || rf.error) return; // sin las tablas o sin conexión: se sigue con lo guardado en el navegador
  // Si la última compra no alcanzó a vaciar el carrito de la cuenta (se cerró la página o se cortó la conexión),
  // lo que quedó en la base ya fue comprado: no se vuelve a mostrar y se borra ahora
  if (leerLocal(claveCuenta(CLAVE_CARRITO_COMPRADO))) {
    rc.datos = [];
    const clave = claveCuenta(CLAVE_CARRITO_COMPRADO);
    Api.cuenta.vaciarCarrito(estado.cliente.cedula).then((r) => { if (!r.error) guardarLocal(clave, null); });
  }
  // Si la cuenta todavía no tiene nada en la base, se sube lo que ya había en este navegador
  const primeraVez = !rc.datos.length && !rf.datos.length && (estado.carrito.length || estado.favoritos.length);
  if (primeraVez) estado.invitado = { carrito: estado.carrito.slice(), favoritos: estado.favoritos.slice() };
  const carrito = rc.datos;
  (estado.invitado.carrito || []).forEach((l) => {
    const igual = carrito.find((x) => x.id === l.id && x.talla === l.talla);
    if (igual) igual.cantidad = Math.min(9999, igual.cantidad + l.cantidad); else carrito.push(l);
  });
  const favoritos = rf.datos;
  (estado.invitado.favoritos || []).forEach((id) => { if (!favoritos.includes(id)) favoritos.push(id); });
  const hayInvitado = (estado.invitado.carrito || []).length || (estado.invitado.favoritos || []).length;
  estado.invitado = { carrito: [], favoritos: [] };
  estado.carrito = carrito; estado.favoritos = favoritos;
  estado.cuentaCargada = true;
  guardarLocal(claveCuenta(CLAVE_CARRITO), carrito); guardarLocal(claveCuenta(CLAVE_FAVORITOS), favoritos);
  if (hayInvitado) { sincronizarCuenta('carrito'); sincronizarCuenta('favoritos'); }
}
const esFavorito = (id) => estado.favoritos.includes(id);
function alternarFavorito(id) {
  estado.favoritos = esFavorito(id) ? estado.favoritos.filter((x) => x !== id) : [...estado.favoritos, id];
  guardarFavoritos();
  return esFavorito(id);
}
function botonFavorito(p, clase = '', conTexto = false) {
  return `<button class="boton-favorito ${clase}" type="button" data-favorito="${p.id}" aria-pressed="${esFavorito(p.id)}" ${conTexto ? '' : `aria-label="Favorito: ${esc(p.nombre)}"`}>${icono('corazon')}${conTexto ? '<span>Guardar en favoritos</span>' : ''}</button>`;
}

/* Al iniciar o cerrar sesión se cambia al carrito y a los favoritos de esa cuenta.
   Lo que se agregó sin sesión se suma a la cuenta que ingresa. */
function cargarDatosDeCuenta() {
  const carrito = leerCarrito(claveCuenta(CLAVE_CARRITO));
  const favoritos = leerFavoritos(claveCuenta(CLAVE_FAVORITOS));
  if (estado.sesion) {
    // Lo agregado sin sesión se recuerda para sumarlo también a lo que la cuenta tiene en la base
    estado.invitado = { carrito: leerCarrito(CLAVE_CARRITO), favoritos: leerFavoritos(CLAVE_FAVORITOS) };
    leerCarrito(CLAVE_CARRITO).forEach((l) => {
      const igual = carrito.find((x) => x.id === l.id && x.talla === l.talla);
      if (igual) igual.cantidad = Math.min(9999, igual.cantidad + l.cantidad); else carrito.push(l);
    });
    leerFavoritos(CLAVE_FAVORITOS).forEach((id) => { if (!favoritos.includes(id)) favoritos.push(id); });
    guardarLocal(CLAVE_CARRITO, null);
    guardarLocal(CLAVE_FAVORITOS, null);
  }
  estado.carrito = carrito;
  estado.favoritos = favoritos;
  estado.cuentaCargada = false;
  guardarLocal(claveCuenta(CLAVE_CARRITO), carrito); guardarLocal(claveCuenta(CLAVE_FAVORITOS), favoritos);
}
function guardarTemporal(clave, valor) {
  try { if (valor === null) sessionStorage.removeItem(clave); else sessionStorage.setItem(clave, JSON.stringify(valor)); } catch (e) { /* sin almacenamiento */ }
}
function leerTemporal(clave) {
  try { return JSON.parse(sessionStorage.getItem(clave)); } catch (e) { return null; }
}

/* ======================= Seguir comprando ======================= */
// Se recuerda el último catálogo que vio la persona (categoría, género, precio, orden y búsqueda) y hasta
// dónde bajó, para que «Seguir comprando» la devuelva ahí y no a todos los productos.
function recordarCatalogo() {
  if ((location.pathname.split('/').pop() || '') !== 'productos.html') return;
  const p = new URLSearchParams(location.search); p.delete('v');
  guardarTemporal('catalogo-ultimo', p.toString() ? '?' + p : '');
}
function urlCatalogo() { return 'productos.html' + (leerTemporal('catalogo-ultimo') || ''); }
window.addEventListener('pagehide', () => {
  if ((location.pathname.split('/').pop() || '') === 'productos.html') guardarTemporal('catalogo-scroll', Math.round(window.scrollY));
});
// Los enlaces «Seguir comprando» (clase seguir-comprando) piden volver a la misma altura del catálogo
document.addEventListener('click', (e) => {
  const a = e.target.closest && e.target.closest('a.seguir-comprando');
  if (a) guardarTemporal('catalogo-volver', true);
});
function restaurarCatalogo() {
  if (!leerTemporal('catalogo-volver')) return;
  guardarTemporal('catalogo-volver', null);
  const y = Number(leerTemporal('catalogo-scroll')) || 0;
  if (y > 0) requestAnimationFrame(() => window.scrollTo(0, y));
}

/* ======================= Volver después de iniciar sesión ======================= */
// Solo se vuelve a páginas de la propia tienda (nunca a un enlace externo ni a las páginas de ingreso)
const NO_VOLVER = /^(login|registro|recuperar|completar-perfil|nueva-clave|confirmar-correo|cambiar-clave|404)\.html/;
function volverSeguro(v) {
  v = String(v || '');
  if (v === 'retiro') return 'retiro.html';
  return /^[a-z0-9-]+\.html(\?[\w=&%.+-]*)?$/.test(v) && !NO_VOLVER.test(v) ? v : '';
}
function paginaActual() { return (location.pathname.split('/').pop() || 'index.html') + location.search; }
function conVolver(pagina, volver) { const v = volverSeguro(volver); return v && v !== 'index.html' ? `${pagina}?volver=${encodeURIComponent(v)}` : pagina; }
// A dónde volver después de confirmar el correo o de entrar con Google. Se guarda en localStorage (2 horas)
// porque el enlace de confirmación se abre en otra pestaña: así, si estaba comprando, sigue con la tienda de retiro.
function guardarVolverPendiente(v) {
  try { if (v) localStorage.setItem('athletix-volver', JSON.stringify({ v, t: Date.now() })); else localStorage.removeItem('athletix-volver'); } catch (e) { /* sin almacenamiento */ }
}
function leerVolverPendiente() {
  try { const x = JSON.parse(localStorage.getItem('athletix-volver')); return x && Date.now() - x.t < 2 * 3600 * 1000 ? volverSeguro(x.v) : ''; } catch (e) { return ''; }
}
// Última página de la tienda que vio la persona. Al iniciar sesión o crear la cuenta se vuelve ahí, aunque
// haya entrado por «Ingresar» del encabezado. Si estaba en su carrito con productos, sigue con la compra.
function recordarPagina() {
  const p = new URLSearchParams(location.search); p.delete('v');
  const v = volverSeguro((location.pathname.split('/').pop() || 'index.html') + (p.toString() ? '?' + p : ''));
  if (v) guardarTemporal('ultima-pagina', v);
}
function paginaPrevia() {
  const v = volverSeguro(leerTemporal('ultima-pagina'));
  if (/^carrito\.html/.test(v) && estado.carrito.length) return 'retiro.html';
  return v;
}
// Al iniciar sesión se vuelve a donde estaba (seguir con la compra, una página de su cuenta, el catálogo
// con su filtro o el enlace de reseña de un correo); si no hay a dónde, a la portada.
// Si todavía no completó su perfil (por ejemplo, entró con Google por primera vez): se le pide solo cuando lo necesita
// (al comprar o al ver su cuenta); si no, vuelve a donde estaba y completa el perfil en su primera compra.
const PIDE_PERFIL = /^(retiro|pago|confirmacion|pedidos|perfil|metodos-pago|orden)\.html/;
function destinoSinPerfil(volver) {
  const v = volverSeguro(volver);
  if (!v) return 'index.html';
  return PIDE_PERFIL.test(v) || /[?&]resenar=1/.test(v) ? conVolver('completar-perfil.html', v) : v;
}
function destinoTrasIngreso(volver) {
  const v = volverSeguro(volver);
  if (v === 'retiro.html') return estado.carrito.length ? 'retiro.html' : 'carrito.html';
  return v || 'index.html';
}

/* ======================= Tiempo de retiro ======================= */
/* Igual que en la base (crear_pedido): de 1 a 3 horas según cuánto y qué se pide.
   60 min + 10 por unidad desde la 4.ª + 15 por producto distinto desde el 3.º + 20 si hay calzado + 20 si hay tecnología */
function minutosRetiro(lineas) {
  let unidades = 0, calzado = false, tecnologia = false;
  const distintos = new Set();
  lineas.forEach((l) => {
    const p = producto(l.id);
    if (!p) return;
    unidades += l.cantidad; distintos.add(`${l.id}|${l.talla || 'U'}`);
    calzado = calzado || p.categoria === 'calzado'; tecnologia = tecnologia || p.categoria === 'tecnologia';
  });
  const m = 60 + 10 * Math.max(unidades - 3, 0) + 15 * Math.max(distintos.size - 2, 0) + (calzado ? 20 : 0) + (tecnologia ? 20 : 0);
  return Math.min(180, Math.max(60, Math.ceil(m / 5) * 5));
}
function textoDuracion(min) {
  const h = Math.floor(min / 60), m = min % 60;
  if (h && m) return `${h} h ${m} min`;
  return h === 1 ? '1 hora' : `${h} horas`;
}

/* ======================= Utilidades ======================= */
const $ = (sel, raiz = document) => raiz.querySelector(sel);
const $$ = (sel, raiz = document) => Array.from(raiz.querySelectorAll(sel));
const esc = (t) => String(t ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const dinero = (n) => '$' + Number(n || 0).toLocaleString('es-EC', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const producto = (id) => PRODUCTOS.find((p) => p.id === id);
const productoPorDbId = (dbId) => PRODUCTOS.find((p) => p.dbId === dbId);
// El código del producto en la base es el mismo de la tienda; así cada página lo reconoce aunque el catálogo aún esté cargando
PRODUCTOS.forEach((p) => { if (p.dbId === undefined) p.dbId = p.id; });
const normalizar = (t) => String(t).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
const plural = (n, uno, varios) => `${n} ${n === 1 ? uno : varios}`;
/* Fotos de producto (componente único). Cada foto existe en AVIF y WebP de 400 a 1600 px (img/productos/w/,
   las genera herramientas/fotos_web.py). Todas las pantallas arman la foto con foto(), que ya entrega
   <picture> con srcset y sizes: el navegador baja una sola versión, la justa para el espacio y la pantalla.
   El JPG original no se descarga en la tienda; queda para los correos. */
const RE_FOTO = /(?:^|\/)img\/productos\/([a-z0-9]+-\d+)\.jpg(?:\?.*)?$/;
const ANCHOS_FOTO = [400, 600, 800, 1000, 1200, 1600];
// Espacio que ocupa cada tipo de foto según el ancho de pantalla (medido de 320 a 1920 px)
const TAMANOS_FOTO = {
  hero: '(max-width: 37.5rem) calc(100vw - 2rem), (max-width: 64rem) 40vw, 448px',
  categoria: '(max-width: 37.5rem) calc(100vw - 2rem), 385px',
  tarjeta: '(max-width: 40rem) 42vw, (max-width: 80rem) 30vw, 272px',
  principal: '(max-width: 40rem) 92vw, (max-width: 80rem) 45vw, 574px',
  carrito: '(max-width: 40rem) 30vw, 160px'
};
const baseFoto = (src) => { const m = RE_FOTO.exec(src || ''); return m ? m[1] : ''; };
const srcsetFoto = (base, formato) => ANCHOS_FOTO.map((a) => `img/productos/w/${base}-${a}.${formato} ${a}w`).join(', ');
/* src: ruta de la foto; o: { alt, ancho, alto, sizes (clave de TAMANOS_FOTO o texto, o número en px),
   prioridad (foto principal visible al abrir: se pide primero y sin carga diferida), lazy, id, clase } */
function foto(src, o = {}) {
  const ancho = o.ancho || 800, alto = o.alto || 600;
  const sizes = typeof o.sizes === 'number' ? `${o.sizes}px` : (TAMANOS_FOTO[o.sizes] || o.sizes || `${ancho}px`);
  const carga = o.prioridad ? ' fetchpriority="high"' : (o.lazy === false ? '' : ' loading="lazy"');
  const extra = `${o.id ? ` id="${o.id}"` : ''}${o.clase ? ` class="${o.clase}"` : ''} alt="${o.alt || ''}" width="${ancho}" height="${alto}"${carga} decoding="async"`;
  const base = baseFoto(src);
  if (!base) return `<img src="${esc(src || FOTO_RESPALDO)}"${extra}>`;
  return `<picture><source type="image/avif" srcset="${srcsetFoto(base, 'avif')}" sizes="${sizes}">`
    + `<img src="img/productos/w/${base}-800.webp" srcset="${srcsetFoto(base, 'webp')}" sizes="${sizes}"${extra}></picture>`;
}
// Cambia la foto mostrada en un <img> creado con foto() (por ejemplo, la galería del producto)
function cambiarFoto(im, src) {
  const base = baseFoto(src);
  const fuente = im.parentElement && im.parentElement.tagName === 'PICTURE' ? im.parentElement.querySelector('source') : null;
  delete im.dataset.respaldo;
  if (!base) { if (fuente) fuente.removeAttribute('srcset'); im.removeAttribute('srcset'); im.src = src; return; }
  if (fuente) fuente.srcset = srcsetFoto(base, 'avif');
  im.srcset = srcsetFoto(base, 'webp');
  im.src = `img/productos/w/${base}-800.webp`;
}

// En los correos la foto se ve de 56 px: se envía la miniatura JPG de 112 px (antes el JPG de 1600 px, ~290 KB)
const fotoCorreo = (src) => { const base = baseFoto(src); return base ? `img/productos/correo/${base}.jpg` : src; };
const img = (p, vista = 1) => (p.imagenes && p.imagenes[vista - 1]) || `img/productos/${p.id}-${vista}.jpg`;
// Si una foto no carga (archivo faltante o red lenta), se muestra una imagen de respaldo en vez de un hueco roto
const FOTO_RESPALDO = 'img/sin-foto.svg';
document.addEventListener('error', (e) => {
  const el = e.target;
  if (el && el.tagName === 'IMG' && !el.dataset.respaldo && !el.src.endsWith(FOTO_RESPALDO)) {
    el.dataset.respaldo = '1';
    if (el.parentElement && el.parentElement.tagName === 'PICTURE') el.parentElement.querySelectorAll('source').forEach((s) => s.remove());
    el.removeAttribute('srcset');
    el.src = FOTO_RESPALDO;
  }
}, true);
const etiquetaCategoria = (p) => CATEGORIAS[p.categoria] + (p.publico ? ' · ' + p.publico : '');
const unidadesCarrito = () => estado.carrito.reduce((s, i) => s + i.cantidad, 0);
const subtotalCarrito = () => estado.carrito.reduce((s, i) => s + i.cantidad * ((producto(i.id) || {}).precio || 0), 0);
const redondear = (n) => Math.round(n * 100) / 100;
const ivaCarrito = () => redondear(subtotalCarrito() * CONFIG.iva);
const totalCarrito = () => redondear(subtotalCarrito() + ivaCarrito());
const fecha = (iso) => new Date(iso).toLocaleDateString('es-EC', { day: 'numeric', month: 'long', year: 'numeric' });
const fechaHora = (iso) => new Date(iso).toLocaleString('es-EC', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
// Primer nombre del cliente; si entró con Google y aún no completa su perfil, el nombre que entrega Google
const nombreCliente = () => {
  if (estado.cliente) return estado.cliente.nombres.split(' ')[0];
  const m = (estado.sesion && estado.sesion.user.user_metadata) || {};
  return String(m.given_name || m.nombres || m.full_name || m.name || '').trim().split(/\s+/)[0].replace(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ'-]/g, '').slice(0, 20);
};
const correoSesion = () => (estado.sesion ? estado.sesion.user.email : '');
const stockDe = (p, talla) => (p.stock ? (p.stock[talla || 'U'] ?? 0) : 10);
// Desde cuántas unidades se avisa al cliente que quedan pocas
const POCAS_UNIDADES = 3;
const stockTotal = (p) => (p.stock ? Object.values(p.stock).reduce((s, n) => s + Math.max(0, n), 0) : null);

const ICONOS = {
  corazon: '<path d="M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0 1 12 7.4a4.3 4.3 0 0 1 7.5 2.4C19.5 15.4 12 20 12 20z"/>',
  carrito: '<path d="M3 4h2l2.4 11h11L21 7H6.2"/><circle cx="9" cy="19.5" r="1.5"/><circle cx="17" cy="19.5" r="1.5"/>',
  check: '<path d="m5 12.5 4.5 4.5L19 7.5"/>',
  derecha: '<path d="M5 12h14M13 6l6 6-6 6"/>',
  izquierda: '<path d="M19 12H5M11 6l-6 6 6 6"/>',
  chevronIzq: '<path d="m15 5-7 7 7 7"/>',
  chevronDer: '<path d="m9 5 7 7-7 7"/>',
  chevronAbajo: '<path d="m6 9 6 6 6-6"/>',
  grafico: '<path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>',
  filtro: '<path d="M4 6h16M7 12h10M10 18h4"/>',
  menos: '<path d="M5 12h14"/>',
  mas: '<path d="M12 5v14M5 12h14"/>',
  basura: '<path d="M4 7h16M10 11v6M14 11v6M6 7l1 13h10l1-13M9 7V4h6v3"/>',
  editar: '<path d="M4 20h4L19 9l-4-4L4 16z"/>',
  regla: '<rect x="2.5" y="8" width="19" height="8" rx="1.5"/><path d="M6.5 8v3M10 8v4M13.5 8v3M17 8v4"/>',
  camion: '<path d="M3 6h11v10H3zM14 9h4l3 3v4h-7"/><circle cx="7" cy="17.5" r="1.8"/><circle cx="17.5" cy="17.5" r="1.8"/>',
  tienda: '<path d="M4 9h16l-1.5-5h-13zM5 9v11h14V9M9 20v-6h6v6"/>',
  escudo: '<path d="M12 3 5 6v6c0 4.5 3 7.5 7 9 4-1.5 7-4.5 7-9V6z"/><path d="m9 12 2 2 4-4"/>',
  paquete: '<path d="M12 3 4 7v10l8 4 8-4V7z"/><path d="m4 7 8 4 8-4M12 11v10"/>',
  alerta: '<path d="M12 3 2 20h20z"/><path d="M12 10v4M12 17v.01"/>',
  usuario: '<circle cx="12" cy="8" r="4"/><path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6"/>',
  ubicacion: '<path d="M12 21s-7-6.5-7-12a7 7 0 0 1 14 0c0 5.5-7 12-7 12z"/><circle cx="12" cy="9" r="2.5"/>',
  candado: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.01"/>',
  ojo: '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  ojoTachado: '<path d="M3 3l18 18M10.6 5.1A10 10 0 0 1 12 5c6.5 0 10 7 10 7a17 17 0 0 1-3.2 4.2M6.6 6.6C3.9 8.3 2 12 2 12s3.5 7 10 7a9.6 9.6 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2"/>',
  lupa: '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
  salir: '<path d="M15 4h4v16h-4M10 8l-4 4 4 4M6 12h10"/>',
  tarjeta: '<rect x="2.5" y="5" width="19" height="14" rx="2"/><path d="M2.5 10h19M6.5 15h4"/>',
  correo: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3.5 6.5 8.5 7 8.5-7"/>',
  ajustes: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
  estrella: '<path d="M12 2.8l2.8 5.9 6.4.8-4.7 4.4 1.2 6.4L12 17.2l-5.7 3.1 1.2-6.4L2.8 9.5l6.4-.8z"/>',
  recargar: '<path d="M20 11a8 8 0 1 0-2.3 5.7M20 4v7h-7"/>',
  banco: '<path d="M3 10 12 4l9 6M5 10v8M9.5 10v8M14.5 10v8M19 10v8M3 20h18"/>',
  documento: '<path d="M6 3h8l4 4v14H6z"/><path d="M14 3v4h4M9 12h6M9 16h6"/>',
  play: '<path d="M8 5v14l11-7z"/>',
  imagen: '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="10" r="2"/><path d="m21 17-5-5-9 9"/>'
};
const GOOGLE_LOGO = '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" style="stroke:none"><path fill="#4285F4" d="M23.5 12.3c0-.8-.1-1.6-.2-2.3H12v4.5h6.5a5.6 5.6 0 0 1-2.4 3.6v3h3.9c2.2-2.1 3.5-5.1 3.5-8.8z"/><path fill="#34A853" d="M12 24c3.2 0 6-1.1 7.9-2.9l-3.9-3c-1 .7-2.4 1.1-4 1.1-3.1 0-5.7-2.1-6.6-4.9H1.4v3.1A12 12 0 0 0 12 24z"/><path fill="#FBBC05" d="M5.4 14.3a7.2 7.2 0 0 1 0-4.6V6.6H1.4a12 12 0 0 0 0 10.8z"/><path fill="#EA4335" d="M12 4.8c1.7 0 3.3.6 4.5 1.8l3.4-3.4A12 12 0 0 0 1.4 6.6l4 3.1C6.3 6.9 8.9 4.8 12 4.8z"/></svg>';
const icono = (n, clase = '') => `<svg class="${clase}" viewBox="0 0 24 24" aria-hidden="true" focusable="false">${ICONOS[n]}</svg>`;

function estrellas(valor) {
  const llenas = Math.round(valor);
  let html = '<span class="estrellas" aria-hidden="true">';
  for (let i = 1; i <= 5; i++) html += `<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" class="${i <= llenas ? '' : 'vacia'}">${ICONOS.estrella}</svg>`;
  return html + '</span>';
}
function calificacionHtml(p) {
  if (!p.opiniones) return '<p class="calificacion texto-suave">Sin opiniones todavía</p>';
  return `<p class="calificacion">${estrellas(p.rating)}<span><span class="solo-lector">Calificación </span>${p.rating.toFixed(1)}<span class="solo-lector"> de 5</span> (${p.opiniones})</span></p>`;
}

/* ======================= Avisos ======================= */
function anunciar(texto) {
  const zona = $('#anuncio');
  zona.textContent = '';
  setTimeout(() => { zona.textContent = texto; }, 60);
}
let temporizadorAviso;
/* Aviso flotante. Con "accion" muestra un botón (por ejemplo «Deshacer»); mientras el mouse o el foco
   están sobre el aviso no se cierra, para que haya tiempo de usarlo. */
function aviso(texto, tipo = 'ok', accion = null) {
  const caja = $('#aviso-flotante');
  caja.textContent = texto;
  caja.dataset.tipo = tipo;
  if (accion) {
    const b = document.createElement('button');
    b.type = 'button'; b.className = 'aviso-flotante__accion'; b.textContent = accion.texto;
    b.addEventListener('click', () => { caja.hidden = true; accion.fn(); });
    caja.append(' ', b);
  }
  caja.hidden = false;
  clearTimeout(temporizadorAviso);
  const cerrar = () => { temporizadorAviso = setTimeout(() => { if (!caja.matches(':hover, :focus-within')) caja.hidden = true; else cerrar(); }, accion ? 8000 : tipo === 'error' ? 6000 : 3500); };
  cerrar();
}
/* Aviso de sesión: más grande que el aviso normal, con ícono, arriba de la página. Sale una sola vez,
   al iniciar sesión (tipo 'entrada') o al cerrarla (tipo 'salida'), y se puede cerrar con su botón. */
let temporizadorSesion;
function avisoSesion(tipo, titulo, detalle = '') {
  const caja = $('#aviso-sesion');
  if (!caja) return;
  caja.dataset.tipo = tipo;
  caja.innerHTML = `<span class="aviso-sesion__icono">${icono(tipo === 'salida' ? 'salir' : 'usuario')}</span>
    <div class="aviso-sesion__texto"><p class="aviso-sesion__titulo">${esc(titulo)}</p>${detalle ? `<p class="aviso-sesion__detalle">${esc(detalle)}</p>` : ''}</div>
    <button class="aviso-sesion__cerrar" type="button" aria-label="Cerrar aviso">×</button>`;
  $('.aviso-sesion__cerrar', caja).addEventListener('click', () => { caja.hidden = true; });
  caja.hidden = false;
  // El aviso normal no se muestra encima del de sesión
  const normal = $('#aviso-flotante'); if (normal) normal.hidden = true;
  clearTimeout(temporizadorSesion);
  const cerrar = () => { temporizadorSesion = setTimeout(() => { if (!caja.matches(':hover, :focus-within')) caja.hidden = true; else cerrar(); }, 6000); };
  cerrar();
}
/* Va a otra página de la tienda. Si hay un aviso en pantalla, se muestra también en la página siguiente.
   Solo se guarda cuando de verdad se cambia de página; si se queda en la misma, el aviso ya se está viendo
   (antes se guardaba igual y volvía a salir más tarde en otra página, por ejemplo «Cerraste sesión» al ingresar). */
function ir(destino) {
  const actual = location.pathname.split('/').pop() + location.search;
  const mismaPagina = actual === destino || (destino === 'index.html' && actual === '');
  if (mismaPagina) { render(); return; }
  const caja = $('#aviso-flotante');
  if (caja && !caja.hidden && !caja.querySelector('button')) guardarTemporal('aviso-pendiente', { texto: caja.textContent, tipo: caja.dataset.tipo });
  const sesion = $('#aviso-sesion');
  if (sesion && !sesion.hidden) {
    guardarTemporal('aviso-sesion', { tipo: sesion.dataset.tipo, titulo: $('.aviso-sesion__titulo', sesion).textContent, detalle: ($('.aviso-sesion__detalle', sesion) || {}).textContent || '' });
  }
  location.href = destino;
}
function mostrarAvisoPendiente() {
  const a = leerTemporal('aviso-pendiente');
  if (a) { guardarTemporal('aviso-pendiente', null); aviso(a.texto, a.tipo); }
}
// El aviso de sesión pendiente se muestra apenas abre la página siguiente (no espera al catálogo) y se borra
function mostrarAvisoSesionPendiente() {
  const a = leerTemporal('aviso-sesion');
  if (a) { guardarTemporal('aviso-sesion', null); avisoSesion(a.tipo, a.titulo, a.detalle); }
}

/* ======================= Diálogo reutilizable ======================= */
const dialogo = () => $('#dialogo');
function abrirDialogo(html, { ancho = false, alAbrir } = {}) {
  const d = dialogo();
  $('#dialogo-contenido').innerHTML = html;
  d.classList.toggle('dialogo--ancho', ancho);
  if (!d.open) d.showModal();
  if (alAbrir) alAbrir(d);
}
function cerrarDialogo() { if (dialogo().open) dialogo().close(); }
function confirmar(titulo, texto, textoSi = 'Sí, continuar') {
  return new Promise((resolver) => {
    abrirDialogo(`
      <h2 class="dialogo__titulo" id="dialogo-titulo">${esc(titulo)}</h2>
      <p>${esc(texto)}</p>
      <div class="dialogo__botones">
        <button class="boton boton--secundario" type="button" data-respuesta="no">Cancelar</button>
        <button class="boton boton--principal" type="button" data-respuesta="si">${esc(textoSi)}</button>
      </div>`, {
      alAbrir: (d) => {
        $('[data-respuesta="no"]', d).focus();
        const responder = (si) => { d.removeEventListener('close', alCerrar); cerrarDialogo(); resolver(si); };
        const alCerrar = () => resolver(false);
        d.addEventListener('close', alCerrar, { once: true });
        $$('[data-respuesta]', d).forEach((b) => b.addEventListener('click', () => responder(b.dataset.respuesta === 'si')));
      }
    });
  });
}

/* ======================= Formularios ======================= */
function campo({ id, etiqueta, tipo = 'text', ayuda = '', extra = '', valor = '', opcional = false, max = 120 }) {
  return `
    <div class="campo">
      <label for="${id}">${etiqueta}${opcional ? ' <span class="texto-suave">(opcional)</span>' : ' <span class="requerido" aria-hidden="true">*</span>'}</label>
      ${ayuda ? `<p class="campo__ayuda" id="${id}-ayuda">${ayuda}</p>` : ''}
      <input id="${id}" name="${id}" type="${tipo}" value="${esc(valor)}" maxlength="${max}" ${opcional ? '' : 'required aria-required="true"'} aria-describedby="${ayuda ? id + '-ayuda ' : ''}${id}-error" ${extra}>
      <p class="campo__error" id="${id}-error" hidden>${icono('alerta')}<span></span></p>
    </div>`;
}
/* Contraseña con botón para mostrarla u ocultarla */
function campoClave({ id, etiqueta, ayuda = '', autocomplete = 'current-password' }) {
  return `
    <div class="campo">
      <label for="${id}">${etiqueta} <span class="requerido" aria-hidden="true">*</span></label>
      ${ayuda ? `<p class="campo__ayuda" id="${id}-ayuda">${ayuda}</p>` : ''}
      <div class="campo-clave">
        <input id="${id}" name="${id}" type="password" maxlength="72" required aria-required="true" autocomplete="${autocomplete}" aria-describedby="${ayuda ? id + '-ayuda ' : ''}${id}-error" autocapitalize="off" spellcheck="false">
        <button class="campo-clave__boton" type="button" data-ver-clave="${id}" aria-pressed="false" aria-controls="${id}">${icono('ojo')}<span>Mostrar</span><span class="solo-lector"> contraseña</span></button>
      </div>
      <p class="campo__mayus" id="${id}-mayus" role="status" hidden>${icono('alerta')}<span>Bloq Mayús está activado: la contraseña distingue mayúsculas y minúsculas.</span></p>
      <p class="campo__error" id="${id}-error" hidden>${icono('alerta')}<span></span></p>
    </div>`;
}
/* Aviso de Bloq Mayús en las contraseñas (prevención de errores) */
function revisarMayus(e) {
  if (!e.target || !e.target.closest || !e.target.closest('.campo-clave') || typeof e.getModifierState !== 'function') return;
  const aviso = document.getElementById(e.target.id + '-mayus');
  if (aviso) aviso.hidden = !e.getModifierState('CapsLock');
}
document.addEventListener('keydown', revisarMayus);
document.addEventListener('keyup', revisarMayus);
document.addEventListener('focusout', (e) => { const a = e.target && e.target.id && document.getElementById(e.target.id + '-mayus'); if (a) a.hidden = true; });

function activarVerClave(raiz) {
  raiz.addEventListener('click', (e) => {
    const b = e.target.closest('[data-ver-clave]');
    if (!b) return;
    const input = $('#' + b.dataset.verClave, raiz);
    const mostrar = input.type === 'password';
    input.type = mostrar ? 'text' : 'password';
    b.setAttribute('aria-pressed', String(mostrar));
    b.innerHTML = `${icono(mostrar ? 'ojoTachado' : 'ojo')}<span>${mostrar ? 'Ocultar' : 'Mostrar'}</span><span class="solo-lector"> contraseña</span>`;
  });
}
function marcarError(form, id, mensaje) {
  const input = $('#' + id, form);
  const error = $('#' + id + '-error', form);
  if (!input || !error) return;
  if (mensaje) {
    input.setAttribute('aria-invalid', 'true');
    $('span', error).textContent = mensaje;
    error.hidden = false;
  } else {
    input.removeAttribute('aria-invalid');
    error.hidden = true;
  }
}
function mostrarResumenErrores(form, errores, titulo) {
  const caja = $('.alerta-errores', form);
  if (!errores.length) { caja.hidden = true; return; }
  caja.hidden = false;
  caja.innerHTML = `${icono('alerta')}<div><p>${esc(titulo)}</p><ul>${errores.map(([id, m]) => `<li>${id ? `<a href="#${id}" data-enfocar="${id}">${esc(m)}</a>` : esc(m)}</li>`).join('')}</ul></div>`;
  caja.focus();
  caja.scrollIntoView({ block: 'center' });
}
function ocultarResumen(form) { const c = $('.alerta-errores', form); if (c) c.hidden = true; }
/* Aplica reglas [id, mensaje] y muestra los errores; devuelve true si todo está bien */
function validarFormulario(form, reglas, titulo) {
  reglas.forEach(([id, m]) => marcarError(form, id, m));
  const errores = reglas.filter(([, m]) => m);
  if (errores.length) { mostrarResumenErrores(form, errores, titulo || `Revisa ${plural(errores.length, 'campo', 'campos')}:`); return false; }
  ocultarResumen(form);
  return true;
}
function errorGeneral(form, mensaje) { mostrarResumenErrores(form, [['', mensaje]], 'No pudimos continuar:'); }
function activarEnlacesError(form) {
  form.addEventListener('click', (e) => {
    const a = e.target.closest('[data-enfocar]');
    if (a) { e.preventDefault(); const el = $('#' + a.dataset.enfocar, form); if (el) el.focus(); }
  });
}
// Los correos más usados por clientes de todas las edades
function atajosCorreo(id) {
  return `<div class="atajos" role="group" aria-label="Completar el correo">
    <button class="chip" type="button" data-correo="${id}" data-dominio="@gmail.com">@gmail.com</button>
    <button class="chip" type="button" data-correo="${id}" data-dominio="@hotmail.com">@hotmail.com</button>
    <button class="chip" type="button" data-correo="${id}" data-dominio="@outlook.com">@outlook.com</button>
    <button class="chip" type="button" data-correo="${id}" data-dominio="@yahoo.com">@yahoo.com</button>
  </div>`;
}
function activarAtajosCorreo(raiz) {
  raiz.addEventListener('click', (e) => {
    const b = e.target.closest('[data-dominio]');
    if (!b) return;
    const input = $('#' + b.dataset.correo, raiz);
    const usuario = input.value.split('@')[0].trim();
    input.value = usuario + b.dataset.dominio;
    input.focus();
    anunciar(`Correo: ${input.value}`);
  });
}
/* Valida un campo al salir de él (después del primer intento), sin molestar mientras se escribe */
// Si se sale del campo tocando un botón, el mensaje se actualiza DESPUÉS del toque: así el botón no se mueve
// bajo el dedo (sin esto, en celular el primer toque en «Guardar» se perdía al desaparecer un mensaje de error).
let punteroPresionado = false;
document.addEventListener('pointerdown', () => { punteroPresionado = true; }, true);
document.addEventListener('pointerup', () => { setTimeout(() => { punteroPresionado = false; }, 0); }, true);
document.addEventListener('pointercancel', () => { punteroPresionado = false; }, true);
function despuesDelToque(fn) {
  if (!punteroPresionado) { fn(); return; }
  let hecho = false;
  const una = () => { if (!hecho) { hecho = true; setTimeout(fn, 0); } };
  document.addEventListener('pointerup', una, { once: true, capture: true });
  setTimeout(una, 1200);
}
function validarAlSalir(form, id, regla) {
  const input = $('#' + id, form);
  input.addEventListener('blur', () => {
    despuesDelToque(() => { if (input.isConnected && (input.value || input.getAttribute('aria-invalid'))) marcarError(form, id, regla(input.value)); });
  });
}
/* Filtra lo que no corresponde DESPUÉS de escribir (evento input).
   Así funcionan mayúsculas, Alt Gr, Alt + números, pegar y dictado: nunca se bloquea una tecla. */
function filtrarEntrada(input, patron, max) {
  input.addEventListener('input', () => {
    const tope = typeof max === 'function' ? max() : max;
    const limpio = input.value.replace(patron, '').slice(0, tope || undefined);
    if (limpio !== input.value) {
      const pos = Math.max(0, (input.selectionStart || 0) - (input.value.length - limpio.length));
      input.value = limpio;
      try { input.setSelectionRange(pos, pos); } catch (e) { /* algunos tipos no permiten cursor */ }
    }
  });
}
const NO_LETRAS = /[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]/g;
const NO_DIGITOS = /\D/g;

/* Evita el doble envío: desactiva el botón mientras se espera la respuesta */
async function conEspera(boton, textoEspera, accion) {
  if (boton.dataset.ocupado === '1') return undefined;
  const original = boton.innerHTML;
  boton.dataset.ocupado = '1';
  boton.disabled = true;
  boton.setAttribute('aria-busy', 'true');
  boton.innerHTML = `<span class="mini-carga" aria-hidden="true"></span>${esc(textoEspera)}`;
  try {
    return await accion();
  } finally {
    if (boton.isConnected) {
      boton.innerHTML = original;
      boton.disabled = false;
      boton.removeAttribute('aria-busy');
      delete boton.dataset.ocupado;
    }
  }
}

function cargandoHtml(texto = 'Cargando…') {
  return `<div class="contenedor pagina"><div class="panel centro" role="status"><div class="cargando" aria-hidden="true"></div><p class="subtitulo">${esc(texto)}</p></div></div>`;
}
function errorCargaHtml(mensaje) {
  return `<div class="contenedor pagina"><div class="panel centro" role="alert">
    <h1 class="titulo-pagina">No pudimos cargar esta página</h1>
    <p class="subtitulo">${esc(mensaje)}</p>
    <button class="boton boton--principal" type="button" style="margin-top:1.5rem" onclick="render()">${icono('recargar')}Intentar de nuevo</button>
  </div></div>`;
}
