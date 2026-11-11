/* ATHLETIX v2 · Construcción de los archivos que se publican (JS y CSS minificados y separados por grupo de páginas).
   El código legible sigue en js/ y css/; aquí se juntan y comprimen en js/min/ y css/estilos.min.css.
   Cada página carga la base y solo los grupos de vistas que usa (ver herramientas/generar_paginas.py).
   Uso:  npm run construir   (o: node herramientas/construir.mjs) */
import { transform } from 'esbuild';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';

const RAIZ = join(dirname(fileURLToPath(import.meta.url)), '..');
const leer = (r) => readFileSync(join(RAIZ, r), 'utf8');

export const GRUPOS = {
  // Lo que usa cualquier página: configuración, validaciones, datos, conexión con la base, utilidades,
  // páginas informativas y el arranque (encabezado, sesión y enrutador)
  base: ['js/config.js', 'js/validaciones.js', 'js/datos.js', 'js/api.js', 'js/core.js', 'js/vistas-info.js', 'js/app.js'],
  tienda: ['js/vistas-tienda.js'],
  cuenta: ['js/vistas-cuenta.js'],
  compra: ['js/vistas-compra.js', 'js/factura.js'],
  admin: ['js/vistas-admin.js']
};

const kb = (n) => (n / 1024).toFixed(1) + ' KB';
mkdirSync(join(RAIZ, 'js/min'), { recursive: true });
let antes = 0, despues = 0;
for (const [nombre, archivos] of Object.entries(GRUPOS)) {
  const fuente = archivos.map(leer).join('\n;\n');
  // Sin "format": esbuild no renombra las funciones de primer nivel, que se comparten entre archivos
  const { code } = await transform(fuente, { loader: 'js', minify: true, target: 'es2019', legalComments: 'none' });
  writeFileSync(join(RAIZ, `js/min/${nombre}.min.js`), code);
  antes += fuente.length; despues += code.length;
  console.log(`js/min/${nombre}.min.js  ${kb(fuente.length)} -> ${kb(code.length)} (gzip ${kb(gzipSync(code).length)})`);
}
const css = leer('css/estilos.css');
const { code: cssMin } = await transform(css, { loader: 'css', minify: true, target: ['chrome90', 'safari14', 'firefox90'] });
writeFileSync(join(RAIZ, 'css/estilos.min.css'), cssMin);
console.log(`css/estilos.min.css  ${kb(css.length)} -> ${kb(cssMin.length)} (gzip ${kb(gzipSync(cssMin).length)})`);
console.log(`JS total ${kb(antes)} -> ${kb(despues)}`);
