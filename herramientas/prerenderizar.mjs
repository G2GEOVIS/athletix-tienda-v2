/* ATHLETIX v2 · Renderizado previo (prerender) de las páginas públicas.
   Problema que resuelve: la tienda dibuja el contenido con JavaScript, así que el texto o la foto principal
   (lo que Google mide como LCP) solo aparecía cuando terminaban de bajar y ejecutarse los scripts.
   Esta herramienta abre cada página en Chromium (Playwright) tal como la vería un visitante nuevo, espera a que
   termine de dibujarse con los datos de la base y guarda ese contenido dentro del <main> del HTML publicado.
   Así el navegador muestra la página apenas recibe el HTML y el CSS; después el JavaScript vuelve a dibujar
   exactamente lo mismo (con los botones ya funcionando) y lo actualiza si algo cambió.
   - Páginas fijas (inicio, catálogo, ingreso, ayuda…): el contenido va dentro del mismo HTML.
   - Detalle del producto (producto.html?id=…): un fragmento por producto en previo/producto/<id>.html, que un
     script mínimo del <head> pide apenas abre la página.
   El contenido previo solo se muestra cuando le sirve a quien entra: sin sesión iniciada, sin filtros en la dirección
   y, en carrito y favoritos, con la lista vacía. En los demás casos se oculta y la página se dibuja como antes.
   En estas páginas los scripts se piden justo después de pintar el contenido previo (no compiten con él por la red);
   si el contenido previo no aplica, se piden de inmediato.
   Uso (después de generar_paginas.py):  node herramientas/prerenderizar.mjs   (se ejecuta con npm run construir) */
import { createRequire } from 'node:module';
import { createServer } from 'node:http';
import { readFileSync, writeFileSync, mkdirSync, rmSync, existsSync, statSync } from 'node:fs';
import { dirname, join, extname, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const RAIZ = join(dirname(fileURLToPath(import.meta.url)), '..');

// Página -> condición extra para mostrar el contenido previo (además de: sin sesión y sin nada en la dirección)
const LISTA_VACIA = (clave) => `try{var l=JSON.parse(localStorage.getItem('${clave}')||'[]');if(l&&l.length)ok=false}catch(e){}`;
const PAGINAS = {
  'index.html': '',
  'productos.html': '',
  'carrito.html': LISTA_VACIA('athletix-carrito-v2'),
  'favoritos.html': LISTA_VACIA('athletix-favoritos'),
  'login.html': '',
  'registro.html': '',
  'recuperar.html': '',
  'ayuda.html': '',
  'quienes-somos.html': ''
};

/* Script del <head> (se ejecuta antes de pintar): si el contenido previo no corresponde a quien entra,
   marca la página con la clase sin-previo y el CSS lo oculta hasta que el JavaScript dibuje la página real. */
const guardia = (permitido, extra, adicional = '') =>
  `  <script>(function(){var ok=!location.hash&&${permitido};try{for(var i=0;i<sessionStorage.length;i++)if(/^sb-.*-auth-token$/.test(sessionStorage.key(i)))ok=false}catch(e){ok=false}${extra}` +
  `if(!ok)document.documentElement.className+=' sin-previo';${adicional}})();</script>\n`;

// Detalle del producto: pide el fragmento del producto y lo pone en <main> si el JavaScript aún no dibujó la página;
// los scripts se piden después de pintar el fragmento (o enseguida si no hay fragmento), con un máximo de 2,5 s
const PEDIR_FRAGMENTO = 'window.athletixPrevio=ok;if(ok){window.athletixEsperaFragmento=1;var id=new URLSearchParams(location.search).get("id");' +
  'var listo=function(){window.athletixEsperaFragmento=0;if(window.athletixCargarScripts)window.athletixCargarScripts()};setTimeout(listo,2500);' +
  'fetch("previo/producto/"+id+".html").then(function(r){return r.ok?r.text():""}).then(function(h){' +
  'function poner(){var m=document.getElementById("contenido");if(h&&m&&!window.athletixPintado&&!m.firstElementChild){m.innerHTML=h;m.setAttribute("data-previo","")}listo()}' +
  'if(document.getElementById("contenido")&&document.readyState!=="loading")poner();else document.addEventListener("readystatechange",function f(){if(document.readyState!=="loading"){document.removeEventListener("readystatechange",f);poner()}})}).catch(listo)}';

/* Carga de scripts al final del <body>: con contenido previo, después del primer pintado (requestAnimationFrame);
   sin él, de inmediato. async=false mantiene el orden (version, supabase, base, vistas) igual que con defer. */
const SCRIPT_DEFER = /  <script src="([^"]+)" defer><\/script>\n/g;
function cargarDespues(html) {
  const srcs = [...html.matchAll(SCRIPT_DEFER)].map((m) => m[1]);
  if (!srcs.length) throw new Error('No se encontraron los scripts con defer');
  const cargador = `  <script>(function(){var s=${JSON.stringify(srcs)};function c(){if(window.athletixScripts||window.athletixEsperaFragmento)return;window.athletixScripts=1;` +
    `s.forEach(function(u){var e=document.createElement('script');e.src=u;e.async=false;document.head.appendChild(e)})}window.athletixCargarScripts=c;` +
    `if(document.documentElement.className.indexOf('sin-previo')>-1)c();else requestAnimationFrame(function(){setTimeout(c,0)})})();</script>\n`;
  return html.replace(SCRIPT_DEFER, '').replace('</body>', cargador + '</body>');
}

/* ---------- Servidor local de la carpeta del sitio ---------- */
const TIPOS = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.svg': 'image/svg+xml',
  '.avif': 'image/avif', '.webp': 'image/webp', '.jpg': 'image/jpeg', '.png': 'image/png', '.woff2': 'font/woff2' };
const servidor = createServer((req, res) => {
  const ruta = normalize(decodeURIComponent(new URL(req.url, 'http://x').pathname)).replace(/^(\.\.[/\\])+/, '');
  let archivo = join(RAIZ, ruta);
  if (existsSync(archivo) && statSync(archivo).isDirectory()) archivo = join(archivo, 'index.html');
  if (!existsSync(archivo)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { 'Content-Type': TIPOS[extname(archivo)] || 'application/octet-stream' });
  res.end(readFileSync(archivo));
});
await new Promise((ok) => servidor.listen(0, '127.0.0.1', ok));
const BASE = `http://127.0.0.1:${servidor.address().port}/`;

const navegador = await chromium.launch();
async function capturar(ruta) {
  const contexto = await navegador.newContext({ viewport: { width: 390, height: 844 }, serviceWorkers: 'block' });
  const pagina = await contexto.newPage();
  const errores = [];
  pagina.on('pageerror', (e) => errores.push(e.message));
  await pagina.goto(BASE + ruta, { waitUntil: 'networkidle' });
  await pagina.waitForFunction(() => {
    const m = document.getElementById('contenido');
    return window.athletixPintado && m && m.firstElementChild && !m.hasAttribute('aria-busy') && !m.querySelector('.cargando');
  }, null, { timeout: 15000 });
  await pagina.waitForTimeout(400);
  const datos = await pagina.evaluate(() => ({
    html: document.getElementById('contenido').innerHTML.trim(),
    google: estado.googleActivo ? '1' : '0',
    ids: location.pathname.endsWith('/index.html') ? PRODUCTOS.filter((p) => p.activo !== false).map((p) => p.id) : null
  }));
  await contexto.close();
  if (errores.length) throw new Error(`${ruta}: ${errores.join(' | ')}`);
  return datos;
}

const MAIN = '<main id="contenido" tabindex="-1"></main>';
let idsProductos = [];
for (const [archivo, extra] of Object.entries(PAGINAS)) {
  const ruta = join(RAIZ, archivo);
  let html = readFileSync(ruta, 'utf8');
  if (!html.includes(MAIN)) throw new Error(`${archivo}: no tiene el <main> vacío (ejecuta antes generar_paginas.py)`);
  const { html: contenido, google, ids } = await capturar(archivo);
  if (ids) idsProductos = ids;
  html = cargarDespues(html.replace('</head>', guardia('!location.search', extra) + '</head>'))
    .replace(MAIN, `<main id="contenido" tabindex="-1" data-previo data-google="${google}">\n${contenido}\n  </main>`);
  writeFileSync(ruta, html);
  console.log(`${archivo}: ${(contenido.length / 1024).toFixed(1)} KB de contenido previo`);
}

// Detalle de cada producto: fragmentos en previo/producto/
const carpeta = join(RAIZ, 'previo', 'producto');
rmSync(carpeta, { recursive: true, force: true });
mkdirSync(carpeta, { recursive: true });
let total = 0;
for (const id of idsProductos) {
  const { html } = await capturar(`producto.html?id=${id}`);
  writeFileSync(join(carpeta, `${id}.html`), html);
  total += html.length;
}
const rutaProducto = join(RAIZ, 'producto.html');
writeFileSync(rutaProducto, cargarDespues(readFileSync(rutaProducto, 'utf8'))
  .replace('</head>', guardia('/^\\?id=[a-z0-9]{1,12}$/.test(location.search)', '', PEDIR_FRAGMENTO) + '</head>'));
console.log(`producto.html: ${idsProductos.length} fragmentos en previo/producto/ (${(total / 1024).toFixed(0)} KB en total)`);

await navegador.close();
servidor.close();
