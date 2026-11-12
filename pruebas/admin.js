// Panel del administrador con sesión simulada (no escribe en la base): validaciones del formulario de producto y del stock
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
const ANON = 'sb_publishable_tdCRRgSHKJO6ADcmyeuFeQ_xuGIuhXd';
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };
const b64 = (o) => Buffer.from(JSON.stringify(o)).toString('base64url'); const UID = '11111111-2222-4333-8444-555555555555';
const sesion = () => { const exp = Math.floor(Date.now() / 1000) + 3600; return { access_token: `${b64({ alg: 'HS256', typ: 'JWT' })}.${b64({ sub: UID, role: 'authenticated', exp })}.firma`, token_type: 'bearer', expires_in: 3600, expires_at: exp, refresh_token: 'falso', user: { id: UID, aud: 'authenticated', role: 'authenticated', email: 'admin.prueba@example.com', app_metadata: { provider: 'email' }, user_metadata: {} } }; };
const CLIENTE = { cli_cedula: '1710034065', cli_usuario: UID, cli_nombres: 'Admin', cli_apellidos: 'De Prueba', cli_celular: '0991234567', cli_direccion: 'Quito', cli_correo: 'admin.prueba@example.com', cli_pais: 'Ecuador', cli_tipo_documento: 'Cédula' };
(async () => {
  const b = await chromium.launch();
  const abrir = async (ruta, esAdmin = true) => {
    const c = await b.newContext({ viewport: { width: 1280, height: 900 }, serviceWorkers: 'block' }); const p = await c.newPage(); p.errores = []; p.escrituras = []; p.on('pageerror', (e) => p.errores.push(e.message));
    await p.route(/supabase\.co/, async (r) => {
      const q = r.request(); const ruta = new URL(q.url()).pathname; const objeto = /pgrst\.object/.test(q.headers().accept || '');
      const json = (d, s = 200) => r.fulfill({ status: s, contentType: 'application/json', body: JSON.stringify(d) });
      if (ruta === '/auth/v1/user') return json(sesion().user);
      if (ruta === '/rest/v1/rpc/es_admin') return json(esAdmin);
      if (ruta === '/rest/v1/rpc/pedidos_nuevos') return json(0);
      if (ruta === '/rest/v1/cliente') return json(objeto ? CLIENTE : [CLIENTE]);
      if (q.method() === 'GET' && (/\/rest\/v1\/(producto|vista_calificaciones|tienda|categoria|producto_talla)$/.test(ruta) || ruta === '/auth/v1/settings')) return r.fulfill({ response: await r.fetch({ headers: { ...q.headers(), authorization: 'Bearer ' + ANON } }) });
      if (q.method() !== 'GET' && !/\/rpc\//.test(ruta)) { p.escrituras.push(q.method() + ' ' + ruta.replace('/rest/v1/', '')); return json(objeto ? {} : [{}], 200); }
      return json(objeto ? null : []);
    });
    await p.addInitScript((s) => sessionStorage.setItem('sb-umujfngetzifneqerirl-auth-token', JSON.stringify(s)), sesion());
    await p.goto(B + ruta, { waitUntil: 'networkidle' }); await p.waitForTimeout(600); return p;
  };
  const txt = (p, s) => p.evaluate((s) => { const e = document.querySelector(s); return e && !e.hidden ? e.innerText.replace(/\s+/g, ' ').trim() : ''; }, s);
  let p = await abrir('admin-producto.html?id=pt', false);
  ver(/No encontramos/.test(await txt(p, 'main h1')), 'M1. Un cliente normal que abre el panel del administrador: "No encontramos esta página"', await txt(p, 'main h1'));
  await p.context().close();
  p = await abrir('admin-producto.html?id=pt');
  ver(/Editar/.test(await txt(p, 'main h1')), 'M2. El administrador abre el formulario del producto', await txt(p, 'main h1'));
  const intento = async (campo, valor, nombre) => {
    const antes = await p.inputValue('#' + campo); await p.fill('#' + campo, ''); await p.evaluate(([c, v]) => { const i = document.getElementById(c); i.value = v; i.dispatchEvent(new Event('input', { bubbles: true })); }, [campo, valor]);
    const real = await p.inputValue('#' + campo);
    await p.click('#form-producto button[type=submit], main form button[type=submit]'); await p.waitForTimeout(500);
    const err = await txt(p, `#${campo}-error`);
    ver(err.length > 5 && p.escrituras.length === 0 && /admin-producto/.test(p.url()), nombre, `quedó "${real}" · ${err.slice(0, 70)}`);
    await p.fill('#' + campo, antes);
  };
  await intento('stock-u', '-5', 'M3. Stock negativo (-5): se rechaza y no se guarda');
  await intento('stock-u', '2.5', 'M4. Stock con decimales (2.5): se rechaza');
  await intento('stock-u', '100001', 'M5. Stock mayor a 100 000: se rechaza');
  await intento('stock-u', '', 'M6. Stock vacío: se rechaza');
  await intento('precio', '0', 'M7. Precio 0: se rechaza');
  await intento('precio', '-10', 'M8. Precio negativo: se rechaza');
  await intento('precio', '12.345', 'M9. Precio con 3 decimales: se rechaza');
  await intento('precio', '100000', 'M10. Precio de $100 000 o más: se rechaza');
  await intento('precio', 'abc', 'M11. Precio con letras: se rechaza');
  await intento('nombre', 'ab', 'M12. Nombre de 2 letras: se rechaza');
  await intento('descripcion', 'corta', 'M13. Descripción de menos de 20 caracteres: se rechaza');
  await p.fill('#stock-u', '0'); await p.click('main form button[type=submit]'); await p.waitForTimeout(2500);
  ver(p.escrituras.length > 0 && /admin-productos\.html/.test(p.url()), 'M14. Poner el stock en 0 (agotar el producto) sí se permite y se guarda', p.escrituras.slice(0, 4).join(', '));
  ver(!p.errores.length, '    sin errores', p.errores.join('|')); await p.context().close();
  p = await abrir('admin-producto.html');
  await p.fill('#codigo', 'pt'); await p.fill('#nombre', 'Producto repetido'); await p.fill('#precio', '10'); await p.fill('#descripcion', 'Una descripción de más de veinte letras.'); await p.fill('#stock-u', '5');
  await p.click('main form button[type=submit]'); await p.waitForTimeout(500);
  ver(/Ya existe/.test(await txt(p, '#codigo-error')) && p.escrituras.length === 0, 'M15. Crear un producto con un código que ya existe: se rechaza', await txt(p, '#codigo-error'));
  await p.context().close();
  for (const pag of ['admin.html', 'admin-productos.html', 'admin-stock.html', 'admin-pagos.html']) { p = await abrir(pag); const h = await txt(p, 'main h1'); ver(h.length > 3 && !/No encontramos/.test(h) && !p.errores.length, `M16. ${pag} abre sin errores con la base vacía de pedidos`, h + (p.errores[0] ? ' ERR ' + p.errores[0] : '')); await p.context().close(); }
  console.log('fallas:', fallas); await b.close();
})();
