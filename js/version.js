/* ATHLETIX · Versión publicada (la escribe herramientas/generar_paginas.py; no editar a mano) */
window.VERSION_SITIO = '0fd2c5c69a';
// Grupos de vistas con su versión: se usan para adelantar (prefetch) el siguiente paso de la compra
window.GRUPOS_SITIO = {"tienda": "js/min/tienda.min.js?v=98a13768", "cuenta": "js/min/cuenta.min.js?v=d30faef5", "compra": "js/min/compra.min.js?v=189d7091", "admin": "js/min/admin.min.js?v=9302412e"};
(function () {
  var meta = document.querySelector('meta[name="version-sitio"]');
  var pagina = meta && meta.content;
  if (!pagina || pagina === window.VERSION_SITIO) return;
  var marca = 'recarga-' + window.VERSION_SITIO;
  try { if (sessionStorage.getItem(marca)) return; sessionStorage.setItem(marca, '1'); } catch (e) { return; }
  var u = new URL(location.href); u.searchParams.set('v', window.VERSION_SITIO); location.replace(u.toString());
})();
