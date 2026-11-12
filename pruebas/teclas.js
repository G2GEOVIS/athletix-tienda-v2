// Alt + 64 (arroba), Alt Gr, acentos y ñ en los formularios de la v2 publicada
const { chromium } = require('playwright');
const B = process.argv[2] || 'https://g2geovis.github.io/athletix-tienda-v2/';
(async () => {
  const b = await chromium.launch(); let fallas = 0;
  const ver = (ok, t) => { if (!ok) fallas++; console.log((ok ? 'ok   ' : 'FALLA') + ' ' + t); };
  // Alt + 6 4 en el teclado numérico: Windows entrega el carácter al soltar Alt; aquí se envían las mismas teclas y luego el carácter
  const altCodigo = async (p, digitos, caracter) => { await p.keyboard.down('Alt'); for (const d of digitos) await p.keyboard.press('Numpad' + d); await p.keyboard.up('Alt'); await p.keyboard.insertText(caracter); };
  for (const [pag, sel] of [['login.html', '#correo'], ['registro.html', '#correo-r'], ['recuperar.html', '#correo-rec']]) {
    const p = await b.newPage(); const err = []; p.on('pageerror', (e) => err.push(e.message));
    await p.goto(B + pag, { waitUntil: 'networkidle' });
    await p.click(sel); await p.keyboard.type('cliente.prueba'); await altCodigo(p, '64', '@'); await p.keyboard.type('gmail.com');
    ver(await p.inputValue(sel) === 'cliente.prueba@gmail.com' && !err.length, `${pag}: Alt+64 escribe la arroba -> "${await p.inputValue(sel)}"`);
    await p.fill(sel, ''); await p.click(sel); await p.keyboard.type('cliente'); await p.keyboard.down('Control'); await p.keyboard.down('Alt'); await p.keyboard.press('KeyQ'); await p.keyboard.up('Alt'); await p.keyboard.up('Control'); await p.keyboard.insertText('@'); await p.keyboard.type('hotmail.com');
    ver(await p.inputValue(sel) === 'cliente@hotmail.com', `${pag}: Alt Gr + Q escribe la arroba -> "${await p.inputValue(sel)}"`);
    if (pag === 'login.html') { await p.click('#clave'); await p.keyboard.type('Ab'); await altCodigo(p, '64', '@'); await altCodigo(p, '35', '#'); await p.keyboard.type('12'); ver(await p.inputValue('#clave') === 'Ab@#12', `login.html: contraseña con Alt+64 y Alt+35 -> ${(await p.inputValue('#clave')).length} caracteres`); }
    if (pag === 'registro.html') {
      await p.click('#nombres'); await p.keyboard.type('Mar'); await altCodigo(p, '161', 'í'); await p.keyboard.type('a Jos'); await altCodigo(p, '130', 'é');
      await p.click('#apellidos'); await p.keyboard.type('Mu'); await altCodigo(p, '164', 'ñ'); await p.keyboard.type('oz Pe'); await altCodigo(p, '0241', 'ñ'); await p.keyboard.type('a');
      ver(await p.inputValue('#nombres') === 'María José' && await p.inputValue('#apellidos') === 'Muñoz Peña', `registro.html: acentos y ñ con Alt -> "${await p.inputValue('#nombres')}" / "${await p.inputValue('#apellidos')}"`);
      await p.click('#cedula'); await p.keyboard.type('17a1b0c34415'); ver(/^\d{0,10}$/.test(await p.inputValue('#cedula')), `registro.html: la cédula deja solo números -> "${await p.inputValue('#cedula')}"`);
    }
    ver(!err.length, `${pag}: sin errores (${err.join(' | ')})`);
    await p.close();
  }
  console.log('fallas:', fallas); await b.close();
})();
