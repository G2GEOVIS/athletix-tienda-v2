// Carrera de scripts: se retrasan las vistas (tienda/cuenta) o la base y la página igual debe dibujar su vista
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
const pags = ['index.html', 'productos.html', 'productos.html?cat=calzado', 'producto.html?id=vx', 'carrito.html', 'favoritos.html', 'login.html', 'login.html?volver=pedidos.html', 'registro.html', 'recuperar.html', 'ayuda.html', 'quienes-somos.html', 'pedidos.html', 'retiro.html'];
(async () => {
  const b = await chromium.launch(); let fallas = 0;
  for (const lento of [/min\/(tienda|cuenta)\.min/, /min\/base\.min/, /vendor\/supabase/]) for (const pg of pags) {
    const p = await b.newPage(); const err = []; p.on('pageerror', (e) => err.push(e.message));
    await p.route(lento, async (r) => { await new Promise((ok) => setTimeout(ok, 1500)); r.continue(); });
    await p.goto(B + pg, { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
    const h1 = await p.evaluate(() => (document.querySelector('main h1') || {}).textContent || '');
    const mal = /No encontramos/.test(h1) || !h1 || err.length;
    if (mal) { fallas++; console.log('FALLA', String(lento), pg, '->', h1, err.join('|')); }
    await p.close();
  }
  console.log('casos:', 3 * pags.length, 'fallas:', fallas); await b.close();
})();
