/* ATHLETIX · Versión publicada (la escribe herramientas/generar_paginas.py; no editar a mano) */
window.VERSION_SITIO = '8d3fcd346a';
(function () {
  var meta = document.querySelector('meta[name="version-sitio"]');
  var pagina = meta && meta.content;
  if (!pagina || pagina === window.VERSION_SITIO) return;
  var marca = 'recarga-' + window.VERSION_SITIO;
  try { if (sessionStorage.getItem(marca)) return; sessionStorage.setItem(marca, '1'); } catch (e) { return; }
  var u = new URL(location.href); u.searchParams.set('v', window.VERSION_SITIO); location.replace(u.toString());
})();
