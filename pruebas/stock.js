// Casos de stock en la v2 (sin tocar la base): la respuesta del catálogo se modifica en el navegador de prueba
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
let fallas = 0; const ver = (ok, t, extra = '') => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t + (extra ? ' -> ' + extra : '')); };
(async () => {
  const b = await chromium.launch();
  // cambios: { vx: { '42': 1, '*': 0 }, pt: { U: 0 }, fl: null (producto borrado/oculto) }
  const abrir = async (ruta, cambios = {}, { carrito = null, favoritos = null, luego = null } = {}) => {
    const c = await b.newContext({ viewport: { width: 390, height: 844 }, serviceWorkers: 'block' });
    const p = await c.newPage(); p.errores = []; p.on('pageerror', (e) => p.errores.push(e.message));
    p.cambios = cambios;
    await p.route(/rest\/v1\/producto\?/, async (r) => {
      const resp = await r.fetch(); let datos = await resp.json();
      datos = datos.filter((d) => p.cambios[d.prd_codigo] !== null);
      for (const d of datos) { const m = p.cambios[d.prd_codigo]; if (m) for (const t of d.producto_talla) { if (m[t.pta_talla] !== undefined) t.pta_cantidad = m[t.pta_talla]; else if (m['*'] !== undefined) t.pta_cantidad = m['*']; } }
      await r.fulfill({ response: resp, json: datos });
    });
    await p.addInitScript(([ca, fa]) => { if (!sessionStorage.getItem('__ini')) { sessionStorage.setItem('__ini', '1'); if (ca) localStorage.setItem('athletix-carrito-v2', JSON.stringify(ca)); if (fa) localStorage.setItem('athletix-favoritos', JSON.stringify(fa)); } }, [carrito, favoritos]);
    await p.goto(B + ruta, { waitUntil: 'networkidle' }); await p.waitForTimeout(500);
    return p;
  };
  const txt = (p, s) => p.evaluate((s) => { const e = document.querySelector(s); return e ? e.innerText.replace(/\s+/g, ' ').trim() : null; }, s);
  const carritoLS = (p) => p.evaluate(() => JSON.parse(localStorage.getItem('athletix-carrito-v2') || '[]'));
  const cerrar = async (p) => { const e = p.errores.slice(); await p.context().close(); return e; };
  let p, t;

  // 1. Sin tallas, stock 0
  p = await abrir('producto.html?id=pt', { pt: { U: 0 } });
  ver(/agotado/i.test(await txt(p, 'main')) && await p.isDisabled('#form-compra button[type=submit]'), '1. Producto sin tallas agotado: aviso y botón desactivado');
  ver(!(await cerrar(p)).length, '   sin errores');
  // 2. Con tallas, todas en 0
  p = await abrir('producto.html?id=vx', { vx: { '*': 0 } });
  t = await txt(p, 'main');
  const todasDes = await p.evaluate(() => [...document.querySelectorAll('input[name=talla]')].every((i) => i.disabled));
  const botonDes = await p.isDisabled('#form-compra button[type=submit]');
  ver(todasDes, '2a. Calzado con todas las tallas en 0: todas las tallas desactivadas');
  ver(botonDes && /agotado/i.test(t), '2b. …y la página dice que está agotado y no deja agregar', `botón desactivado: ${botonDes}, dice agotado: ${/agotado/i.test(t)}`);
  if (!botonDes) { await p.click('#form-compra button[type=submit]'); await p.waitForTimeout(300); ver((await carritoLS(p)).length === 0, '2c. Al pulsar Agregar no entra nada al carrito', await txt(p, '#error-talla')); }
  await cerrar(p);
  // 3. Última unidad de una talla
  p = await abrir('producto.html?id=vx', { vx: { '42': 1, '41': 0 } });
  ver(await p.isDisabled('input[name=talla][value="41"]'), '3a. Talla 41 en 0 aparece desactivada');
  await p.check('input[name=talla][value="42"]', { force: true });
  ver(/Queda solo 1 unidad/.test(await txt(p, '#limite-cantidad')) && await p.isDisabled('[data-cambio="1"]'), '3b. Talla 42 con 1 unidad: aviso "queda solo 1" y botón + desactivado', await txt(p, '#limite-cantidad'));
  await p.click('#form-compra button[type=submit]'); await p.waitForTimeout(400);
  ver((await carritoLS(p))[0]?.cantidad === 1, '3c. Se agrega 1 unidad');
  await p.keyboard.press('Escape'); await p.waitForTimeout(200);
  await p.click('#form-compra button[type=submit]'); await p.waitForTimeout(400);
  ver(/Ya tienes el máximo/.test(await txt(p, '#dialogo')) && (await carritoLS(p))[0].cantidad === 1, '3d. Agregar otra vez: "Ya tienes el máximo" y el carrito sigue en 1');
  await cerrar(p);
  // 4. Llevar todo el stock
  p = await abrir('producto.html?id=pt', { pt: { U: 37 } });
  await p.click('#llevar-todo'); ver(await txt(p, '#cantidad') === '37', '4a. "Llevar todo (37)" pone la cantidad en 37', await txt(p, '#cantidad'));
  await p.click('#form-compra button[type=submit]'); await p.waitForTimeout(400);
  ver((await carritoLS(p))[0]?.cantidad === 37, '4b. Entran las 37 al carrito');
  await p.goto(B + 'carrito.html', { waitUntil: 'networkidle' }); await p.waitForTimeout(500);
  ver(await p.isDisabled('[data-accion="mas"]') && /37/.test(await txt(p, '.item-carrito')), '4c. En el carrito hay 37 y el + está desactivado');
  ver(!(await cerrar(p)).length, '   sin errores');
  // 5. El stock baja mientras el producto está en el carrito
  p = await abrir('carrito.html', { pt: { U: 2 } }, { carrito: [{ id: 'pt', talla: null, cantidad: 5 }] });
  t = await txt(p, 'main');
  ver(/Ajustamos la cantidad/.test(t) && (await carritoLS(p))[0].cantidad === 2, '5a. Tenía 5 y quedan 2: avisa y ajusta a 2', (t.match(/Ajustamos[^.]*\./) || [''])[0]);
  await cerrar(p);
  p = await abrir('carrito.html', { pt: { U: 0 }, vx: { '42': 0 } }, { carrito: [{ id: 'pt', talla: null, cantidad: 5 }, { id: 'vx', talla: '42', cantidad: 1 }, { id: 'fl', talla: null, cantidad: 2 }] });
  t = await txt(p, 'main'); const ca = await carritoLS(p);
  ver(/se agotó/.test(t) && ca.length === 1 && ca[0].id === 'fl', '5b. Dos productos se agotan: los quita con aviso y deja el que sí hay', `${ca.length} línea(s) en el carrito`);
  await cerrar(p);
  p = await abrir('carrito.html', { pt: { U: 0 } }, { carrito: [{ id: 'pt', talla: null, cantidad: 5 }] });
  t = await txt(p, 'main');
  ver(/se agotó/.test(t) && /carrito está vacío/i.test(t) && !(await p.$('#continuar-compra')), '5c. Se agota lo único del carrito: aviso, carrito vacío y sin botón de continuar');
  await cerrar(p);
  // 6. Producto borrado u oculto por el administrador
  p = await abrir('carrito.html', { fl: null }, { carrito: [{ id: 'fl', talla: null, cantidad: 2 }] });
  ver(/ya no está disponible/.test(await txt(p, 'main')) && (await carritoLS(p)).length === 0, '6a. Producto borrado que estaba en el carrito: lo quita con aviso');
  await cerrar(p);
  p = await abrir('producto.html?id=fl', { fl: null });
  ver(/No encontramos/.test(await txt(p, 'main h1')), '6b. Abrir el enlace de un producto borrado: "No encontramos esta página" (no se queda el contenido guardado)', await txt(p, 'main h1'));
  ver(!(await cerrar(p)).length, '   sin errores');
  // 7. Contenido previo desactualizado: la página guardada dice que hay stock y la base dice que no
  p = await abrir('producto.html?id=pt', { pt: { U: 0 } });
  ver(await p.isDisabled('#form-compra button[type=submit]'), '7a. Detalle: termina mostrando agotado aunque el HTML guardado tenía stock');
  await cerrar(p);
  p = await abrir('productos.html', { pt: { U: 0 }, vx: { '*': 0 } });
  const etiquetas = await p.evaluate(() => [...document.querySelectorAll('.tarjeta-producto')].filter((t) => /Agotado/.test(t.innerText)).length);
  ver(etiquetas === 2, '7b. Catálogo: las 2 tarjetas agotadas muestran "Agotado"', etiquetas + ' tarjetas');
  await cerrar(p);
  // 8. Carrito manipulado a mano en el navegador
  p = await abrir('carrito.html', {}, { carrito: [{ id: 'pt', talla: null, cantidad: 99999 }, { id: 'noexiste', talla: null, cantidad: 1 }, { id: 'vx', talla: '99', cantidad: 1 }, { id: 'fl', talla: null, cantidad: -3 }, { id: 'fl', talla: null, cantidad: 1.5 }, '<script>alert(1)</script>', null] });
  const cm = await carritoLS(p); t = await txt(p, 'main');
  ver(cm.length === 0 || cm.every((l) => l.id !== 'noexiste' && l.cantidad >= 1 && Number.isInteger(l.cantidad) && l.cantidad <= 100), '8. Carrito con datos inválidos (99999 unidades, producto y talla inexistentes, negativos, decimales, texto): se limpia solo', JSON.stringify(cm));
  ver(!(await cerrar(p)).length, '   sin errores');
  p = await abrir('carrito.html', { pt: { U: 29 } }, { carrito: [{ id: 'pt', talla: null, cantidad: 9999 }] });
  ver((await carritoLS(p))[0]?.cantidad === 29, '8b. 9999 unidades escritas a mano: se ajusta al stock (29)', JSON.stringify(await carritoLS(p)));
  await cerrar(p);
  // 9. Favoritos: agregar todos con uno agotado
  p = await abrir('favoritos.html', { pt: { U: 0 } }, { favoritos: ['pt', 'fl'] });
  t = await txt(p, 'main');
  ver(/Agotado/i.test(t), '9a. Favoritos muestra cuál está agotado');
  const todos = await p.$('#agregar-todos, [data-accion="agregar-todos"], button:has-text("Agregar todo")');
  if (todos) { await todos.click(); await p.waitForTimeout(500); const cf = await carritoLS(p); ver(cf.length === 1 && cf[0].id === 'fl', '9b. "Agregar todo": entra solo el que tiene stock', (await txt(p, '#dialogo') || '').slice(0, 120)); } else ver(false, '9b. no encontré el botón de agregar todos');
  ver(!(await cerrar(p)).length, '   sin errores');
  // 10. Cambiar cantidad en el carrito con poco stock
  p = await abrir('carrito.html', { pt: { U: 3 } }, { carrito: [{ id: 'pt', talla: null, cantidad: 1 }] });
  for (let i = 0; i < 6; i++) { const m = await p.$('[data-accion="mas"]:not([disabled])'); if (m) await m.click(); await p.waitForTimeout(120); }
  ver((await carritoLS(p))[0].cantidad === 3 && await p.isDisabled('[data-accion="mas"]'), '10a. Pulsar + seis veces con stock 3: se queda en 3');
  for (let i = 0; i < 6; i++) { const m = await p.$('[data-accion="menos"]:not([disabled])'); if (m) await m.click(); await p.waitForTimeout(120); }
  ver((await carritoLS(p))[0].cantidad === 1, '10b. Pulsar − seis veces: se queda en 1 (no baja a 0 ni negativo)');
  ver(!(await cerrar(p)).length, '   sin errores');
  // 11. Sin conexión con la base
  const c = await b.newContext({ viewport: { width: 390, height: 844 }, serviceWorkers: 'block' }); p = await c.newPage(); p.errores = []; p.on('pageerror', (e) => p.errores.push(e.message));
  await p.route(/supabase\.co/, (r) => r.abort());
  await p.addInitScript(() => localStorage.setItem('athletix-carrito-v2', JSON.stringify([{ id: 'pt', talla: null, cantidad: 1 }])));
  await p.goto(B + 'carrito.html', { waitUntil: 'domcontentloaded' }); await p.waitForTimeout(7000);
  t = await txt(p, 'body');
  ver(/Tu carrito/.test(t), '11a. Base de datos caída: el carrito igual se muestra', (t.match(/No (hay|se pudo)[^.]*\./) || [''])[0]);
  const cont = await p.$('#continuar-compra'); if (cont) { await cont.click(); await p.waitForTimeout(600); ver(/carrito\.html/.test(p.url()), '11b. …y no deja continuar la compra sin conexión', (await txt(p, '#aviso-flotante') || '').slice(0, 90)); }
  ver(!p.errores.length, '   sin errores', p.errores.join('|')); await c.close();

  console.log('fallas:', fallas); await b.close();
})();
