// Casos de formularios, búsqueda, direcciones raras y navegación (sin crear cuentas ni escribir en la base)
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };
(async () => {
  const b = await chromium.launch();
  const nueva = async (ruta, vp = { width: 390, height: 844 }) => {
    const c = await b.newContext({ viewport: vp, serviceWorkers: 'block' }); const p = await c.newPage();
    p.errores = []; p.dialogos = 0; p.escrituras = [];
    p.on('pageerror', (e) => p.errores.push(e.message)); p.on('dialog', (d) => { p.dialogos++; d.dismiss(); });
    p.on('request', (r) => { if (/supabase\.co/.test(r.url()) && r.method() !== 'GET' && !/rpc\/(cedula|correo|celular)_registrad|rpc\/es_admin/.test(r.url())) p.escrituras.push(r.method() + ' ' + new URL(r.url()).pathname); });
    await p.goto(B + ruta, { waitUntil: 'networkidle' }); await p.waitForTimeout(400); return p;
  };
  const txt = (p, s) => p.evaluate((s) => { const e = document.querySelector(s); return e && !e.hidden ? e.innerText.replace(/\s+/g, ' ').trim() : ''; }, s);
  const sinDesborde = (p) => p.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1);
  let p, t;

  // ---- Registro ----
  p = await nueva('registro.html');
  await p.click('#form-registro button[type=submit]'); await p.waitForTimeout(500);
  t = await txt(p, '.alerta-errores');
  ver(t.length > 20 && p.escrituras.length === 0, 'R1. Enviar el registro vacío: lista los errores y no envía nada', t.slice(0, 110));
  const probar = async (id, valor, patron, nombre) => { await p.fill('#' + id, ''); await p.click('#' + id); await p.keyboard.type(valor); await p.keyboard.press('Tab'); await p.waitForTimeout(1300); const e = await txt(p, `#${id}-error`); const v = await p.inputValue('#' + id); ver(patron === null ? e === '' : patron.test(e), nombre, `valor "${v.slice(0, 30)}" · ${e || 'sin error'}`); };
  await probar('cedula', '1234567890', /no es válida|válida/i, 'R2. Cédula con dígito verificador incorrecto: se rechaza');
  await probar('cedula', '0000000000', /válida|provincia/i, 'R3. Cédula 0000000000: se rechaza');
  await probar('cedula', '17100', /10|válida/i, 'R4. Cédula incompleta: se rechaza');
  await probar('cedula', '1710034065', null, 'R5. Cédula válida (1710034065): se acepta');
  await probar('correo-r', 'sin-arroba.com', /correo/i, 'R6. Correo sin arroba: se rechaza');
  await probar('correo-r', 'a@b', /correo/i, 'R7. Correo sin dominio completo (a@b): se rechaza');
  await probar('correo-r', 'con espacio@gmail.com', /correo/i, 'R8. Correo con espacio: se rechaza');
  await probar('correo-r', "x'; drop table cliente;--@gmail.com", /correo/i, 'R9. Correo con intento de inyección SQL: se rechaza');
  await probar('nombres', 'Juan123 <b>', null, 'R10. Nombre con números y etiquetas: se limpian al escribir');
  ver(await p.inputValue('#nombres') === 'Juan b', '     el campo quedó solo con letras', await p.inputValue('#nombres'));
  await probar('nombres', 'A', /./, 'R11. Nombre de una sola letra: se rechaza');
  await probar('telefono', '099123', /celular|número|dígitos/i, 'R12. Celular incompleto: se rechaza');
  await probar('telefono', '0991234567890123', null, 'R13. Celular con dígitos de más: se corta a 10');
  ver((await p.inputValue('#telefono')).length === 10, '     quedaron 10 dígitos', await p.inputValue('#telefono'));
  await probar('clave-r', 'abc', /8|contraseña/i, 'R14. Contraseña corta: se rechaza');
  await probar('clave-r', 'abcdefghij', /número|letras/i, 'R15. Contraseña sin números: se rechaza');
  await p.fill('#clave-r', 'Prueba1234'); await probar('clave-r2', 'Prueba9999', /coinciden/i, 'R16. Las contraseñas no coinciden: se avisa al salir del campo');
  await probar('clave-r2', 'Prueba1234', null, 'R16b. Al corregirla, el aviso desaparece');
  await p.fill('#nombres', ''); await p.click('#nombres'); await p.keyboard.insertText('María José '.repeat(40)); 
  ver((await p.inputValue('#nombres')).length <= 60, 'R17. Pegar un texto de 440 caracteres en el nombre: se corta al máximo', (await p.inputValue('#nombres')).length + ' caracteres');
  ver(await sinDesborde(p), 'R18. La página no se ensancha con textos largos');
  ver(p.escrituras.length === 0 && !p.errores.length && !p.dialogos, 'R19. Nada de esto creó una cuenta ni dio errores', p.escrituras.join(',') + p.errores.join('|'));
  await p.context().close();

  // ---- Ingreso ----
  p = await nueva('login.html');
  await p.click('#form-ingresar button[type=submit]'); await p.waitForTimeout(400);
  ver((await txt(p, '.alerta-errores')).length > 10 && p.escrituras.length === 0, 'I1. Ingresar con los campos vacíos: errores y no consulta al servidor', (await txt(p, '.alerta-errores')).slice(0, 90));
  await p.fill('#correo', "' or 1=1 --"); await p.fill('#clave', "' or '1'='1"); await p.click('#form-ingresar button[type=submit]'); await p.waitForTimeout(500);
  ver(/correo/i.test(await txt(p, '#correo-error')) && p.escrituras.length === 0, "I2. Inyección SQL en el ingreso (' or 1=1 --): se rechaza antes de llegar al servidor", await txt(p, '#correo-error'));
  await p.fill('#correo', 'nadie.existe.prueba@example.com'); await p.fill('#clave', 'ClaveQueNoExiste99'); await p.click('#form-ingresar button[type=submit]');
  await p.waitForTimeout(4000); t = await txt(p, '#form-ingresar');
  ver(/incorrectos|No existe una cuenta/i.test(t) && /login\.html/.test(p.url()), 'I3. Correo que no existe: avisa que no hay cuenta con ese correo y sigue en el ingreso', (t.match(/(Correo o contraseña|No existe una cuenta)[^.]*\./) || [''])[0]);
  ver(!(await p.isDisabled('#form-ingresar button[type=submit]')), 'I4. El botón vuelve a quedar activo para reintentar');
  const vs = await p.evaluate(() => ['https://evil.com', '//evil.com', 'javascript:alert(1)', 'pedidos.html', 'login.html', '../otra.html', 'producto.html?id=vx', 'pedidos.html#x<script>'].map((v) => volverSeguro(v)));
  ver(JSON.stringify(vs) === JSON.stringify(['', '', '', 'pedidos.html', '', '', 'producto.html?id=vx', '']), 'I5. "Volver a" después de ingresar solo acepta páginas de la tienda (no enlaces externos ni javascript:)', JSON.stringify(vs));
  ver(!p.errores.length && !p.dialogos, '    sin errores', p.errores.join('|')); await p.context().close();

  // ---- Recuperar ----
  p = await nueva('recuperar.html');
  await p.fill('#correo-rec', 'no-es-correo'); await p.click('#form-recuperar button[type=submit]'); await p.waitForTimeout(400);
  ver(/correo/i.test(await txt(p, '#correo-rec-error')) && p.escrituras.length === 0, 'C1. Recuperar con un correo mal escrito: error y no envía nada', await txt(p, '#correo-rec-error'));
  await p.context().close();

  // ---- Búsqueda y direcciones ----
  for (const [n, q] of [['B1', '<script>alert(1)</script>'], ['B2', '"><img src=x onerror=alert(1)>'], ['B3', 'a'.repeat(500)], ['B4', '   '], ['B5', "'; drop table producto;--"], ['B6', '%%%__\\'], ['B7', '🏃‍♂️ zapatillas']]) {
    p = await nueva('productos.html?q=' + encodeURIComponent(q));
    t = await txt(p, 'main');
    const inyectado = await p.evaluate(() => !!document.querySelector('main script, main img[onerror]'));
    ver(!p.dialogos && !inyectado && !p.errores.length && await sinDesborde(p) && /producto/i.test(t), `${n}. Buscar ${JSON.stringify(q.slice(0, 32))}${q.length > 32 ? '…' : ''}: no ejecuta código, no rompe la página`, (t.match(/\d+ productos?|No encontramos[^.]*\.|Sin resultados[^.]*\./) || [''])[0]);
    await p.context().close();
  }
  p = await nueva('productos.html?q=TECNOLOGÍA'); const a1 = (await txt(p, 'main')).match(/(\d+) productos?/); await p.context().close();
  p = await nueva('productos.html?q=tecnologia'); const a2 = (await txt(p, 'main')).match(/(\d+) productos?/); await p.context().close();
  ver(a1 && a2 && a1[1] === a2[1] && Number(a1[1]) > 0, 'B8. Buscar "TECNOLOGÍA" y "tecnologia" da lo mismo (sin importar mayúsculas ni tildes)', `${a1 && a1[1]} y ${a2 && a2[1]} productos`);
  for (const [n, ruta, patron] of [
    ['U1', 'producto.html?id=<script>alert(1)</script>', /No encontramos/], ['U2', 'producto.html?id=' + 'x'.repeat(300), /No encontramos/], ['U3', 'producto.html', /No encontramos/],
    ['U4', 'producto.html?id=VX', /No encontramos|ASICS/], ['U5', 'productos.html?cat=noexiste', /producto/i], ['U6', 'productos.html?cat=calzado&genero=x&precio=abc&orden=zzz', /Calzado/],
    ['U7', 'orden.html?pedido=abc', /Inicia sesión/], ['U8', 'confirmacion.html?pedido=999999', /Inicia sesión/], ['U9', 'admin-producto.html?id=vx', /Inicia sesión/], ['U10', 'index.html?x=<svg onload=alert(1)>#/producto/vx', /./]
  ]) {
    p = await nueva(ruta); t = await txt(p, 'main h1');
    ver(patron.test(t) && !p.dialogos && !p.errores.length, `${n}. Abrir ${ruta.slice(0, 58)}${ruta.length > 58 ? '…' : ''}`, t + (p.errores.length ? ' ERR ' + p.errores[0] : ''));
    await p.context().close();
  }

  // ---- Clics repetidos, dos pestañas, atrás ----
  p = await nueva('producto.html?id=pt');
  await p.evaluate(() => { const f = document.getElementById('form-compra'); for (let i = 0; i < 40; i++) f.requestSubmit(); });
  await p.waitForTimeout(500);
  const ls = await p.evaluate(() => JSON.parse(localStorage.getItem('athletix-carrito-v2')));
  const stockPt = await p.evaluate(() => stockDe(producto('pt'), null));
  ver(ls.length === 1 && ls[0].cantidad === stockPt, `N1. 40 clics seguidos en "Agregar al carrito": el carrito llega al stock (${stockPt}) y no lo pasa`, JSON.stringify(ls));
  const p2 = await p.context().newPage(); await p2.goto(B + 'index.html', { waitUntil: 'networkidle' });
  await p.keyboard.press('Escape'); await p.goto(B + 'carrito.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(400);
  await p.click('[data-accion="eliminar"]'); await p.waitForTimeout(600);
  ver(await p2.evaluate(() => document.getElementById('contador-carrito').textContent.trim()) === '0', 'N2. Dos pestañas: al vaciar el carrito en una, el contador de la otra se actualiza', await p2.evaluate(() => document.getElementById('contador-carrito').textContent.trim()));
  const deshacer = await p.$('button:has-text("Deshacer")'); if (deshacer) { await deshacer.click(); await p.waitForTimeout(400); ver((await p.evaluate(() => JSON.parse(localStorage.getItem('athletix-carrito-v2')))).length === 1, 'N3. "Deshacer" devuelve el producto eliminado'); }
  await p.goto(B + 'productos.html', { waitUntil: 'networkidle' }); await p.goBack({ waitUntil: 'networkidle' }); await p.waitForTimeout(500);
  ver(/Tu carrito/.test(await txt(p, 'main h1')) && !!(await p.$('.item-carrito')), 'N4. Botón Atrás del navegador: el carrito se muestra con su producto');
  ver(!p.errores.length && !p2.errores?.length, '    sin errores', p.errores.join('|')); await p.context().close();

  // ---- Pantallas muy pequeñas y muy grandes ----
  for (const [w, h] of [[280, 600], [320, 568], [2560, 1440]]) for (const ruta of ['index.html', 'productos.html', 'producto.html?id=vx', 'registro.html']) {
    p = await nueva(ruta, { width: w, height: h });
    const okv = await sinDesborde(p) && !p.errores.length;
    if (!okv) ver(false, `P. ${ruta} a ${w} px`, 'ancho del documento ' + await p.evaluate(() => document.documentElement.scrollWidth));
    await p.context().close();
  }
  ver(true, 'P1. 4 páginas a 280, 320 y 2560 px de ancho: revisadas (las fallas, si hay, salen arriba)');

  console.log('fallas:', fallas); await b.close();
})();
