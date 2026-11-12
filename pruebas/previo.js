// Pruebas del renderizado previo: qué se ve sin JavaScript, cuándo se oculta y si el JS dibuja lo mismo
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
(async () => {
  const b = await chromium.launch();
  const abrir = async (ruta, { sinJs = false, antes = null } = {}) => {
    const c = await b.newContext({ viewport: { width: 390, height: 844 } });
    const p = await c.newPage();
    const errores = []; p.on('pageerror', (e) => errores.push(e.message));
    if (sinJs) await p.route(/\.js(\?|$)/, (r) => r.abort());
    if (antes) await p.addInitScript(antes);
    await p.goto(B + ruta, { waitUntil: 'networkidle' }); await p.waitForTimeout(700);
    const r = await p.evaluate(() => {
      const m = document.getElementById('contenido');
      const visibles = [...m.children].filter((e) => getComputedStyle(e).display !== 'none').length;
      return { sinPrevio: document.documentElement.classList.contains('sin-previo'), visibles, h1: (m.querySelector('h1') || {}).textContent, previo: m.hasAttribute('data-previo'), html: m.innerHTML.trim(), url: location.pathname.split('/').pop() + location.search };
    });
    await c.close(); return { ...r, errores };
  };
  const sesion = () => sessionStorage.setItem('sb-umujfngetzifneqerirl-auth-token', '{"falso":1}');
  const carrito = () => localStorage.setItem('athletix-carrito-v2', JSON.stringify([{ id: 'vx', talla: '42', cantidad: 1 }]));
  const favs = () => localStorage.setItem('athletix-favoritos', JSON.stringify(['vx']));
  const casos = [
    ['index.html', {}, 'se ve'], ['index.html', { antes: sesion }, 'oculto'], ['productos.html', {}, 'se ve'], ['productos.html?cat=calzado', {}, 'oculto'],
    ['carrito.html', {}, 'se ve'], ['carrito.html', { antes: carrito }, 'oculto'], ['favoritos.html', {}, 'se ve'], ['favoritos.html', { antes: favs }, 'oculto'],
    ['login.html', {}, 'se ve'], ['login.html?volver=pedidos.html', {}, 'oculto'], ['producto.html?id=vx', {}, 'se ve'], ['producto.html?id=zz', {}, 'oculto'],
    ['index.html#/carrito', {}, 'oculto'], ['ayuda.html', {}, 'se ve'], ['quienes-somos.html', {}, 'se ve'], ['registro.html', {}, 'se ve'], ['recuperar.html', {}, 'se ve']
  ];
  let fallas = 0;
  for (const [ruta, op, esperado] of casos) {
    const sj = await abrir(ruta, { ...op, sinJs: true });
    const vis = sj.visibles > 0 && !sj.sinPrevio ? 'se ve' : 'oculto';
    let linea = `${ruta.padEnd(32)} sin JS: ${vis.padEnd(6)} (esperado ${esperado})`;
    let ok = vis === esperado;
    if (!op.antes) {
      const cj = await abrir(ruta, op);
      const igual = vis === 'se ve' ? (sj.html.replace(/\s+/g, ' ') === cj.html.replace(/\s+/g, ' ')) : null;
      linea += ` | con JS: h1 "${cj.h1}" previo-quitado:${!cj.previo} errores:${cj.errores.length}` + (igual === null ? '' : ` mismo-html:${igual}`);
      if (cj.errores.length || cj.previo || igual === false) ok = false;
      if (igual === false) { require('fs').writeFileSync('previo-' + ruta.replace(/\W+/g, '_') + '-a.html', sj.html); require('fs').writeFileSync('previo-' + ruta.replace(/\W+/g, '_') + '-b.html', cj.html); }
    }
    if (!ok) fallas++;
    console.log((ok ? 'ok   ' : 'FALLA') + ' ' + linea);
  }
  console.log('fallas:', fallas);
  await b.close();
})();
