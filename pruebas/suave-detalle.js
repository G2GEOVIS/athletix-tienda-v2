// 3. En el detalle: el cliente elige talla y la base responde después con otro stock -> la talla sigue elegida y el límite se actualiza
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
(async () => { const b = await chromium.launch(); const c = await b.newContext({ viewport: { width: 390, height: 844 }, serviceWorkers: 'block' }); const p = await c.newPage(); const err = []; p.on('pageerror', (e) => err.push(e.message));
  await p.route(/rest\/v1\/producto\?/, async (r) => { const resp = await r.fetch(); const d = await resp.json(); for (const x of d) if (x.prd_codigo === 'vx') for (const t of x.producto_talla) t.pta_cantidad = t.pta_talla === '42' ? 2 : t.pta_talla === '43' ? 0 : t.pta_cantidad; await new Promise((ok) => setTimeout(ok, 2500)); await r.fulfill({ response: resp, json: d }); });
  await p.goto(B + 'producto.html?id=vx', { waitUntil: 'domcontentloaded' }); await p.waitForFunction(() => window.athletixPintado); await p.waitForTimeout(500);
  await p.check('input[name=talla][value="42"]', { force: true }); const antes = await p.evaluate(() => document.getElementById('limite-cantidad').innerText);
  await p.waitForTimeout(3500);
  const r = await p.evaluate(() => ({ talla: (document.querySelector('input[name=talla]:checked') || {}).value, limite: document.getElementById('limite-cantidad').innerText, elegida: document.getElementById('talla-elegida').innerText, t43: document.querySelector('input[name=talla][value="43"]').disabled }));
  const ok = r.talla === '42' && /Quedan solo 2/.test(r.limite) && r.t43 && !err.length;
  console.log((ok ? 'ok   ' : 'FALLA') + ' 3. Detalle: la talla 42 sigue elegida y el límite pasa a 2 cuando la base responde; la 43 queda desactivada -> ' + JSON.stringify({ antes, ...r }) + err.join('|'));
  console.log('fallas:', ok ? 0 : 1); await b.close(); })();
