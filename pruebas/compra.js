// Flujo de compra con una sesión simulada: el servidor de datos se reemplaza en el navegador de prueba (no se escribe en la base
// ni se envían correos). Sirve para ver cómo responde la tienda cuando la base contesta "sin stock", tarda, falla o se pulsa dos veces.
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
const ANON = 'sb_publishable_tdCRRgSHKJO6ADcmyeuFeQ_xuGIuhXd';
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
const UID = '11111111-2222-4333-8444-555555555555';
const sesion = () => { const exp = Math.floor(Date.now() / 1000) + 3600; return { access_token: `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64({ sub: UID, role: 'authenticated', exp, email: 'cliente.prueba@example.com' })}.firma`, token_type: 'bearer', expires_in: 3600, expires_at: exp, refresh_token: 'falso', user: { id: UID, aud: 'authenticated', role: 'authenticated', email: 'cliente.prueba@example.com', app_metadata: { provider: 'email' }, user_metadata: {} } }; };
const CLIENTE = { cli_cedula: '1710034065', cli_usuario: UID, cli_nombres: 'Cliente', cli_apellidos: 'De Prueba', cli_celular: '0991234567', cli_direccion: 'Av. Siempre Viva 123', cli_correo: 'cliente.prueba@example.com', cli_pais: 'Ecuador', cli_tipo_documento: 'Cédula' };
(async () => {
  const b = await chromium.launch();
  // pedido: función que decide qué responde "crear_pedido"; stock: cambios al catálogo (después de la primera respuesta si es función)
  const abrir = async ({ carrito, pedido, stock = () => ({}) }) => {
    const c = await b.newContext({ viewport: { width: 1280, height: 900 }, serviceWorkers: 'block' });
    const p = await c.newPage(); p.errores = []; p.llamadas = []; p.correos = 0; p.on('pageerror', (e) => p.errores.push(e.message));
    await p.route(/emailjs\.com/, (r) => r.abort());
    await p.route(/supabase\.co/, async (r) => {
      const q = r.request(); const u = new URL(q.url()); const ruta = u.pathname; const objeto = /pgrst\.object/.test(q.headers().accept || '');
      const json = (d, status = 200) => r.fulfill({ status, contentType: 'application/json', body: JSON.stringify(d) });
      if (ruta.startsWith('/functions/')) { p.correos++; return json({ ok: true }); }
      if (ruta === '/auth/v1/user') return json(sesion().user);
      if (ruta.startsWith('/auth/v1/token')) return json(sesion());
      if (ruta === '/rest/v1/rpc/crear_pedido') { p.llamadas.push(JSON.parse(q.postData())); return pedido(r, json, p.llamadas.length); }
      if (ruta === '/rest/v1/rpc/es_admin') return json(false);
      if (ruta === '/rest/v1/rpc/pedidos_nuevos') return json(0);
      if (ruta === '/rest/v1/cliente') return json(objeto ? CLIENTE : [CLIENTE]);
      if (/\/rest\/v1\/(carrito|favorito|metodo_pago|pedido|detalle_pedido|resena)/.test(ruta)) return q.method() === 'GET' ? json(objeto ? null : []) : json([], 201);
      if (/\/rest\/v1\/(producto|vista_calificaciones|tienda|categoria)$/.test(ruta) || ruta === '/auth/v1/settings') {
        const resp = await r.fetch({ headers: { ...q.headers(), authorization: 'Bearer ' + ANON } });
        if (ruta.endsWith('/producto')) { const d = await resp.json(); const m = stock(p.llamadas.length); for (const x of d) if (m[x.prd_codigo]) for (const t of x.producto_talla) if (m[x.prd_codigo][t.pta_talla] !== undefined) t.pta_cantidad = m[x.prd_codigo][t.pta_talla]; return r.fulfill({ response: resp, json: d }); }
        return r.fulfill({ response: resp });
      }
      return json({ message: 'ruta no simulada ' + ruta }, 404);
    });
    await p.addInitScript(([s, ca, uid]) => { if (!sessionStorage.getItem('__ini')) { sessionStorage.setItem('__ini', '1'); sessionStorage.setItem('sb-umujfngetzifneqerirl-auth-token', JSON.stringify(s)); localStorage.setItem('athletix-carrito-v2-' + uid, JSON.stringify(ca)); } }, [sesion(), carrito, UID]);
    await p.goto(B + 'carrito.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(500);
    return p;
  };
  const txt = (p, s) => p.evaluate((s) => { const e = document.querySelector(s); return e ? e.innerText.replace(/\s+/g, ' ').trim() : null; }, s);
  const hastaPago = async (p) => {
    await p.click('#continuar-compra'); await p.waitForURL(/retiro\.html/, { timeout: 15000 }); await p.waitForSelector('#form-retiro'); await p.waitForTimeout(300);
    await p.click('button[form="form-retiro"]'); await p.waitForURL(/pago\.html/, { timeout: 15000 }); await p.waitForSelector('#form-pago'); await p.waitForTimeout(300);
    await p.check('input[name="forma"][value="tienda"]', { force: true }); await p.waitForTimeout(200);
  };
  const OK = (n) => [{ ped_numero: 9000 + n, ped_codigo: 'AX-2026-0900' + n, ped_total: 286.35, ped_codigo_retiro: 'ABC123', ped_hora_estimada: new Date(Date.now() + 3600e3).toISOString(), ped_factura: 77 }];
  const CARRITO = [{ id: 'pt', talla: null, cantidad: 1 }];
  let p, t;

  // A. Compra normal con pago en tienda
  p = await abrir({ carrito: CARRITO, pedido: (r, json) => json(OK(1)) });
  ver(/Cliente/.test(await txt(p, '#zona-cuenta') || ''), 'A0. La sesión simulada se reconoce', (await txt(p, '#zona-cuenta') || '').slice(0, 40));
  await hastaPago(p);
  await p.click('#boton-pagar'); await p.waitForURL(/confirmacion\.html/, { timeout: 30000 }).catch(() => {});
  ver(/confirmacion\.html/.test(p.url()) && p.llamadas.length === 1, 'A1. Compra correcta: un solo pedido y pasa a la confirmación', `${p.llamadas.length} llamada(s), ${p.correos} correo(s) pedidos`);
  ver(JSON.stringify(p.llamadas[0].p_items) === JSON.stringify([{ producto: 'pt', talla: '', cantidad: 1 }]) && p.llamadas[0].p_tarjeta === null && !!p.llamadas[0].p_clave, 'A2. Se envían el producto, la cantidad, la tienda y una clave única del intento', JSON.stringify(p.llamadas[0]).slice(0, 150));
  ver((await p.evaluate((u) => localStorage.getItem('athletix-carrito-v2-' + u), UID)) === '[]', 'A3. El carrito queda vacío después de comprar');
  ver(!p.errores.length, '    sin errores', p.errores.join('|')); await p.context().close();

  // B. Otro cliente compró antes: la base responde "sin stock"
  p = await abrir({ carrito: [{ id: 'pt', talla: null, cantidad: 5 }], pedido: (r, json) => json({ code: 'P0001', message: 'No hay stock suficiente de "Reloj GPS de running negro"' }, 400), stock: (n) => (n >= 1 ? { pt: { U: 2 } } : {}) });
  await hastaPago(p); await p.click('#boton-pagar'); await p.waitForTimeout(4000);
  t = await txt(p, 'body');
  ver(/No hay stock suficiente/.test(t) && /Ajustamos la cantidad/.test(t) && /pago\.html/.test(p.url()), 'B1. Sin stock al pagar: explica qué pasó, ajusta el carrito a lo que queda y no cobra', (t.match(/No hay stock[^.]*\.[^.]*\./) || [''])[0].slice(0, 160));
  ver(!(await p.$('#capa-pago')), 'B2. La pantalla de "Procesando" no se queda pegada');
  ver(JSON.parse(await p.evaluate((u) => localStorage.getItem('athletix-carrito-v2-' + u), UID))[0].cantidad === 2, 'B3. El carrito quedó con 2 unidades (lo que hay)');
  await p.context().close();
  p = await abrir({ carrito: CARRITO, pedido: (r, json) => json({ code: 'P0001', message: 'No hay stock suficiente de "Reloj GPS de running negro"' }, 400), stock: (n) => (n >= 1 ? { pt: { U: 0 } } : {}) });
  await hastaPago(p); await p.click('#boton-pagar'); await p.waitForTimeout(4500);
  t = await txt(p, 'body');
  ver(/se agotó/.test(t) && /carrito\.html/.test(p.url()), 'B4. Se agotó todo lo del carrito al pagar: avisa y vuelve al carrito', p.url().split('/').pop() + ' · ' + (t.match(/[^.]*se agotó[^.]*\./) || [''])[0].slice(0, 120));
  ver(!p.errores.length, '    sin errores', p.errores.join('|')); await p.context().close();

  // C. Doble clic y varios clics seguidos en Pagar
  p = await abrir({ carrito: CARRITO, pedido: async (r, json) => { await new Promise((ok) => setTimeout(ok, 1500)); json(OK(2)); } });
  await hastaPago(p);
  await p.evaluate(() => { const bt = document.getElementById('boton-pagar'); for (let i = 0; i < 6; i++) bt.click(); document.getElementById('form-pago').requestSubmit(); });
  await p.waitForURL(/confirmacion\.html/, { timeout: 30000 }).catch(() => {});
  ver(p.llamadas.length === 1, 'C1. Seis clics seguidos en Pagar: se crea un solo pedido', p.llamadas.length + ' llamada(s)');
  await p.context().close();

  // D. La base tarda demasiado (sin respuesta) y luego se reintenta
  p = await abrir({ carrito: CARRITO, pedido: async (r, json, n) => { if (n === 1) { await new Promise((ok) => setTimeout(ok, 17000)); return json(OK(3)).catch(() => {}); } json(OK(3)); } });
  await hastaPago(p); await p.click('#boton-pagar'); await p.waitForTimeout(16500);
  t = await txt(p, '#form-pago');
  ver(/conexión|inténtalo|intentar/i.test(t) && !(await p.$('#capa-pago')) && !(await p.isDisabled('#boton-pagar')), 'D1. La base no responde en 15 s: avisa y deja volver a intentar', (t.match(/No (hay|pudimos)[^.]*\./) || [''])[0]);
  await p.click('#boton-pagar'); await p.waitForURL(/confirmacion\.html/, { timeout: 30000 }).catch(() => {});
  ver(p.llamadas.length === 2 && p.llamadas[0].p_clave === p.llamadas[1].p_clave, 'D2. El reintento usa la misma clave: la base devuelve el mismo pedido y no lo duplica', `claves iguales: ${p.llamadas[0].p_clave === (p.llamadas[1] || {}).p_clave}`);
  await p.context().close();

  // E. Errores del servidor
  for (const [nombre, resp, patron] of [
    ['E1. Error interno de la base (500)', [{ message: 'internal error' }, 500], /No pudimos completar/],
    ['E2. Demasiados pedidos seguidos', [{ code: 'P0001', message: 'Hiciste demasiados pedidos seguidos. Espera un minuto.' }, 400], /demasiados pedidos/i],
    ['E3. La sesión venció mientras pagaba', [{ code: 'PGRST301', message: 'JWT expired' }, 401], /sesión terminó/i],
    ['E4. Producto retirado por el administrador', [{ code: 'P0001', message: 'Un producto del carrito ya no está disponible' }, 400], /ya no está disponible/],
    ['E5. Respuesta vacía de la base', [[], 200], /No se pudo confirmar el pedido/]
  ]) {
    p = await abrir({ carrito: CARRITO, pedido: (r, json) => json(...resp) });
    await hastaPago(p); await p.click('#boton-pagar'); await p.waitForTimeout(3500);
    t = await txt(p, 'body');
    const carritoIntacto = JSON.parse(await p.evaluate((u) => localStorage.getItem('athletix-carrito-v2-' + u), UID)).length === 1;
    ver(patron.test(t) && carritoIntacto && !(await p.$('#capa-pago')) && !p.errores.length, `${nombre}: mensaje claro, carrito intacto y sin pantalla pegada`, (t.match(patron) || ['(sin mensaje)'])[0] + (p.errores.length ? ' ERR ' + p.errores.join('|') : ''));
    await p.context().close();
  }

  // F. Entrar directo a pasos de la compra
  p = await abrir({ carrito: [], pedido: (r, json) => json(OK(4)) });
  await p.goto(B + 'pago.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  ver(/carrito\.html/.test(p.url()), 'F1. Abrir pago.html con el carrito vacío: regresa al carrito', p.url().split('/').pop());
  await p.context().close();
  p = await abrir({ carrito: CARRITO, pedido: (r, json) => json(OK(5)) });
  await p.goto(B + 'pago.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  ver(/retiro\.html/.test(p.url()), 'F2. Abrir pago.html sin haber elegido tienda: lleva a elegir la tienda', p.url().split('/').pop());
  ver(p.llamadas.length === 0, 'F3. …y no se crea ningún pedido');
  await p.context().close();

  console.log('fallas:', fallas); await b.close();
})();
