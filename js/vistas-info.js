/* ATHLETIX · Páginas informativas (Ayuda, Quiénes somos, Página no encontrada) y tiendas de retiro.
   Se cargan en todas las páginas porque son livianas y cualquier página puede mostrar "no encontrada". */
'use strict';

/* Tiendas de retiro: se piden a la base una sola vez por página */
async function cargarTiendas() {
  if (estado.tiendas.length) return { datos: estado.tiendas };
  const r = await Api.catalogo.tiendas();
  if (!r.error) estado.tiendas = r.datos || [];
  return r;
}

/* ======================= Ayuda y página no encontrada ======================= */
function vistaAyuda() {
  return {
    titulo: 'Centro de ayuda',
    seccion: 'ayuda',
    html: `
    <div class="contenedor pagina">
      <h1 class="titulo-pagina">Centro de ayuda</h1>
      <p class="subtitulo cabecera-pagina">Respuestas a las preguntas más frecuentes.</p>
      <div class="preguntas">
        ${AYUDA.map(([q, r], i) => `<details class="pregunta" ${i === 0 ? 'open' : ''}><summary>${q}</summary><p>${r}</p></details>`).join('')}
      </div>
      <div class="panel panel--gris" style="margin-top:2rem;max-width:48rem">
        <h2>¿Necesitas más ayuda?</h2>
        <p>Escríbenos a <a href="mailto:geovannymorocho621@gmail.com?subject=Consulta%20ATHLETIX">geovannymorocho621@gmail.com</a> y te respondemos de lunes a sábado, de 09:00 a 18:00.</p>
      </div>
    </div>`
  };
}

/* ======================= Quiénes somos ======================= */
async function vistaQuienesSomos() {
  // Las tiendas se leen de la base (las mismas donde se retira el pedido); si no responde, la sección no se muestra
  const rt = await cargarTiendas();
  const tiendas = rt.error ? [] : estado.tiendas;
  const activos = PRODUCTOS.filter((p) => p.activo !== false);
  const cuantos = (c) => activos.filter((p) => p.categoria === c).length;
  return {
    titulo: 'Quiénes somos',
    seccion: 'quienes-somos',
    html: `
    <div class="contenedor pagina quienes">
      <h1 class="titulo-pagina">Quiénes somos</h1>
      <p class="subtitulo cabecera-pagina">ATHLETIX es una tienda deportiva ecuatoriana. Vendemos en línea y entregamos en nuestras tiendas de Quito y Guayaquil, sin costo de envío.</p>

      <section class="quienes__bloque" aria-labelledby="q-historia">
        <h2 class="titulo-seccion" id="q-historia">Nuestra historia</h2>
        <p>ATHLETIX nació de una queja que escuchábamos seguido entre amigos que corren y entrenan: para conseguir unas buenas zapatillas o un reloj deportivo había que recorrer varios locales, preguntar si quedaba la talla y muchas veces volver con las manos vacías.</p>
        <p>Por eso juntamos en un solo lugar el calzado, la tecnología y el equipo de entrenamiento que usamos nosotros mismos, y mostramos en la web el stock real de cada talla. Antes de salir de casa ya sabes si lo que buscas está disponible.</p>
        <p>Elegimos el retiro en tienda porque es más rápido que esperar un envío: compras en la web y en una a tres horas tu pedido está listo, sin costo extra. Hoy atendemos en Quito y Guayaquil, y seguimos escogiendo cada producto con el mismo criterio con el que empezamos: que de verdad sirva para entrenar.</p>
      </section>

      <div class="quienes__grilla">
        <section class="panel" aria-labelledby="q-mision">
          <span class="quienes__icono">${icono('escudo')}</span>
          <h2 id="q-mision">Misión</h2>
          <p>Acercar a cada deportista el calzado, la tecnología y el equipo que necesita, con precios claros, compra fácil y retiro rápido en tienda.</p>
        </section>
        <section class="panel" aria-labelledby="q-vision">
          <span class="quienes__icono">${icono('grafico')}</span>
          <h2 id="q-vision">Visión</h2>
          <p>Ser la tienda deportiva en línea de referencia en Ecuador, reconocida por una experiencia de compra accesible para todas las personas.</p>
        </section>
        <section class="panel" aria-labelledby="q-valores">
          <span class="quienes__icono">${icono('estrella')}</span>
          <h2 id="q-valores">Valores</h2>
          <ul class="quienes__lista">
            <li><strong>Honestidad:</strong> el precio que ves es el que pagas, con el IVA indicado.</li>
            <li><strong>Opiniones reales:</strong> solo opina quien compró el producto.</li>
            <li><strong>Accesibilidad:</strong> la tienda se usa con teclado, lector de pantalla y celular.</li>
          </ul>
        </section>
      </div>

      <section class="quienes__bloque" aria-labelledby="q-ofrecemos">
        <h2 class="titulo-seccion" id="q-ofrecemos">Qué vendemos</h2>
        <ul class="quienes__categorias">
          ${Object.entries(CATEGORIAS).map(([c, t]) => `<li><a class="panel panel--gris" href="productos.html?cat=${c}"><strong>${t}</strong><span>${plural(cuantos(c), 'producto', 'productos')}</span></a></li>`).join('')}
        </ul>
      </section>

      ${tiendas.length ? `
      <section class="quienes__bloque" aria-labelledby="q-tiendas">
        <h2 class="titulo-seccion" id="q-tiendas">Nuestras tiendas</h2>
        <p class="texto-suave">Aquí retiras tus pedidos. Lleva tu cédula o pasaporte y tu número de pedido.</p>
        <ul class="quienes__tiendas">
          ${tiendas.map((t) => `<li class="panel">
            <h3>${icono('tienda')}${esc(t.nombre)}</h3>
            <p>${esc(t.direccion)}${t.ciudad ? `, ${esc(t.ciudad)}` : ''}</p>
            ${t.horario ? `<p class="texto-suave">${esc(t.horario)}</p>` : ''}
          </li>`).join('')}
        </ul>
      </section>` : ''}
    </div>`
  };
}

function vistaNoEncontrada() {
  return {
    titulo: 'Página no encontrada',
    seccion: '',
    html: `
    <div class="contenedor pagina centro">
      <h1 class="titulo-pagina">No encontramos esta página</h1>
      <p class="subtitulo">Puede que el enlace esté incompleto.</p>
      <a class="boton boton--principal" style="margin-top:1.5rem" href="index.html">Ir al inicio</a>
    </div>`
  };
}
