/* ATHLETIX · Arranque, encabezado, sesión y enrutador */
'use strict';

/* ======================= Catálogo desde la base de datos ======================= */
// La base es la fuente oficial de todos los productos (los que crea el administrador también).
// datos.js queda como respaldo: si la base no responde, la tienda igual muestra el catálogo.
const ORDEN_TALLAS = (a, b) => parseFloat(a) - parseFloat(b);
function desdeBase(f, anterior) {
  const tallas = (f.producto_tallas || []).map((t) => t.talla).filter((t) => t !== 'U').sort(ORDEN_TALLAS);
  const vistas = f.imagenes.length ? f.imagenes.map((i) => i.descripcion) : (anterior ? anterior.vistas : ['vista principal']);
  const claves = anterior ? anterior.claves : normalizar([f.nombre, f.descripcion].join(' ')).split(/[^a-zñ0-9]+/).filter((x) => x.length > 2);
  return {
    id: f.id, dbId: f.id, nombre: f.nombre, categoria: f.categoria, publico: f.publico === 'Unisex' ? null : f.publico,
    precio: Number(f.precio), activo: f.activo, etiqueta: f.etiqueta,
    tallas: f.usa_talla ? tallas : [], vistas, imagenes: f.imagenes.map((i) => i.url),
    descripcion: f.descripcion,
    caracteristicas: f.caracteristicas.length ? f.caracteristicas : (anterior ? anterior.caracteristicas : []),
    ficha: f.ficha.length ? f.ficha : (anterior ? anterior.ficha : []),
    claves,
    stock: Object.fromEntries((f.producto_tallas || []).map((t) => [t.talla, t.stock]))
  };
}
/* Catálogo guardado en el navegador: la última respuesta de la base se guarda (localStorage) para mostrar
   la página al instante en la siguiente visita y no volver a pedir los 90 productos en cada página. */
const CLAVE_CATALOGO = 'athletix-catalogo-v2';
const CATALOGO_FRESCO_MS = 60 * 1000; // menos de 1 minuto: se usa tal cual, sin consultar la base
let firmaCatalogo = '';
function aplicarCatalogo(filas, notasLista) {
  const notas = new Map((notasLista || []).map((c) => [c.producto_id, c]));
  const anteriores = new Map(PRODUCTOS.map((p) => [p.id, p]));
  const nuevos = filas.map((f) => {
    const p = desdeBase(f, anteriores.get(f.id));
    const n = notas.get(f.id);
    p.rating = n ? Number(n.promedio) : 0;
    p.opiniones = n ? Number(n.opiniones) : 0;
    return p;
  });
  // Se mantiene el orden de datos.js y los productos nuevos del administrador van al final
  const orden = new Map(PRODUCTOS.map((p, i) => [p.id, i]));
  nuevos.sort((a, b) => (orden.has(a.id) ? orden.get(a.id) : 1e6) - (orden.has(b.id) ? orden.get(b.id) : 1e6));
  PRODUCTOS.length = 0;
  PRODUCTOS.push(...nuevos);
}
// Aplica el catálogo guardado (si hay) y devuelve su antigüedad en milisegundos
function catalogoGuardado() {
  try {
    const g = JSON.parse(localStorage.getItem(CLAVE_CATALOGO) || 'null');
    if (!g || !Array.isArray(g.filas) || !g.filas.length) return null;
    aplicarCatalogo(g.filas, g.notas);
    firmaCatalogo = JSON.stringify([g.filas, g.notas || []]);
    return { edad: Date.now() - (g.t || 0) };
  } catch (e) { return null; }
}
// Pide el catálogo a la base. Devuelve true si cambió algo respecto a lo que ya se mostraba.
async function cargarCatalogo() {
  const [rp, rc] = await Promise.all([Api.catalogo.productos(), Api.catalogo.calificaciones()]);
  if (rp.error) {
    estado.catalogoConectado = false;
    estado.errorCatalogo = rp.error;
    pintarBannerConexion();
    return false;
  }
  const filas = rp.datos || [];
  const notas = rc.datos || [];
  const firma = JSON.stringify([filas, notas]);
  const cambio = firma !== firmaCatalogo;
  if (filas.length && cambio) {
    aplicarCatalogo(filas, notas);
    firmaCatalogo = firma;
  }
  if (filas.length) { try { localStorage.setItem(CLAVE_CATALOGO, JSON.stringify({ t: Date.now(), filas, notas })); } catch (e) { /* sin espacio: se sigue sin guardar */ } }
  estado.catalogoConectado = filas.length > 0;
  estado.errorCatalogo = filas.length ? '' : 'Los productos todavía no están cargados en la base de datos.';
  pintarBannerConexion();
  return cambio;
}

function pintarBannerConexion() {
  let banner = $('#banner-conexion');
  if (estado.catalogoConectado) { if (banner) banner.remove(); return; }
  if (!banner) {
    banner = document.createElement('div');
    banner.id = 'banner-conexion';
    banner.className = 'banner-conexion';
    banner.setAttribute('role', 'status');
    $('.encabezado').after(banner);
  }
  banner.innerHTML = `<div class="contenedor">${icono('alerta')}<span>${esc(estado.errorCatalogo || 'Sin conexión con la tienda.')} Puedes ver los productos, pero para comprar necesitas conexión.</span>
    <button class="boton-icono" type="button" id="reintentar-conexion">${icono('recargar')}Reintentar</button></div>`;
  $('#reintentar-conexion', banner).addEventListener('click', async (e) => {
    await conEspera(e.currentTarget, 'Conectando…', cargarCatalogo);
    if (estado.catalogoConectado) { aviso('Conexión restablecida.'); render(); }
  });
}

/* ======================= Sesión ======================= */
async function alIniciarSesion(sesion) {
  estado.sesion = sesion;
  estado.cliente = null;
  estado.esAdmin = false;
  cargarDatosDeCuenta();
  actualizarContador();
  if (!sesion) { renderCuenta(); return; }
  const r = await Api.cliente.perfil(sesion.user.id);
  if (!r.error && r.datos) {
    estado.cliente = r.datos;
  } else if (!r.error) {
    // Primer ingreso después de confirmar el correo: se crea el perfil con los datos del registro
    const m = sesion.user.user_metadata || {};
    const extranjero = m.pais && m.pais !== 'Ecuador';
    if (m.cedula && m.nombres && m.apellidos && m.telefono && !(extranjero ? Validar.pasaporte(m.cedula) : Validar.cedula(m.cedula))) {
      const rc = await Api.cliente.crear({ id: sesion.user.id, correo: sesion.user.email, cedula: m.cedula, pais: m.pais || 'Ecuador', nombres: m.nombres, apellidos: m.apellidos, telefono: m.telefono, direccion: m.direccion });
      if (!rc.error) estado.cliente = rc.datos;
    }
  }
  if (estado.cliente) {
    [estado.esAdmin] = await Promise.all([Api.cliente.esAdmin(), cargarCuentaDesdeBase()]);
    actualizarContador();
  }
  estado.nuevos = undefined;
  recordarProveedorCorreo();
  renderCuenta();
  vigilarPedidos();
}

async function cerrarSesion() {
  await Api.auth.salir();
  estado.sesion = null; estado.cliente = null; estado.esAdmin = false;
  // El carrito y los favoritos de la cuenta quedan guardados para cuando vuelva a ingresar
  cargarDatosDeCuenta(); actualizarContador();
  clearInterval(vigilanciaPedidos);
  guardarTemporal('tienda', null);
  renderCuenta();
  avisoSesion('salida', 'Cerraste sesión', 'Tu carrito y tus favoritos quedan guardados para cuando vuelvas a ingresar.');
  ir('index.html');
}

/* ======================= Encabezado ======================= */
function actualizarContador() {
  const n = unidadesCarrito();
  $('#contador-carrito').textContent = n;
  $('#contador-carrito-texto').textContent = `, ${plural(n, 'producto', 'productos')}`;
  const f = estado.favoritos.length, cf = $('#contador-favoritos');
  if (cf) { cf.textContent = f; cf.hidden = !f; $('#contador-favoritos-texto').textContent = f ? `, ${plural(f, 'producto', 'productos')}` : ''; }
}

function renderCuenta() {
  const zona = $('#zona-cuenta');
  if (!estado.sesion) {
    // Desde el botón Ingresar, después de iniciar sesión se va a la portada
    zona.innerHTML = `<a class="cuenta__boton" href="login.html" data-ruta="ingresar">${icono('usuario')}<span class="cuenta__nombre-largo">Ingresar</span></a>`;
    return;
  }
  const nombre = nombreCliente() || 'Mi cuenta';
  zona.innerHTML = `
    <button class="cuenta__boton" type="button" aria-expanded="false" aria-controls="menu-cuenta">
      ${icono('usuario')}<span class="cuenta__nombre cuenta__nombre-largo">Hola, ${esc(nombre)}</span>${icono('chevronAbajo')}
      ${estado.esAdmin ? `<span class="insignia insignia--flotante" data-nuevos ${estado.nuevos ? '' : 'hidden'} aria-hidden="true">${estado.nuevos}</span>` : ''}
    </button>
    <ul class="cuenta__menu" id="menu-cuenta" hidden>
      ${estado.cliente ? `<li class="cuenta__quien" role="presentation"><strong>${esc(`${estado.cliente.nombres} ${estado.cliente.apellidos}`)}</strong><span>${esc(estado.cliente.correo || correoSesion())}</span></li>` : ''}
      <li><a href="perfil.html">${icono('usuario')}Mi perfil</a></li>
      <li><a href="pedidos.html">${icono('paquete')}Mis pedidos</a></li>
      ${estado.esAdmin ? `<li><a href="admin.html?estado=Recibido">${icono('ajustes')}Panel de pedidos<span class="insignia" data-nuevos ${estado.nuevos ? '' : 'hidden'}>${estado.nuevos}<span class="solo-lector"> pedidos nuevos</span></span></a></li><li><a href="admin-productos.html">${icono('tienda')}Productos</a></li><li><a href="admin-stock.html">${icono('grafico')}Stock</a></li><li><a href="admin-pagos.html">${icono('tarjeta')}Pagos</a></li>` : ''}
      <li><button type="button" data-accion="cerrar-sesion">${icono('salir')}Cerrar sesión</button></li>
    </ul>`;
  const boton = $('.cuenta__boton', zona);
  const menu = $('#menu-cuenta');
  boton.addEventListener('click', () => {
    const abrir = boton.getAttribute('aria-expanded') !== 'true';
    boton.setAttribute('aria-expanded', abrir);
    menu.hidden = !abrir;
    if (abrir) $('a', menu).focus();
  });
  menu.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') { cerrarMenuCuenta(); boton.focus(); }
  });
}
/* ======================= Aviso de pedidos nuevos (administrador) ======================= */
let vigilanciaPedidos = null;
async function revisarPedidosNuevos() {
  if (!estado.esAdmin) return;
  const n = await Api.pedidos.nuevos();
  if (n > (estado.nuevos || 0) && estado.nuevos !== undefined) {
    aviso(n - estado.nuevos === 1 ? '¡Tienes un pedido nuevo!' : `¡Tienes ${n - estado.nuevos} pedidos nuevos!`);
    anunciar('Llegó un pedido nuevo. Revísalo en el panel de pedidos.');
  }
  estado.nuevos = n;
  $$('[data-nuevos]').forEach((el) => { el.hidden = !n; el.firstChild.textContent = n; });
}
function vigilarPedidos() {
  clearInterval(vigilanciaPedidos);
  if (!estado.esAdmin) return;
  revisarPedidosNuevos();
  vigilanciaPedidos = setInterval(revisarPedidosNuevos, 60000);
}

function cerrarMenuCuenta() {
  const b = $('.cuenta__boton[aria-expanded]');
  if (b) { b.setAttribute('aria-expanded', 'false'); $('#menu-cuenta').hidden = true; }
}

function iniciarEncabezado() {
  const botonMenu = $('.boton-menu');
  const nav = $('#menu-principal');
  botonMenu.addEventListener('click', () => {
    const abrir = botonMenu.getAttribute('aria-expanded') !== 'true';
    botonMenu.setAttribute('aria-expanded', abrir);
    nav.classList.toggle('abierta', abrir);
  });
  $('.buscador').addEventListener('submit', (e) => {
    e.preventDefault();
    const q = $('#buscar-texto').value.trim().slice(0, 80);
    ir(q ? 'productos.html?q=' + encodeURIComponent(q) : 'productos.html');
  });
  document.addEventListener('click', (e) => {
    if (e.target === dialogo()) cerrarDialogo(); // clic en el fondo del diálogo
    if (e.target.closest('[data-cerrar-dialogo]')) cerrarDialogo();
    if (e.target.closest('[data-accion="cerrar-sesion"]')) { cerrarMenuCuenta(); cerrarSesion(); return; }
    const contacto = e.target.closest('a[href^="mailto:"]:not([data-app-correo])');
    if (contacto) { e.preventDefault(); escribirnos(contacto.getAttribute('href')); return; }
    if (!e.target.closest('#zona-cuenta')) cerrarMenuCuenta();
  });
  $('.saltar').addEventListener('click', (e) => { e.preventDefault(); $('#contenido').focus(); });
}

/* ======================= Contacto por correo ======================= */
/* El correo de la tienda abre el correo web del cliente (Gmail, Outlook/Hotmail o Yahoo) según el correo de su cuenta.
   Sin sesión, o con otro proveedor, se le deja elegir. */
const CORREOS_WEB = {
  gmail: ['Gmail', (a, s) => `https://mail.google.com/mail/?view=cm&fs=1&to=${a}&su=${s}`],
  outlook: ['Outlook / Hotmail', (a, s) => `https://outlook.live.com/mail/0/deeplink/compose?to=${a}&subject=${s}`],
  yahoo: ['Yahoo', (a, s) => `https://compose.mail.yahoo.com/?to=${a}&subject=${s}`]
};
function proveedorDeCorreo(correo) {
  const d = String(correo || '').split('@')[1] || '';
  if (/^(gmail|googlemail)\./.test(d)) return 'gmail';
  if (/^(hotmail|outlook|live|msn)\./.test(d)) return 'outlook';
  if (/^(yahoo|ymail)\./.test(d)) return 'yahoo';
  return '';
}
function escribirnos(mailto) {
  const [destino, consulta = ''] = mailto.replace(/^mailto:/, '').split('?');
  const asunto = new URLSearchParams(consulta).get('subject') || 'Consulta ATHLETIX';
  const a = encodeURIComponent(destino), s = encodeURIComponent(asunto);
  // Proveedor del correo de la cuenta; sin sesión, el del último correo usado en este navegador; si no, Gmail (el más usado)
  let prov = proveedorDeCorreo(estado.cliente ? estado.cliente.correo : correoSesion());
  if (!prov) { try { prov = localStorage.getItem('athletix-proveedor-correo') || ''; } catch (e) { prov = ''; } }
  if (!CORREOS_WEB[prov]) prov = 'gmail';
  aviso(`Abriendo ${CORREOS_WEB[prov][0]} para escribirnos…`);
  window.open(CORREOS_WEB[prov][1](a, s), '_blank', 'noopener');
}
// Se recuerda el proveedor del correo de quien inició sesión, para el botón de contacto aunque luego salga
function recordarProveedorCorreo() {
  const prov = proveedorDeCorreo(estado.cliente ? estado.cliente.correo : correoSesion());
  if (prov) { try { localStorage.setItem('athletix-proveedor-correo', prov); } catch (e) { /* sin almacenamiento */ } }
}

/* ======================= Enrutador ======================= */
/* Cada archivo HTML indica qué pantalla es con <body data-pagina="...">; los datos extra van en la dirección (?id=vx) */
function leerRuta() {
  const params = new URLSearchParams(location.search);
  const pagina = document.body.dataset.pagina || '';
  const partes = pagina.split('/').filter(Boolean);
  if (partes[0] === 'producto') partes[1] = params.get('id') || '';
  return { partes, params };
}

const ARCHIVOS = { '': 'index.html', productos: 'productos.html', producto: 'producto.html', carrito: 'carrito.html', ingresar: 'login.html',
  registro: 'registro.html', 'verifica-correo': 'confirmar-correo.html', 'completar-perfil': 'completar-perfil.html', recuperar: 'recuperar.html',
  'nueva-clave': 'nueva-clave.html', retiro: 'retiro.html', pago: 'pago.html', confirmacion: 'confirmacion.html', pedidos: 'pedidos.html',
  perfil: 'perfil.html', admin: 'admin.html', ayuda: 'ayuda.html', orden: 'orden.html',
  'admin-productos': 'admin-productos.html', 'admin-producto': 'admin-producto.html', 'admin-pagos': 'admin-pagos.html', 'admin-stock': 'admin-stock.html', favoritos: 'favoritos.html', 'quienes-somos': 'quienes-somos.html' };

const ARCHIVO_PERFIL = { '': 'perfil.html', pagos: 'metodos-pago.html', seguridad: 'cambiar-clave.html' };
// Rutas que no muestran productos: no piden el catálogo a la base
const RUTAS_SIN_CATALOGO = new Set(['ingresar', 'registro', 'verifica-correo', 'completar-perfil', 'recuperar', 'nueva-clave', 'perfil', 'ayuda', 'quienes-somos']);
// Rutas que siempre piden el catálogo al día (precios y stock exactos)
const RUTAS_CATALOGO_AL_DIA = new Set(['carrito', 'retiro', 'pago', 'admin', 'admin-productos', 'admin-producto', 'admin-stock', 'admin-pagos']);
const CLAVE_GOOGLE = 'athletix-google-activo';
/* Pantalla de cada ruta, por nombre: cada página solo carga el archivo de vistas que necesita
   (tienda, cuenta, compra o administración), así que la función se busca recién al mostrarla */
const VISTAS = {
  '': 'vistaInicio',
  productos: 'vistaProductos',
  producto: 'vistaProducto',
  carrito: 'vistaCarrito',
  ingresar: 'vistaIngresar',
  registro: 'vistaRegistro',
  'verifica-correo': 'vistaVerificaCorreo',
  'completar-perfil': 'vistaCompletarPerfil',
  recuperar: 'vistaRecuperar',
  'nueva-clave': 'vistaNuevaClave',
  retiro: 'vistaRetiro',
  pago: 'vistaPago',
  confirmacion: 'vistaConfirmacion',
  pedidos: 'vistaPedidos',
  perfil: 'vistaPerfil',
  admin: 'vistaAdmin',
  'admin-productos': 'vistaAdminProductos',
  'admin-producto': 'vistaAdminProducto',
  'admin-pagos': 'vistaAdminPagos',
  'admin-stock': 'vistaAdminStock',
  orden: 'vistaOrden',
  favoritos: 'vistaFavoritos',
  ayuda: 'vistaAyuda',
  'quienes-somos': 'vistaQuienesSomos'
};

/* Prefetch: mientras el cliente mira una pantalla del flujo de compra, el navegador descarga en segundo plano
   (con prioridad baja) la página y el código del paso siguiente, para que al pulsar "Continuar" abra al instante. */
const SIGUIENTE_PASO = {
  producto: { pagina: 'carrito.html', grupos: [] },
  carrito: { pagina: 'retiro.html', grupos: ['cuenta', 'compra'] },
  retiro: { pagina: 'pago.html', grupos: [] },
  pago: { pagina: 'confirmacion.html', grupos: [] }
};
const adelantados = new Set();
function adelantarSiguientePaso(ruta) {
  const sig = SIGUIENTE_PASO[ruta];
  if (!sig) return;
  const urls = [sig.pagina, ...sig.grupos.map((g) => (window.GRUPOS_SITIO || {})[g]).filter(Boolean)];
  const pedir = () => urls.forEach((u) => {
    if (adelantados.has(u)) return;
    adelantados.add(u);
    const l = document.createElement('link');
    l.rel = 'prefetch';
    l.href = u;
    document.head.appendChild(l);
  });
  if ('requestIdleCallback' in window) requestIdleCallback(pedir, { timeout: 3000 }); else setTimeout(pedir, 1500);
}

let primeraCarga = true;
let turnoRender = 0;
async function render() {
  const turno = ++turnoRender;
  cerrarDialogo();
  cerrarMenuCuenta();
  $('.boton-menu').setAttribute('aria-expanded', 'false');
  $('#menu-principal').classList.remove('abierta');

  const { partes, params } = leerRuta();
  const vista = window[VISTAS[partes[0] || '']] || vistaNoEncontrada;
  const main = $('#contenido');
  let resultado;
  try {
    const salida = vista(partes, params);
    if (salida && typeof salida.then === 'function') {
      main.innerHTML = cargandoHtml();
      main.setAttribute('aria-busy', 'true');
      resultado = await salida;
      main.removeAttribute('aria-busy');
    } else {
      resultado = salida;
    }
  } catch (error) {
    console.error(error);
    resultado = { titulo: 'Error', html: errorCargaHtml('Ocurrió un problema inesperado. Inténtalo de nuevo.') };
  }
  if (turno !== turnoRender) return; // el usuario ya fue a otra página
  if (!resultado) return; // la vista redirigió

  main.innerHTML = resultado.html;
  document.title = `${resultado.titulo} | ATHLETIX`;

  const seccion = resultado.seccion ?? partes[0] ?? 'inicio';
  $$('[data-ruta]').forEach((a) => {
    if (a.dataset.ruta === (seccion || 'inicio')) a.setAttribute('aria-current', 'page');
    else a.removeAttribute('aria-current');
  });
  $('#buscar-texto').value = partes[0] === 'productos' ? (params.get('q') || '') : '';

  try { if (resultado.montar) resultado.montar(main, params); } catch (error) { console.error(error); }
  window.scrollTo(0, 0);
  if (partes[0] === 'productos') { recordarCatalogo(); restaurarCatalogo(); }
  recordarPagina();
  adelantarSiguientePaso(partes[0] || '');
  if (!primeraCarga) {
    const titulo = $('h1', main);
    if (titulo) { titulo.setAttribute('tabindex', '-1'); titulo.focus({ preventScroll: true }); }
  }
  primeraCarga = false;
}

/* ======================= Regreso desde los enlaces del correo ======================= */
function revisarEnlaceDeRegreso() {
  const h = window.HASH_INICIAL || '';
  if (!/access_token=|error_description=|error=/.test(h)) return null;
  const p = new URLSearchParams(h.replace(/^#/, ''));
  if (p.get('error_description') || p.get('error')) {
    const vencido = /expired|invalid/i.test(p.get('error_code') + ' ' + p.get('error_description'));
    return { error: vencido ? 'Ese enlace ya se usó o venció. Si ya pulsaste "Confirmar mi correo" antes, tu cuenta ya está confirmada: inicia sesión con tu correo y contraseña.' : 'No pudimos completar el ingreso. Inténtalo de nuevo.' };
  }
  return { tipo: p.get('type') || 'login' };
}

/* ======================= Inicio de la aplicación ======================= */
window.addEventListener('error', (e) => { console.error(e.error || e.message); });
window.addEventListener('unhandledrejection', (e) => { console.error(e.reason); e.preventDefault(); aviso('Ocurrió un problema de conexión. Inténtalo de nuevo.', 'error'); });
window.addEventListener('offline', () => aviso('Perdiste la conexión a internet.', 'error'));
window.addEventListener('online', () => { aviso('Volviste a tener conexión.'); if (!estado.catalogoConectado) cargarCatalogo(); });
// Alto real del encabezado fijo: los filtros del catálogo se quedan justo debajo al bajar por los productos
function medirEncabezado() {
  const e = $('.encabezado');
  if (e) document.documentElement.style.setProperty('--alto-encabezado', e.offsetHeight + 'px');
}
window.addEventListener('resize', medirEncabezado);
document.addEventListener('DOMContentLoaded', medirEncabezado);
medirEncabezado();

window.addEventListener('storage', (e) => {
  if (e.key === claveCuenta(CLAVE_CARRITO)) { estado.carrito = leerCarrito(e.key); actualizarContador(); }
  if (e.key === claveCuenta(CLAVE_FAVORITOS)) { estado.favoritos = leerFavoritos(e.key); actualizarContador(); }
});
// Botón de favorito (corazón) en tarjetas y en el detalle del producto
document.addEventListener('click', (e) => {
  const b = e.target.closest('[data-favorito]');
  if (!b) return;
  const p = producto(b.dataset.favorito);
  const si = alternarFavorito(b.dataset.favorito);
  $$(`[data-favorito="${b.dataset.favorito}"]`).forEach((x) => x.setAttribute('aria-pressed', si));
  actualizarContador();
  const texto = `${p ? p.nombre : 'El producto'} ${si ? 'se guardó en' : 'se quitó de'} tus favoritos.`;
  anunciar(texto);
  if (leerRuta().partes[0] === 'favoritos') render(); else aviso(texto);
});

async function iniciar() {
  iniciarEncabezado();
  actualizarContador();
  renderCuenta();
  mostrarAvisoSesionPendiente();
  const regreso = revisarEnlaceDeRegreso();

  if (!Api.disponible()) {
    if (regreso) history.replaceState(null, '', location.pathname + location.search);
    estado.errorCatalogo = 'No se pudo cargar la conexión con la tienda.';
    pintarBannerConexion();
    render();
    return;
  }
  /* Qué pide cada página a la base (antes: catálogo, calificaciones y ajustes de Google en todas):
     - Las páginas que no muestran productos (ingreso, registro, ayuda, perfil…) no piden el catálogo.
     - Si el catálogo guardado tiene menos de 1 minuto, se usa sin consultar (salvo carrito, compra y administración,
       que siempre lo piden al día por precios y stock).
     - Si Google está activo se guarda en el navegador y solo se vuelve a preguntar en ingreso y registro. */
  const ruta = leerRuta().partes[0] || '';
  const usaCatalogo = !RUTAS_SIN_CATALOGO.has(ruta);
  const guardado = catalogoGuardado();
  if (guardado && guardado.edad < CATALOGO_FRESCO_MS) estado.catalogoConectado = true;
  const pedirCatalogo = usaCatalogo && (!guardado || guardado.edad >= CATALOGO_FRESCO_MS || RUTAS_CATALOGO_AL_DIA.has(ruta));
  const catalogo = pedirCatalogo ? cargarCatalogo() : Promise.resolve(false);
  let googleGuardado = null;
  try { googleGuardado = localStorage.getItem(CLAVE_GOOGLE); } catch (e) { /* sin almacenamiento */ }
  if (googleGuardado !== null) estado.googleActivo = googleGuardado === '1';
  const preguntaGoogle = ruta === 'ingresar' || ruta === 'registro';
  const google = preguntaGoogle || googleGuardado === null
    ? Api.auth.googleActivo().then((g) => { estado.googleActivo = g; try { localStorage.setItem(CLAVE_GOOGLE, g ? '1' : '0'); } catch (e) { /* nada */ } })
    : Promise.resolve();
  // Supabase lee primero los datos del enlace del correo; después se limpia la dirección
  await alIniciarSesion(await Api.auth.sesion());
  if (regreso) history.replaceState(null, '', location.pathname + location.search);

  let esRecuperacion = false;
  Api.auth.alCambiar(async (evento, sesion) => {
    if (evento === 'PASSWORD_RECOVERY') { esRecuperacion = true; estado.sesion = sesion; ir('nueva-clave.html'); return; }
    if (evento === 'SIGNED_OUT') { estado.sesion = null; estado.cliente = null; estado.esAdmin = false; cargarDatosDeCuenta(); actualizarContador(); renderCuenta(); return; }
    if (evento === 'TOKEN_REFRESHED' || evento === 'USER_UPDATED') { estado.sesion = sesion; return; }
    if (evento === 'SIGNED_IN' && sesion && (!estado.sesion || estado.sesion.user.id !== sesion.user.id)) {
      await alIniciarSesion(sesion);
      render();
    }
  });

  if (regreso && regreso.error) {
    aviso(regreso.error, 'error');
    ir('login.html'); return;
  } else if (regreso && regreso.tipo === 'recovery') {
    ir('nueva-clave.html'); return;
  } else if (regreso && estado.sesion && !esRecuperacion) {
    guardarTemporal('correo-pendiente', null);
    const volver = leerVolverPendiente();
    const conGoogle = (estado.sesion.user.app_metadata || {}).provider === 'google';
    if (estado.cliente) avisoSesion('entrada', `Iniciaste sesión, ${nombreCliente()}`, conGoogle ? 'Entraste con tu cuenta de Google.' : 'Tu correo quedó confirmado.');
    else avisoSesion('entrada', conGoogle ? 'Iniciaste sesión con Google' : 'Correo confirmado: iniciaste sesión', 'Antes de tu primera compra te pediremos tu cédula y celular.');
    if (!estado.cliente) { const d = destinoSinPerfil(volver); if (d !== 'index.html') { ir(d); return; } }
    guardarVolverPendiente(null);
    const destino = destinoTrasIngreso(volver);
    if (destino !== 'index.html') { ir(destino); return; }
  }
  /* La página se muestra de inmediato con el catálogo guardado (o el de respaldo de datos.js) y se actualiza
     sola si la base responde con algo distinto. Solo esperan a la base (máximo 5 s):
     el carrito y la compra con sesión (precios y stock al día) y el ingreso o registro si aún no se sabe si Google está activo. */
  const esperaCatalogo = pedirCatalogo && RUTAS_CATALOGO_AL_DIA.has(ruta) && (ruta === 'carrito' || estado.sesion);
  const esperaGoogle = preguntaGoogle && googleGuardado === null;
  if (esperaCatalogo || esperaGoogle) {
    $('#contenido').innerHTML = cargandoHtml();
    await Promise.race([Promise.all([esperaCatalogo ? catalogo : null, esperaGoogle ? google : null]), new Promise((ok) => setTimeout(ok, 5000))]);
  }
  render();
  mostrarAvisoPendiente();
  const cambio = await catalogo;
  const ahora = leerRuta().partes[0] || '';
  if (cambio && ['', 'productos', 'producto', 'carrito', 'favoritos'].includes(ahora) && !$('#dialogo').open) render();
  if (preguntaGoogle && !esperaGoogle) { await google; if (String(estado.googleActivo) !== String(googleGuardado === '1') && !$('#dialogo').open) render(); }
}

// Enlaces antiguos con # (por ejemplo index.html#/carrito) se llevan a su página nueva
// Service Worker (sw.js): guarda en el navegador JS, CSS, fuentes y fotos para las siguientes visitas.
// Se registra cuando la página ya terminó de cargar, para no competir con lo que el cliente está viendo.
if ('serviceWorker' in navigator && location.protocol === 'https:') {
  window.addEventListener('load', () => { navigator.serviceWorker.register('sw.js').catch(() => { /* sin Service Worker la tienda funciona igual */ }); });
}
// Los scripts se cargan con defer: el arranque espera a que estén todos (también las vistas de la página)
function redirigirEnlaceAntiguo() {
  const m = location.hash.match(/^#\/([^?]*)(\?.*)?$/);
  if (!m) { iniciar(); return; }
  const [ruta, sub] = m[1].split('/');
  const consulta = (m[2] || '').replace(/^\?/, '');
  let destino = ARCHIVOS[ruta] || 'index.html';
  if (ruta === 'producto' && sub) destino = 'producto.html?id=' + encodeURIComponent(sub);
  else if (ruta === 'perfil' && sub) destino = ARCHIVO_PERFIL[sub] || 'perfil.html';
  if (consulta) destino += (destino.includes('?') ? '&' : '?') + consulta;
  location.replace(destino);
}
if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', redirigirEnlaceAntiguo);
else redirigirEnlaceAntiguo();
