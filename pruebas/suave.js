// La actualización que llega de la base después de dibujar no debe molestar: ni mover la página, ni quitar el foco, ni borrar lo escrito
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };
(async () => {
  const b = await chromium.launch();
  const abrir = async (ruta, cambios) => {
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, serviceWorkers: 'block' }); const p = await c.newPage(); p.errores = []; p.on('pageerror', (e) => p.errores.push(e.message));
    await p.route(/rest\/v1\/producto\?/, async (r) => { const resp = await r.fetch(); const d = await resp.json(); for (const x of d) if (cambios[x.prd_codigo] !== undefined) for (const t of x.producto_talla) t.pta_cantidad = cambios[x.prd_codigo]; await new Promise((ok) => setTimeout(ok, 2500)); await r.fulfill({ response: resp, json: d }); });
    await p.goto(B + ruta, { waitUntil: 'domcontentloaded' }); await p.waitForSelector('main h1'); await p.waitForFunction(() => window.athletixPintado); await p.waitForTimeout(600); return p;
  };
  // 1. Catálogo: el cliente baja y escribe en el buscador mientras la base todavía no responde; luego llega un cambio de stock
  let p = await abrir('productos.html', { vx: 0 });
  await p.evaluate(() => { window.scrollTo(0, 1500); document.querySelector('.tarjeta-producto').marca = 1; });
  await p.evaluate(() => document.getElementById('buscar-texto').focus({ preventScroll: true })); await p.keyboard.type('rel');
  await p.waitForTimeout(4000);
  let r = await p.evaluate(() => ({ y: Math.round(scrollY), q: document.getElementById('buscar-texto').value, foco: document.activeElement.id, agotado: [...document.querySelectorAll('.tarjeta-producto')].some((t) => /Agotado/.test(t.innerText)), nuevo: !document.querySelector('.tarjeta-producto').marca }));
ver(r.nuevo && r.agotado, '1a. Llega un cambio de stock: la tarjeta pasa a "Agotado" sola');
  ver(r.y > 500, '1b. La página no salta al inicio (se queda donde estaba el cliente)', 'altura ' + r.y);
  ver(r.q === 'rel' && r.foco === 'buscar-texto', '1c. No se borra lo que estaba escribiendo en el buscador ni pierde el foco', `"${r.q}" foco en ${r.foco}`);
  ver(!p.errores.length, '    sin errores', p.errores.join('|')); await p.context().close();
  // 2. Si la base responde lo mismo que ya se veía, no se vuelve a dibujar (visita repetida, con el catálogo ya guardado)
  p = await abrir('productos.html', {});
  await p.waitForTimeout(3500);   // primera visita: guarda el catálogo real
  await p.goto(B + 'producto.html?id=vx', { waitUntil: 'domcontentloaded' }); await p.waitForFunction(() => window.athletixPintado); await p.waitForTimeout(700);
  await p.evaluate(() => { document.querySelector('main h1').marca = 1; localStorage.setItem('athletix-catalogo-v2', JSON.stringify({ ...JSON.parse(localStorage.getItem('athletix-catalogo-v2')), t: 0 })); });
  await p.check('input[name=talla][value="42"]', { force: true });
  await p.reload({ waitUntil: 'domcontentloaded' }); await p.waitForFunction(() => window.athletixPintado); await p.waitForTimeout(700);
  await p.evaluate(() => { document.querySelector('main h1').marca = 1; }); await p.check('input[name=talla][value="42"]', { force: true });
  await p.waitForTimeout(4000);
  r = await p.evaluate(() => ({ mismo: document.querySelector('main h1').marca === 1, talla: (document.querySelector('input[name=talla]:checked') || {}).value }));
  ver(r.mismo && r.talla === '42', '2. La base responde lo mismo: la página no se redibuja y la talla elegida sigue marcada', `redibujó: ${!r.mismo}, talla ${r.talla}`);
  ver(!p.errores.length, '    sin errores', p.errores.join('|')); await p.context().close();
  console.log('fallas:', fallas); await b.close();
})();
