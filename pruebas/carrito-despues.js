// ¿Queda vacío el carrito de la cuenta después de comprar? Sesión y base simuladas: no se escribe nada real.
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/'; const REF = process.argv[3] || 'umujfngetzifneqerirl';
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url'); const UID = '11111111-2222-4333-8444-555555555555';
const sesion = () => { const exp = Math.floor(Date.now() / 1000) + 3600; return { access_token: `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64({ sub: UID, role: 'authenticated', exp })}.firma`, token_type: 'bearer', expires_in: 3600, expires_at: exp, refresh_token: 'falso', user: { id: UID, aud: 'authenticated', role: 'authenticated', email: 'cliente.prueba@example.com', app_metadata: { provider: 'email' }, user_metadata: {} } }; };
const CLIENTE = { cli_cedula: '1710034065', cli_usuario: UID, cli_nombres: 'Cliente', cli_apellidos: 'De Prueba', cli_celular: '0991234567', cli_direccion: 'Av. Amazonas N34-120 y Av. Atahualpa', cli_correo: 'cliente.prueba@example.com', cli_pais: 'Ecuador', cli_tipo_documento: 'Cédula' };
(async () => {
  const b = await chromium.launch(); const c = await b.newContext({ viewport: { width: 1280, height: 900 }, serviceWorkers: 'block' }); const p = await c.newPage();
  let carritoBase = [{ prd_codigo: 'pt', car_talla: 'U', car_cantidad: 1 }]; const bitacora = []; let pedidoHecho = false;
  await p.route(/emailjs\.com/, (r) => r.abort());
  await p.route(/supabase\.co/, async (r) => {
    const q = r.request(); const u = new URL(q.url()); const ruta = u.pathname; const objeto = /pgrst\.object/.test(q.headers().accept || '');
    const json = (d, s = 200) => r.fulfill({ status: s, contentType: 'application/json', body: JSON.stringify(d) });
    if (ruta.startsWith('/functions/')) return json({ ok: true });
    if (ruta === '/auth/v1/user') return json(sesion().user);
    if (ruta === '/rest/v1/rpc/crear_pedido') { pedidoHecho = true; bitacora.push('PEDIDO CREADO'); return json([{ ped_numero: 9001, ped_codigo: 'AX-2026-09001', ped_total: 286.35, ped_codigo_retiro: 'ABC123', ped_hora_estimada: new Date().toISOString(), ped_factura: 77 }]); }
    if (ruta === '/rest/v1/rpc/es_admin') return json(false);
    if (ruta.startsWith('/rest/v1/rpc/')) return json(0);
    if (ruta === '/rest/v1/cliente') return json(objeto ? CLIENTE : [CLIENTE]);
    if (ruta === '/rest/v1/carrito') {
      if (q.method() === 'GET') { if (pedidoHecho) bitacora.push(`la página ${p.url().split('/').pop().split('?')[0]} lee el carrito de la cuenta: ${carritoBase.length} producto(s)`); return json(carritoBase); }
      if (q.method() === 'DELETE') { carritoBase = []; bitacora.push('se borra el carrito de la cuenta'); return json([]); }
      bitacora.push('se guarda el carrito de la cuenta'); return json([], 201);
    }
    if (/\/rest\/v1\/(favorito|metodo_pago|pedido|detalle_pedido|resena)/.test(ruta)) return q.method() === 'GET' ? json(objeto ? null : []) : json([], 201);
    if (q.method() === 'GET') return r.fulfill({ response: await r.fetch({ headers: { ...q.headers(), authorization: 'Bearer ' + q.headers().apikey } }) });
    return json([]);
  });
  await p.addInitScript(([s, ref]) => { if (!sessionStorage.getItem('__ini')) { sessionStorage.setItem('__ini', '1'); sessionStorage.setItem(`sb-${ref}-auth-token`, JSON.stringify(s)); } }, [sesion(), REF]);
  await p.goto(B + 'carrito.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
  await p.click('#continuar-compra'); await p.waitForSelector('#form-retiro', { timeout: 20000 }); await p.waitForTimeout(500);
  await p.waitForTimeout(1500);
  const bot = await p.evaluate(() => [...document.querySelectorAll('button')].filter((x) => /Continuar|pago/i.test(x.innerText)).map((x) => [x.innerText.trim(), x.type, x.getAttribute('form'), x.id, x.disabled]));
  if (process.env.DEP) console.log('  botones:', JSON.stringify(bot), JSON.stringify(await p.evaluate(() => [...document.querySelectorAll('input[name=tienda]')].map((i) => [i.value, i.checked]))));
  await p.evaluate(() => { const t = document.querySelector('input[name=tienda]'); if (t && !document.querySelector('input[name=tienda]:checked')) t.click(); });
  await p.evaluate(() => document.getElementById('form-retiro').requestSubmit());
  await p.waitForTimeout(2500);
  if (process.env.DEP) console.log('  tras enviar retiro:', p.url().split('/').pop(), await p.evaluate(() => document.querySelector('main').innerText.replace(/\s+/g, ' ').slice(0, 300)));
  await p.waitForSelector('#form-pago', { timeout: 20000 }); await p.waitForTimeout(500);
  await p.check('input[name="forma"][value="tienda"]', { force: true }); await p.click('#boton-pagar');
  await p.waitForFunction(() => /confirmacion\.html/.test(location.href), null, { timeout: 30000 }); await p.waitForTimeout(5000);
  const contador = await p.evaluate(() => document.getElementById('contador-carrito').textContent.trim());
  console.log(B); bitacora.forEach((l) => console.log('   ' + l)); console.log('   contador del carrito en la confirmación:', contador);
  await p.goto(B + 'carrito.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(1200);
  console.log('   al abrir el carrito después:', await p.evaluate(() => document.querySelectorAll('.item-carrito').length), 'producto(s)');
  await b.close();
})();
