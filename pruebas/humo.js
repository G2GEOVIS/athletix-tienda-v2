// Prueba de humo: cada página carga sin errores, muestra su contenido y no pide JPG ni fuentes de Google
const { chromium } = require('playwright');
const B = process.argv[2] || 'http://127.0.0.1:5500/';
const pags = ['index.html','productos.html','productos.html?cat=calzado','producto.html?id=vx','producto.html?id=noexiste','carrito.html','favoritos.html','ayuda.html','quienes-somos.html','login.html','registro.html','recuperar.html','confirmar-correo.html','nueva-clave.html','completar-perfil.html','retiro.html','pago.html','confirmacion.html','orden.html','pedidos.html','perfil.html','metodos-pago.html','cambiar-clave.html','admin.html','admin-productos.html','admin-producto.html','admin-stock.html','admin-pagos.html','404.html'];
(async () => {
  const b = await chromium.launch(); let fallas = 0;
  for (const movil of [true, false]) {
    const ctx = await b.newContext(movil ? { viewport: { width: 390, height: 844 }, deviceScaleFactor: 3, isMobile: true, hasTouch: true } : { viewport: { width: 1366, height: 768 } });
    for (const pg of pags) {
      const p = await ctx.newPage(); const errores = []; const raros = [];
      p.on('console', (m) => { if (m.type() === 'error' && !/status of 40[04]|Failed to load resource/.test(m.text())) errores.push(m.text().slice(0, 140)); });
      p.on('pageerror', (e) => errores.push('pageerror: ' + e.message.slice(0, 140)));
      p.on('request', (r) => { const u = r.url(); if (/\.jpg(\?|$)/.test(u) || u.includes('fonts.g') || u.includes('emailjs')) raros.push(u.split('/').pop()); });
      await p.goto(B + pg, { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
      const info = await p.evaluate(() => ({ url: location.pathname.split('/').pop() + location.search, h1: (document.querySelector('main h1') || {}).textContent || '', cargando: !!document.querySelector('main .cargando') }));
      const mal = errores.length || !info.h1 || info.cargando || raros.length;
      if (mal) fallas++;
      console.log((mal ? 'FALLA ' : 'ok    ') + (movil ? 'movil ' : 'pc    ') + pg.padEnd(28) + ' -> ' + info.url.padEnd(34) + ' h1: ' + info.h1.trim().slice(0, 30) + (errores.length ? ' | ERR ' + errores.join(' ; ') : '') + (raros.length ? ' | PIDE ' + raros.join(',') : ''));
      await p.close();
    }
    await ctx.close();
  }
  console.log('fallas:', fallas); await b.close();
})();
