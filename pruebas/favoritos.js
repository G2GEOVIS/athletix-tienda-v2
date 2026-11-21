// Favoritos asociados a la cuenta. Sesión y base simuladas: no se escribe nada real.
// 1) Sin sesión: el corazón lleva a iniciar sesión y Mis favoritos también; nada se guarda en el navegador.
// 2) Con sesión: el producto que quiso guardar antes de ingresar queda en sus favoritos (en la base).
// 3) Borrar el historial (localStorage) no hace perder los favoritos: se vuelven a leer de la base.
// 4) Mis favoritos con un producto agotado: «Agregar todos» solo pasa al carrito el que tiene stock.
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/'; const REF = process.argv[3] || 'umujfngetzifneqerirl';
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url'); const UID = '11111111-2222-4333-8444-555555555555';
const sesion = () => { const exp = Math.floor(Date.now() / 1000) + 3600; return { access_token: `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64({ sub: UID, role: 'authenticated', exp })}.firma`, token_type: 'bearer', expires_in: 3600, expires_at: exp, refresh_token: 'falso', user: { id: UID, aud: 'authenticated', role: 'authenticated', email: 'cliente.prueba@example.com', app_metadata: { provider: 'email' }, user_metadata: {} } }; };
const CLIENTE = { cli_cedula: '1710034065', cli_usuario: UID, cli_nombres: 'Cliente', cli_apellidos: 'De Prueba', cli_celular: '0991234567', cli_direccion: 'Av. Amazonas N34-120 y Av. Atahualpa', cli_correo: 'cliente.prueba@example.com', cli_pais: 'Ecuador', cli_tipo_documento: 'Cédula' };
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };

(async () => {
  const b = await chromium.launch();
  const base = { favoritos: [] }; // tabla FAVORITO simulada de la cuenta de prueba

  async function abrir({ conSesion, stock = {} }) {
    const c = await b.newContext({ viewport: { width: 1280, height: 900 }, serviceWorkers: 'block' });
    const p = await c.newPage(); p.errores = []; p.on('pageerror', (e) => p.errores.push(e.message));
    await p.route(/emailjs\.com/, (r) => r.abort());
    await p.route(/supabase\.co/, async (r) => {
      const q = r.request(); const u = new URL(q.url()); const ruta = u.pathname; const objeto = /pgrst\.object/.test(q.headers().accept || '');
      const json = (d, s = 200) => r.fulfill({ status: s, contentType: 'application/json', body: JSON.stringify(d) });
      if (ruta === '/rest/v1/producto') { // catálogo real, con el stock cambiado solo en este navegador
        const resp = await r.fetch({ headers: { ...q.headers(), authorization: 'Bearer ' + q.headers().apikey } }); let datos = await resp.json();
        if (Array.isArray(datos)) for (const d of datos) { const m = stock[d.prd_codigo]; if (m) for (const t of d.producto_talla) if (m[t.pta_talla] !== undefined) t.pta_cantidad = m[t.pta_talla]; }
        return r.fulfill({ response: resp, json: datos });
      }
      if (!conSesion) return r.fulfill({ response: await r.fetch() });
      if (ruta.startsWith('/functions/')) return json({ ok: true });
      if (ruta === '/auth/v1/user') return json(sesion().user);
      if (ruta === '/rest/v1/rpc/es_admin') return json(false);
      if (ruta.startsWith('/rest/v1/rpc/')) return json(0);
      if (ruta === '/rest/v1/cliente') return json(objeto ? CLIENTE : [CLIENTE]);
      if (ruta === '/rest/v1/favorito') {
        if (q.method() === 'GET') return json(base.favoritos.map((id) => ({ prd_codigo: id })));
        if (q.method() === 'POST') { for (const f of JSON.parse(q.postData() || '[]')) if (!base.favoritos.includes(f.prd_codigo)) base.favoritos.push(f.prd_codigo); return json([], 201); }
        if (q.method() === 'DELETE') { const no = (u.searchParams.get('prd_codigo') || '').match(/"([^"]+)"/g); const quedan = no ? no.map((x) => x.replace(/"/g, '')) : []; base.favoritos = base.favoritos.filter((id) => quedan.includes(id)); return json([]); }
      }
      if (/\/rest\/v1\/(carrito|metodo_pago|pedido|detalle_pedido|resena)/.test(ruta)) return q.method() === 'GET' ? json(objeto ? null : []) : json([], 201);
      if (q.method() === 'GET') return r.fulfill({ response: await r.fetch({ headers: { ...q.headers(), authorization: 'Bearer ' + q.headers().apikey } }) });
      return json([]);
    });
    if (conSesion) await p.addInitScript(([s, ref]) => { if (!sessionStorage.getItem('__ini')) { sessionStorage.setItem('__ini', '1'); sessionStorage.setItem(`sb-${ref}-auth-token`, JSON.stringify(s)); } }, [sesion(), REF]);
    return p;
  }
  const local = (p) => p.evaluate(() => Object.fromEntries(Object.keys(localStorage).filter((k) => /favorit/.test(k)).map((k) => [k, localStorage.getItem(k)])));

  // 1. Sin sesión
  let p = await abrir({ conSesion: false });
  await p.goto(B + 'producto.html?id=cb', { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  await p.click('main [data-favorito="cb"]');
  await p.waitForURL(/login\.html/, { timeout: 10000 }).catch(() => {});
  ver(/login\.html\?volver=producto\.html%3Fid%3Dcb/.test(p.url()), '1a. Sin sesión, el corazón lleva a iniciar sesión y vuelve al producto', p.url().split('/').pop());
  await p.waitForTimeout(600);
  ver(/guardar tus favoritos/i.test(await p.textContent('main')), '1b. La página de ingreso explica que los favoritos se guardan en la cuenta');
  const ls1 = await local(p);
  ver(!ls1['athletix-favoritos'] && /"id":"cb"/.test(ls1['athletix-favorito-pendiente'] || ''), '1c. No se guarda como favorito en el navegador; solo queda pendiente para después de ingresar', JSON.stringify(ls1));
  await p.goto(B + 'favoritos.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  ver(/login\.html\?volver=favoritos\.html/.test(p.url()), '1d. Mis favoritos sin sesión lleva a iniciar sesión', p.url().split('/').pop());
  await p.goto(B + 'productos.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(600);
  ver((await p.textContent('#contador-favoritos')).trim() === '0' || await p.$eval('#contador-favoritos', (e) => e.hidden || getComputedStyle(e).display === 'none'), '1e. Sin sesión el contador de favoritos no muestra nada guardado');
  ver(!p.errores.length, '   sin errores', p.errores.join(' | '));
  const pendiente = ls1['athletix-favorito-pendiente'];
  await p.context().close();

  // 2. Inicia sesión: el pendiente queda guardado en la cuenta
  p = await abrir({ conSesion: true });
  await p.addInitScript((v) => { if (!sessionStorage.getItem('__pend')) { sessionStorage.setItem('__pend', '1'); localStorage.setItem('athletix-favorito-pendiente', v); } }, pendiente);
  await p.goto(B + 'producto.html?id=cb', { waitUntil: 'networkidle' }); await p.waitForTimeout(2000);
  ver(base.favoritos.includes('cb'), '2a. Al iniciar sesión, el producto que quiso guardar queda en sus favoritos de la base', JSON.stringify(base.favoritos));
  ver(await p.getAttribute('main [data-favorito="cb"]', 'aria-pressed') === 'true', '2b. El corazón del producto aparece marcado');
  ver(/se guardó en tus favoritos/i.test(await p.textContent('#aviso-flotante')), '2c. Se avisa que se guardó');
  ver(!(await local(p))['athletix-favorito-pendiente'], '2d. El pendiente se borra');
  await p.goto(B + 'productos.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(1200);
  await p.click('.tarjeta-producto [data-favorito]:not([aria-pressed="true"])'); await p.waitForTimeout(1200);
  ver(base.favoritos.length === 2, '2e. Con sesión el corazón guarda directo en la cuenta, sin salir de la página', JSON.stringify(base.favoritos) + ' ' + p.url().split('/').pop());
  ver(!p.errores.length, '   sin errores', p.errores.join(' | '));
  await p.context().close();

  // 3. Historial borrado (contexto nuevo, sin nada guardado en el navegador): los favoritos siguen ahí
  p = await abrir({ conSesion: true });
  await p.goto(B + 'favoritos.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(1800);
  const tarjetas = await p.$$eval('main .tarjeta-producto', (l) => l.length);
  ver(tarjetas === 2, '3a. Con el historial borrado, Mis favoritos muestra los 2 productos guardados en la cuenta', String(tarjetas));
  ver(!p.errores.length, '   sin errores', p.errores.join(' | '));
  await p.context().close();

  // 4. Un favorito agotado: «Agregar todos» solo pasa al carrito el que tiene stock
  base.favoritos = ['pt', 'fl'];
  p = await abrir({ conSesion: true, stock: { pt: { U: 0 } } });
  await p.goto(B + 'favoritos.html', { waitUntil: 'networkidle' });
  await p.waitForFunction(() => /Agotado/i.test(document.querySelector('main').innerText), null, { timeout: 8000 }).catch(() => {});
  ver(/Agotado/i.test(await p.textContent('main')), '4a. Mis favoritos muestra cuál está agotado');
  await p.click('#todo-al-carrito'); await p.waitForTimeout(800);
  const dialogo = await p.$('#dialogo[open]');
  if (dialogo) { const elegir = await p.$('#dialogo input[type=radio]'); if (elegir) await elegir.check({ force: true }); const ok = await p.$('#dialogo button[type=submit]'); if (ok) await ok.click(); await p.waitForTimeout(600); }
  const carrito = await p.evaluate(() => { const k = Object.keys(localStorage).find((x) => x.startsWith('athletix-carrito-v2-')); return JSON.parse(localStorage.getItem(k) || '[]'); });
  ver(carrito.length === 1 && carrito[0].id === 'fl', '4b. «Agregar todos» pasa al carrito solo el que tiene stock', JSON.stringify(carrito));
  ver(!p.errores.length, '   sin errores', p.errores.join(' | '));
  await p.context().close();

  await b.close();
  console.log(fallas ? `\n${fallas} falla(s)` : '\nTodo correcto');
  process.exit(fallas ? 1 : 0);
})();
